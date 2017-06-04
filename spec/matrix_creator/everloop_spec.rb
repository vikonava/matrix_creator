require 'spec_helper'

RSpec.describe MatrixCreator::Everloop do
  simulate_malos_everloop

  let(:color) { { r: 1, g: 2, b: 3, w: 4 } }
  let(:comm_instance) { double('MatrixCreator::Comm.instance') }

  before(:each) do
    allow(MatrixCreator::Comm).to receive(:new).and_return(comm_instance)
    allow(comm_instance).to receive(:send_configuration)
    allow(comm_instance).to receive(:destroy)
  end

  describe 'self.modify_color' do
    it 'creates MatrixCreator::Comm instance with everloop port' do
      expect(MatrixCreator::Comm).to receive(:new).with(20021)

      MatrixCreator::Everloop.modify_color(color)
    end

    it 'generates MatrixMalos::EverloopImage with 35 images' do
      mock_color = { red: 1, green: 2, blue: 3, white: 4 }
      expect(led_value).to receive(:new).with(mock_color).exactly(35).times
      
      MatrixCreator::Everloop.modify_color(color)
    end

    it 'sends configuration to the driver comm instance' do
      mock_color = { red: 1, green: 2, blue: 3, white: 4 }
      mock_led_value = double('MatrixCreator::LedValue.mock')
      mock_led_array = (1..35).map{ mock_led_value }
      mock_everloop_image = double('MatrixCreator::EverloopImage.mock')
      mock_driver_config = double('MatrixCreator::DriverConfig.mock')

      expect(led_value).to receive(:new).with(mock_color).exactly(35).times.and_return(mock_led_value)
      expect(everloop_image).to receive(:new).with(led: mock_led_array).and_return(mock_everloop_image)
      expect(driver_config).to receive(:new).with(image: mock_everloop_image).and_return(mock_driver_config)

      expect(comm_instance).to receive(:send_configuration).with(mock_driver_config)

      MatrixCreator::Everloop.modify_color(color)
    end

    it 'destroys everloop comm instance' do
      expect(comm_instance).to receive(:destroy)

      MatrixCreator::Everloop.modify_color(color)
    end
  end
end
