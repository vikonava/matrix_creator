require 'spec_helper'

RSpec.describe MatrixCreator::Everloop::Pulse do
  let(:comm_instance) { double('MatrixCreator::Comm.instance') }
  let(:color) { { r:10, g:20, b:30, w:40 } }
  let(:code_thread) { double('Thread::MainCode') }

  before(:each) do |example|
    allow(MatrixCreator::Comm).to receive(:new).and_return(comm_instance)
    stub_const('MatrixCreator::Everloop::Animation::ANIMATION_SPEED', 0)

    unless example.metadata[:skip_pulse_instance]
      @pulse_instance = MatrixCreator::Everloop::Pulse.new(color, code_thread)
    end
  end

  describe 'initialize' do
    simulate_malos_everloop

    it 'assigns a comm instance into an instance variable' do
      expect(@pulse_instance.instance_variable_get(:@everloop_comm)).to eq(comm_instance)
    end

    it 'stores main thread into code_thread instance variable' do
      expect(@pulse_instance.instance_variable_get(:@code_thread)).to eq(code_thread)
    end

    it 'initializes stating intensity' do
      expect(@pulse_instance.instance_variable_get(:@intensity)).to eq(0)
    end

    it 'initializes starting intensity next value to be increasing' do
      expect(@pulse_instance.instance_variable_get(:@intensity_next_value)).to eq(1)
    end

    it 'initializes intensity messages', skip_pulse_instance: true do
      mock_led_value_instance = double('MatrixMalos::LedValue.instance')
      mock_led_array = (1..35).map{ mock_led_value_instance }
      mock_everloop_image_instance = double('MatrixMalos::EverloopImage.instance')
      mock_driver_config_instance = double('MatrixMalos::DriverConfig.instance')

      (0..10).map do |mock_intensity|
        mock_color = {
          red: 1 * mock_intensity,
          green: 2 * mock_intensity,
          blue: 3 * mock_intensity,
          white: 4 * mock_intensity
        }
        expect(led_value).to receive(:new).with(mock_color).exactly(35).times.and_return(mock_led_value_instance)
      end

      expect(everloop_image).to receive(:new).with(led: mock_led_array).and_return(mock_everloop_image_instance)
      expect(driver_config).to receive(:new).with(image: mock_everloop_image_instance).and_return(mock_driver_config_instance)
      
      MatrixCreator::Everloop::Pulse.new(color, code_thread)
    end
  end

  describe 'loop_animation' do
    let(:everloop_msgs) {
      (0..10).map do |intensity|
        double("MatrixMalos::DriverConfig::MSG(#{intensity})")
      end
    }

    before(:each) do
      @pulse_instance.instance_variable_set(:@everloop_msgs, everloop_msgs)

      allow(comm_instance).to receive(:send_configuration)
    end

    it 'exits loop after main thread is finished' do
      # Returns true after second loop
      intensity_count = 0
      allow(code_thread).to receive(:[]).with(:finished) do
        intensity_count += 1
        intensity_count <= 2 ? false : true
      end

      @pulse_instance.loop_animation

      expect(intensity_count).to eq(3)
    end

    context 'for first intensity' do
      before(:each) do
        allow(code_thread).to receive(:[]).with(:finished).and_return(true)
      end

      it 'sends first configuration intensity' do
        expect(comm_instance).to receive(:send_configuration).with(everloop_msgs.first).once

        @pulse_instance.loop_animation
      end

      it 'increases intensity by 1' do
        @pulse_instance.loop_animation

        expect(@pulse_instance.instance_variable_get(:@intensity)).to eq(1)
      end
    end

    context 'when increasing intensity to 10' do
      it 'changes intensity value to decrease' do
        # Returns true after second loop
        intensity_count = 0
        allow(code_thread).to receive(:[]).with(:finished) do
          intensity_count += 1

          intensity_count <= 10 ? false : true
        end

        @pulse_instance.loop_animation

        expect(@pulse_instance.instance_variable_get(:@intensity_next_value)).to eq(-1)
      end
    end

    context 'after increasing intensity by 10' do
      it 'sends configuration intensity to be 9' do
        # Returns true after second loop
        intensity_count = 0
        allow(code_thread).to receive(:[]).with(:finished) do
          intensity_count += 1

          intensity_count <= 12 ? false : true
        end

        expect(comm_instance).to receive(:send_configuration).with(everloop_msgs[9]).twice

        @pulse_instance.loop_animation
      end
    end

    context 'during a whole loop' do
      it 'sends configuration for all increasing and decreasing intensities' do
        intensity_count = 0
        allow(code_thread).to receive(:[]).with(:finished) do
          intensity_count += 1
          intensity_count <= 21 ? false : true
        end

        (0..10).each do |intensity|
          expect(comm_instance).to receive(:send_configuration).with(everloop_msgs[intensity]).twice
        end

        @pulse_instance.loop_animation
      end
    end

    context 'after a whole loop' do
      it 'restarts intensity value to 0' do
        intensity_count = 0
        allow(code_thread).to receive(:[]).with(:finished) do
          intensity_count += 1
          intensity_count <= 22 ? false : true
        end

        @pulse_instance.loop_animation

        expect(@pulse_instance.instance_variable_get(:@intensity_next_value)).to eq(1)
      end
    end
  end
end
