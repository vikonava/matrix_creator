require 'fileutils'
require 'json'

module MatrixCreator
  ##
  # Class: Comm
  #
  # This class is used to communicate to the chipset by using ZeroMQ sockets
  class Comm # rubocop:disable Metrics/ClassLength
    # Contains the IP address to be used to connect to the Matrix Creator chipset
    MATRIX_CREATOR_IP = MatrixCreator.settings[:ip]

    # Maximum number of old log files to keep
    MAX_OLD_FILES = 10

    # Maximum size for each log file
    MAX_LOG_SIZE = 102_400_000

    # Current logger level to store
    LOG_LEVEL = Logger::WARN

    # Pinging speed
    PING_SPEED = 3

    # Speed to check for timeout
    TIMEOUT_VERIFICATION_SPEED = 1

    # Contains the ZMQ::Context instance used
    attr_reader :context

    # Contains device base port
    attr_reader :device_port

    ##
    # Creates an instance of Comm to be used as communication with chipset's device
    #
    # @param device_port [Integer] port of the device to communicate with
    def initialize(device_port)
      initialize_logger

      # Creating instance variables
      print_log(:debug, 'Initializing instance')
      @context = ::ZMQ::Context.new
      @device_port = device_port
    end

    ##
    # Sends configuration data to the driver
    #
    # @param driver_config [MatrixMalos::DriverConfig] data message
    def send_configuration(driver_config)
      # Connecting to the configuration port
      socket_address = "tcp://#{MATRIX_CREATOR_IP}:#{@device_port}"
      config_socket = @context.socket(:PUSH)
      config_socket.connect(socket_address)
      print_log(:debug, "config_socket connected to #{socket_address}")

      # Sending Encoded Data
      config_data = MatrixMalos::DriverConfig.encode(driver_config)
      config_socket.send(config_data)
      print_log(:info, 'Configuration sent to driver')
      print_log(:debug, "Data: #{driver_config.to_json}")
    end

    ##
    # Pings the driver keep-alive port every 3 seconds until listener finishes running
    #
    # @param main_thread [Thread] the main listener
    # @return [Thread] instance
    def start_pinging(main_thread)
      Thread.new do
        # Connecting to the keep-alive port
        socket_address = "tcp://#{MATRIX_CREATOR_IP}:#{@device_port + 1}"
        ping_socket = @context.socket(:PUSH)
        ping_socket.connect(socket_address)
        print_log(:debug, "ping_socket connected to #{socket_address}")

        # Infinite loop that breaks when main thread has finished
        loop do
          # Send Ping
          ping_socket.send('')
          print_log(:info, 'Ping sent')

          sleep(PING_SPEED)

          break if main_thread[:finished]
        end

        print_log(:debug, 'Stopped pinging')
      end
    end

    ##
    # Connects to the error port to listen for any errors reported
    #
    # @return [Thread] instance
    def start_error_listener
      Thread.new do
        # Connecting to the error port
        socket_address = "tcp://#{MATRIX_CREATOR_IP}:#{@device_port + 2}"
        error_socket = @context.socket(:SUB)
        error_socket.connect(socket_address)
        error_socket.subscribe('')

        # Infinite loop to listen for errors, this thread will be killed
        # by the main thread when it needs to be stopped
        loop do
          # Read and log error messages
          error_msg = error_socket.recv_message
          print_log(:error, error_msg.data)
        end
      end
    end

    ##
    # Main thread that listens for data reported by the driver data port.
    # It will listen for any errors until the maximum number of messages expected
    # to be received is reached or until it is killed by the timeout verification.
    #
    # @param decoder [MatrixMalos] module to be used to decode data received
    # @param max_resp [Integer] maximum number of messages to receive
    # @param error_thread [Thread] instance that logs errors
    # @param block callback method to be executed when a message has been received
    # @return [Thread] instance
    def start_data_listener(decoder, max_resp, error_thread, block = nil)
      Thread.new do
        # Initialize current number of messages received
        count = 0

        begin
          # Thread variable that indicates if this thread has finished
          Thread.current[:finished] = false

          # Thread variable that contains an array of messages received
          # for further processing
          Thread.current[:result] = []

          # Connecting to the data port
          socket_address = "tcp://#{MATRIX_CREATOR_IP}:#{@device_port + 3}"
          data_socket = @context.socket(:SUB)
          data_socket.connect(socket_address)
          print_log(:debug, "data_socket connected to #{socket_address}")
          data_socket.subscribe('')
          print_log(:info, "Listening for data (max_resp: #{max_resp || 'Unlimited'})")

          loop do
            # Receiving data
            data = data_socket.recv
            print_log(:info, 'Data received')
            decoded_data = JSON.parse(decoder.decode(data).to_json, symbolize_names: true)
            print_log(:debug, "Data: #{decoded_data}")

            # Push decoded data into the results array
            Thread.current[:result] << decoded_data

            # Send data to callback method
            block.call(decoded_data) if block

            # Increment count and break loop if max number of
            # messages has been reached
            count += 1
            break if max_resp && count >= max_resp
          end
        rescue => e
          print_log(:fatal, e.message)
        end

        # Mark thread as finished
        Thread.current[:finished] = true
        print_log(:info, 'Finished listening')

        # Kill error thread, no longer need to log errors
        Thread.kill(error_thread)
        print_log(:info, 'Killed error listener thread')
      end
    end

    ##
    # Verifies if there is a timeout according to the max number of seconds specified,
    # if there is then all threads are killed
    #
    # @param max_secs [Integer] maximum number of seconds to gather data
    # @param main_thread [Thread] instance of the main data listener
    # @param error_thread [Thread] instance of the error listener
    # @param ping_thread [Thread] instance of the ping thread
    def verify_timeout(max_secs, main_thread, error_thread, ping_thread)
      current_time = Time.now

      print_log(:info, "Starting timeout verification (max_secs: #{max_secs})")

      loop do
        # Break if main thread is finished, we no longer need to check for timeout
        break if main_thread[:finished]

        # If there is a timeout, kill all threads and break
        if Time.now >= current_time + max_secs
          print_log(:info, 'Listener timed out, killing all threads')
          Thread.kill(main_thread)
          Thread.kill(error_thread)
          Thread.kill(ping_thread)
          break
        end

        sleep(TIMEOUT_VERIFICATION_SPEED)
      end

      print_log(:info, 'Finishing timeout verification')
    end

    ##
    # Start the listening proccess on a driver.
    #
    # @param decoder [MatrixMalos] module to be used to decode data received
    # @param options [Hash] contains the options that can be specified for a max_resp and/or max_secs
    # @yield callback used to process data received from the driver
    # @return an array with a list of all the messages received
    def perform(decoder, options = {}, &block)
      # Start running threads
      error_thread = start_error_listener
      data_thread = start_data_listener(decoder, options[:max_resp], error_thread, block)
      ping_thread = start_pinging(data_thread)

      # Verify timeout if that option is specified
      if options[:max_secs]
        verify_timeout(options[:max_secs], data_thread, error_thread, ping_thread)
      end

      # Wait for threads to finish
      data_thread.join
      error_thread.join
      ping_thread.join

      # Return data captured from the driver
      print_log(:debug, "Data Result: #{data_thread[:result].to_json}")
      data_thread[:result]
    end

    ##
    # Destroy the ZMQ::Context instance, since there can only be one running per proccess
    def destroy
      print_log(:info, 'Destroying ZMQ context')
      @context.destroy
    end

    private

    ##
    # Initialize logger instance
    def initialize_logger
      # Logger initialization
      FileUtils.mkdir_p('log/') unless File.directory?('log/')
      @logger = Logger.new('log/matrix_creator.log', MAX_OLD_FILES, MAX_LOG_SIZE)
      @logger.level = LOG_LEVEL
    end

    ##
    # Send a message to the logger instance
    #
    # @param level [Symbol] logging level for the message
    # @param msg [String] message to be logged
    def print_log(level, msg)
      @logger.send(level, "[Instance: #{object_id}] #{msg}")
    end
  end
end
