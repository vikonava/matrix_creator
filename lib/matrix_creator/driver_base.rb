# Load Protos
require 'protos/malos/driver_pb'

# Load Dependencies
require 'matrix_creator/comm'

module MatrixCreator
  # Module: DriverBase
  #
  # Base communication for generic drivers
  module DriverBase
    ##
    # Detects and returns information from a generic driver
    #
    # @param base_port [Integer] indicates the base port to communicate to the driver
    # @param decoder ProtoBuf to use for decoding returned data
    # @param options [Hash] of keys and values that can contain speed, max_resp and/or max_secs
    # @return [Array] elements detected in JSON format
    #
    # @example Detect value from a driver and return data
    #   MatrixCreator::DriverBase.detect(8888, MatrixMalos::Imu, max_resp: 3)
    #
    # @example Detect value from a driver and process data immediatly when received
    #   MatrixCreator::DriverBase.detect(8888, MatrixMalos::Imu, max_resp: 3) { |data|
    #     // Do something with data
    #   }
    #
    def self.detect(base_port, decoder, options = {}, block = nil)
      @driver_comm = MatrixCreator::Comm.new(base_port)

      # Setup Driver
      config = MatrixMalos::DriverConfig.new(
        delay_between_updates: options[:speed] || 1.0,
        timeout_after_last_ping: 4.0
      )
      @driver_comm.send_configuration(config)

      # Query Driver
      result = @driver_comm.perform(decoder, options, block)

      # Destroy context
      @driver_comm.destroy

      result
    end
  end
end
