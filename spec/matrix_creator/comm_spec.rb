require 'spec_helper'

RSpec.describe MatrixCreator::Comm do
  let(:base_port) { 9000 }
  let(:zmq_context) { double('ZMQ::Context') }
  let(:zmq_socket) { double('ZMQ::Socket') }
  let(:decoded_data) { double('MatrixMalos::DecodedData') }
  let(:encoded_data) { double('MatrixMalos::EncodedData') }

  let(:decoder) { double('MatrixMalos::ProtoDecoder') }
  let(:error_thread) { double('Thread::ErrorListener') }
  let(:ping_thread) { double('Thread::Pinger') }

  let(:logger) { double('Logger.instance') }

  before(:each) do |example|
    stub_const('MatrixCreator::Comm::PING_SPEED', 0)

    allow(ZMQ::Context).to receive(:new).and_return(zmq_context)

    # Generate logger
    allow(Logger).to receive(:new).and_return(logger)
    allow(logger).to receive(:level=)
    allow(logger).to receive(:debug)
    allow(logger).to receive(:info)
    allow(logger).to receive(:warn)
    allow(logger).to receive(:error)

    # Generate socket configuration
    allow(zmq_context).to receive(:socket).and_return(zmq_socket)
    allow(zmq_socket).to receive(:connect)
    allow(zmq_socket).to receive(:send)
    allow(zmq_socket).to receive(:subscribe)

    # Allow DriverConfig to encode data
    allow(MatrixMalos::DriverConfig).to receive(:encode).with(decoded_data).and_return(encoded_data)

    # Generate instance 
    allow_any_instance_of(MatrixCreator::Comm).to receive(:print_log)
    allow_any_instance_of(MatrixCreator::Comm).to receive(:initialize_logger)
    @comm_instance = MatrixCreator::Comm.new(base_port)
  end

  describe 'initialize' do
    before(:each) do
      allow_any_instance_of(MatrixCreator::Comm).to receive(:initialize_logger)
      allow_any_instance_of(MatrixCreator::Comm).to receive(:print_log)
    end

    it 'initializes logger' do
      expect_any_instance_of(MatrixCreator::Comm).to receive(:initialize_logger)

      MatrixCreator::Comm.new(base_port)
    end

    it 'assigns context variable' do
      instance = MatrixCreator::Comm.new(base_port)

      expect(instance.context).to be(zmq_context)
    end

    it 'assigns device base port variable' do
      instance = MatrixCreator::Comm.new(base_port)

      expect(instance.device_port).to be(9000)
    end
  end

  describe 'send_configuration' do
    it 'creates a PUSH socket' do
      expect(@comm_instance.context).to receive(:socket).with(:PUSH)

      @comm_instance.send_configuration(decoded_data)
    end

    it 'connects to the base port of the device' do
      expect(zmq_socket).to receive(:connect).with('tcp://127.0.0.1:9000')

      @comm_instance.send_configuration(decoded_data)
    end

    it 'sends encoded configuration to device' do
      expect(zmq_socket).to receive(:send).with(encoded_data)

      @comm_instance.send_configuration(decoded_data)
    end
  end

  describe 'start_pinging' do
    before(:each) do
      @main_thread = { finished: true }
    end

    after(:each) do
      Thread.kill(@ping_thread)
    end

    it 'returns a thread instance' do
      @ping_thread = @comm_instance.start_pinging(@main_thread)

      expect(@ping_thread.class).to be(Thread)
    end

    it 'creates a PUSH socket' do
      expect(@comm_instance.context).to receive(:socket).with(:PUSH)

      @ping_thread = @comm_instance.start_pinging(@main_thread)
      wait_for_thread(@ping_thread)
    end

    it 'connects to the Ping port of the device' do
      expect(zmq_socket).to receive(:connect).with('tcp://127.0.0.1:9001')

      @ping_thread = @comm_instance.start_pinging(@main_thread)
      wait_for_thread(@ping_thread)
    end

    it 'sends a ping every PING_SPEED seconds' do
      @main_thread = { finished: false }

      sleep_count = 0
      allow(@comm_instance).to receive(:sleep) do
        sleep_count += 1
        if sleep_count > 2
          @main_thread[:finished] = true
        end
      end

      expect(zmq_socket).to receive(:send).exactly(3).times

      @ping_thread = @comm_instance.start_pinging(@main_thread)
      wait_for_thread(@ping_thread)

      expect(sleep_count).to eq(3)
    end

    it 'finishes when main thread variable finished is true' do
      @ping_thread = @comm_instance.start_pinging(@main_thread)
      wait_for_thread(@ping_thread)

      expect(@ping_thread.alive?).to be(false)
    end
  end

  describe 'start_error_listener' do
    let(:error_msg) { double('ZMQ::Message') }
    let(:error_data) { double('ZMQ::Message.data') }

    before(:each) do
      allow(error_msg).to receive(:data).and_return(error_data)
    end

    after(:each) do
      Thread.kill(@error_thread)
    end

    it 'returns a thread instance' do
      @error_thread = @comm_instance.start_error_listener

      expect(@error_thread.class).to be(Thread)
    end

    it 'creates a SUB socket' do
      expect(@comm_instance.context).to receive(:socket).with(:SUB)

      @error_thread = @comm_instance.start_error_listener
      sleep(0.01)
    end

    it 'connects to the Error port of the device' do
      expect(zmq_socket).to receive(:connect).with('tcp://127.0.0.1:9002')

      @error_thread = @comm_instance.start_error_listener
      sleep(0.01)
    end

    it 'subscribes to the socket' do
      expect(zmq_socket).to receive(:subscribe).with('')

      @error_thread = @comm_instance.start_error_listener
      sleep(0.01)
    end

    it 'logs error when received' do
      allow(zmq_socket).to receive(:recv_message).once.and_return(error_msg)
      allow(@comm_instance).to receive(:print_log).with(:error, error_data)

      @error_thread = @comm_instance.start_error_listener
      sleep(0.01)
    end
  end

  describe 'start_data_listener' do
    let(:callback) { double('CallbackBlock') }
    let(:decoded_json) { { data: 'decoded' }.to_json }

    before(:each) do |example|
      allow(Thread).to receive(:kill)
      allow(zmq_socket).to receive(:recv).and_return(encoded_data)
      allow(decoded_data).to receive(:to_json).and_return(decoded_json)

      unless example.metadata[:skip_recv]
        allow(decoder).to receive(:decode).with(encoded_data).and_return(decoded_data)
      end
    end

    after(:each) do
      Thread.kill(@data_thread)
    end

    it 'returns a thread instance' do
      @data_thread = @comm_instance.start_data_listener(decoder, 1, error_thread, nil)

      expect(@data_thread.class).to be(Thread)
    end

    it 'initializes thread finished variable to false', skip_recv: true do
      @data_thread = @comm_instance.start_data_listener(decoder, 1, error_thread, nil)
      wait_for_thread(@data_thread)

      expect(@data_thread[:finished]).to be(false)
    end

    it 'creates a SUB socket' do
      expect(zmq_context).to receive(:socket).with(:SUB)

      @data_thread = @comm_instance.start_data_listener(decoder, 1, error_thread, nil)
      wait_for_thread(@data_thread)
    end

    it 'connects to the Data port of the device' do
      expect(zmq_socket).to receive(:connect).with('tcp://127.0.0.1:9003')

      @data_thread = @comm_instance.start_data_listener(decoder, 1, error_thread, nil)
      wait_for_thread(@data_thread)
    end

    it 'subscribes to the socket' do
      expect(zmq_socket).to receive(:subscribe).with('')

      @data_thread = @comm_instance.start_data_listener(decoder, 1, error_thread, nil)
      wait_for_thread(@data_thread)
    end

    it 'does not process data if there is no callback' do
      expect(callback).not_to receive(:call)

      @data_thread = @comm_instance.start_data_listener(decoder, 1, error_thread, nil)
      wait_for_thread(@data_thread)
    end

    it 'processes decoded data with the callback' do
      expect(callback).to receive(:call).with(JSON.parse(decoded_json, symbolize_names: true))

      @data_thread = @comm_instance.start_data_listener(decoder, 1, error_thread, callback)
      wait_for_thread(@data_thread)
    end

    it 'continues thread if max responses not reached' do
      expect(zmq_socket).to receive(:recv).at_least(:twice)

      @data_thread = @comm_instance.start_data_listener(decoder, nil, error_thread, nil)
      sleep(0.05)

      expect(@data_thread.alive?).to be(true)
    end

    it 'stops thread when max responses number is reached' do
      expect(zmq_socket).to receive(:recv).exactly(5).times

      @data_thread = @comm_instance.start_data_listener(decoder, 5, error_thread, nil)
      wait_for_thread(@data_thread)
    end

    it 'sets thread finished variable to true when finishing' do
      @data_thread = @comm_instance.start_data_listener(decoder, 5, error_thread, nil)
      wait_for_thread(@data_thread)

      expect(@data_thread[:finished]).to be(true)
    end

    it 'creates log message when fatal error' do
      expect(zmq_socket).to receive(:recv).and_raise(StandardError)
      expect(@comm_instance).to receive(:print_log).with(:fatal, anything)

      @data_thread = @comm_instance.start_data_listener(decoder, 1, error_thread, nil)
      wait_for_thread(@data_thread)
    end

    it 'stops thread when fatal error' do
      expect(zmq_socket).to receive(:recv).and_raise(StandardError)

      @data_thread = @comm_instance.start_data_listener(decoder, 1, error_thread, nil)
      wait_for_thread(@data_thread)

      expect(@data_thread.alive?).to be(false)
    end

    it 'kills error thread when finishing' do
      expect(Thread).to receive(:kill).with(error_thread)

      @data_thread = @comm_instance.start_data_listener(decoder, 1, error_thread, nil)
      wait_for_thread(@data_thread)
    end

    it 'thread result variable has an array of received data objects' do
      result_mock = Array.new(5){ JSON.parse(decoded_json, symbolize_names: true) }

      @data_thread = @comm_instance.start_data_listener(decoder, 5, error_thread, nil)
      wait_for_thread(@data_thread)

      expect(@data_thread[:result]).to eq(result_mock)
    end
  end

  describe 'verify_timeout' do
    before(:each) do
      @main_thread = { finished: false }

      allow(Thread).to receive(:kill)
    end

    it 'finishes when main code thread finishes execution not killing threads' do
      @main_thread = { finished: true }

      expect(Thread).not_to receive(:kill)

      @comm_instance.verify_timeout(999, @main_thread, error_thread, ping_thread)
    end

    it 'kills main thread when there is a timeout' do
      expect(Thread).to receive(:kill).with(@main_thread)

      @comm_instance.verify_timeout(0.01, @main_thread, error_thread, ping_thread)
    end

    it 'kills error thread when there is a timeout' do
      expect(Thread).to receive(:kill).with(error_thread)

      @comm_instance.verify_timeout(0, @main_thread, error_thread, ping_thread)
    end

    it 'kills ping thread when there is a timeout' do
      expect(Thread).to receive(:kill).with(ping_thread)

      @comm_instance.verify_timeout(0, @main_thread, error_thread, ping_thread)
    end
  end

  describe 'perform' do
    let(:block) { double('BlockOfCode') }

    before(:each) do
      @data_thread = { result: [{ decoded: 'data' }] }

      allow(@comm_instance).to receive(:start_error_listener).and_return(error_thread)
      allow(@comm_instance).to receive(:start_data_listener).and_return(@data_thread)
      allow(@comm_instance).to receive(:start_pinging).and_return(ping_thread)
      allow(@comm_instance).to receive(:verify_timeout)

      allow(error_thread).to receive(:join)
      allow(@data_thread).to receive(:join)
      allow(ping_thread).to receive(:join)
    end

    it 'starts error thread' do
      expect(@comm_instance).to receive(:start_error_listener)
      expect(error_thread).to receive(:join)

      @comm_instance.perform(decoder)
    end

    it 'starts data thread with corresponding params and a block of code' do
      expect(@comm_instance).to receive(:start_data_listener).with(decoder, 10, error_thread, anything)
      expect(error_thread).to receive(:join)

      @comm_instance.perform(decoder, max_resp: 10){ block }
    end

    it 'starts ping thread' do
      expect(@comm_instance).to receive(:start_pinging).with(@data_thread)
      expect(error_thread).to receive(:join)

      @comm_instance.perform(decoder)
    end

    it 'does not start timeout verification if no max_secs specified' do
      expect(@comm_instance).not_to receive(:verify_timeout)

      @comm_instance.perform(decoder)
    end

    it 'starts timeout verification thread when max_secs are specified' do
      expect(@comm_instance).to receive(:verify_timeout).with(60, @data_thread, error_thread, ping_thread)

      @comm_instance.perform(decoder, max_secs: 60)
    end

    it 'returns data thread results when finishing' do
      result = @comm_instance.perform(decoder)

      expect(result).to eq(@data_thread[:result])
    end
  end

  describe 'destroy' do
    it 'destroys ZMQ::Context' do
      expect(zmq_context).to receive(:destroy)

      @comm_instance.destroy
    end
  end

  context 'private' do
    describe 'initialize_logger' do
      before(:each) do
        allow(@comm_instance).to receive(:initialize_logger).and_call_original

        allow(File).to receive(:directory?).with('log/').and_return(true)
      end

      it 'creates log folder if it doesnt exist' do
        allow(File).to receive(:directory?).with('log/').and_return(false)
        expect(FileUtils).to receive(:mkdir_p).and_return('log/')

        @comm_instance.send(:initialize_logger)
      end

      it 'does not create log folder if already existing' do
        expect(FileUtils).not_to receive(:mkdir_p)

        @comm_instance.send(:initialize_logger)
      end

      it 'assigns the logger instance to the Comm instance' do
        @comm_instance.send(:initialize_logger)

        expect(@comm_instance.instance_variable_get(:@logger)).to be(logger)
      end

      it 'sets log level' do
        expect(logger).to receive(:level=)

        @comm_instance.send(:initialize_logger)
      end
    end

    describe 'print_log' do
      before(:each) do
        allow(@comm_instance).to receive(:print_log).and_call_original

        @comm_instance.instance_variable_set(:@logger, logger)
      end

      it 'sends message to the log instance' do
        expect(logger).to receive(:level).with(/\[Instance: \d+\] Message/)

        @comm_instance.send(:print_log, :level, 'Message')
      end
    end
  end
end
