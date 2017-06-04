require 'spec_helper'

RSpec.describe MatrixCreator::Comm do
  let(:comm_instance) { double('MatrixCreator::Comm.instance') }
  let(:decoder) { double('MatrixMalos::Decoder') }

  describe 'self.detect' do
    simulate_matrix_malos_config

    before(:each) do
      allow(MatrixCreator::Comm).to receive(:new).and_return(comm_instance)
      allow(comm_instance).to receive(:send_configuration)
      allow(comm_instance).to receive(:perform)
      allow(comm_instance).to receive(:destroy)
    end

    it 'generates a comm instance with base port specified' do
      expect(MatrixCreator::Comm).to receive(:new).with(8888)

      MatrixCreator::DriverBase.detect(8888, decoder)
    end

    it 'sets delay between updates as 1 sec when not specified' do
      expect(driver_config).to receive(:new).with(hash_including(delay_between_updates: 1.0))

      MatrixCreator::DriverBase.detect(8888, decoder)
    end

    it 'sets delay between updates according to options value' do
      expect(driver_config).to receive(:new).with(hash_including(delay_between_updates: 0.1))

      MatrixCreator::DriverBase.detect(8888, decoder, speed: 0.1)
    end

    it 'sends configuration to the driver' do
      expect(comm_instance).to receive(:send_configuration).with(driver_config_instance)

      MatrixCreator::DriverBase.detect(8888, decoder)
    end

    it 'calls perform data to the driver with the right params' do
      expect(comm_instance).to receive(:perform).with(decoder, { key: 'value' }, nil)

      MatrixCreator::DriverBase.detect(8888, decoder, { key: 'value' })
    end

    it 'calls perform data to the driver passing the receiving block' do
      block_mock = double('Proc::mock')
      expect(comm_instance).to receive(:perform).with(decoder, {}, block_mock)

      MatrixCreator::DriverBase.detect(8888, decoder, {}, block_mock)
    end

    it 'calls destroy method on the comm instance' do
      expect(comm_instance).to receive(:destroy)

      MatrixCreator::DriverBase.detect(8888, decoder)
    end

    it 'returns result from the comm instance perform method' do
      mock_result = double('MatrixCreator::Comm.perform.result')
      allow(comm_instance).to receive(:perform).and_return(mock_result)

      expect(MatrixCreator::DriverBase.detect(8888, decoder)).to be(mock_result)
    end
  end
end
