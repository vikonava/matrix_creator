require 'spec_helper'

RSpec.describe MatrixCreator::Everloop::Pulse do
  simulate_malos_everloop

  let(:comm_instance) { double('MatrixCreator::Comm.instance') }
  let(:color) { { r:10, g:20, b:30, w:40 } }
  let(:code_thread) { double('Thread::MainCode') }

  before(:each) do |example|
    led_count = 0
    @led_value_array = (1..35).map do
      led_count += 1
      if led_count <= 5
        double("MatrixCreator::LedValue::Intensity(#{led_count*2})")
      else
        double("MatrixCreator::LedValue::Intensity(0)")
      end
    end

    allow(MatrixCreator::Comm).to receive(:new).and_return(comm_instance)
    stub_const('MatrixCreator::Everloop::Animation::ANIMATION_SPEED', 0)

    led_count = -1
    allow(MatrixMalos::LedValue).to receive(:new) do
      led_count += 1
      @led_value_array[led_count]
    end

    @spinner_instance  = MatrixCreator::Everloop::Spinner.new(color, code_thread)
  end

  describe 'initialize' do
    it 'assigns a comm instance into an instance variable' do
      expect(@spinner_instance.instance_variable_get(:@everloop_comm)).to eq(comm_instance)
    end

    it 'stores main thread into code_thread instance variable' do
      expect(@spinner_instance.instance_variable_get(:@code_thread)).to eq(code_thread)
    end

    it 'stores spinner array in led_array instance variable' do
      expect(@spinner_instance.instance_variable_get(:@led_array)).to eq(@led_value_array)
    end
  end

  describe 'loop_animation' do
    before(:each) do
      @spinner_instance.instance_variable_set(:@led_array, @led_value_array)

      allow(comm_instance).to receive(:send_configuration)
    end

    it 'exits loop after main thread is finished' do
      # Returns true after second loop
      rotate_count = 0
      allow(code_thread).to receive(:[]).with(:finished) do
        rotate_count += 1
        rotate_count <= 2 ? false : true
      end

      @spinner_instance.loop_animation

      expect(rotate_count).to eq(3)
    end


    context 'on first request' do
      before(:each) do
        allow(code_thread).to receive(:[]).with(:finished).and_return(true)
      end

      it 'sends configuration for the first 5 leds to be on' do
        expect(everloop_image).to receive(:new).with(led: @led_value_array)

        @spinner_instance.loop_animation
      end

      it 'sleeps for animation before moving to next request' do
        expect(@spinner_instance).to receive(:sleep)

        @spinner_instance.loop_animation
      end
    end

    context 'after first request' do
      it 'rotates led array by one' do
        rotate_count = 0
        allow(code_thread).to receive(:[]).with(:finished) do
          rotate_count += 1
          rotate_count < 2 ? false : true
        end

        expect(@led_value_array).to receive(:rotate!).with(-1)

        @spinner_instance.loop_animation
      end
    end

    context 'at the end of a spin' do
      before(:each) do
        rotate_count = 0
        allow(code_thread).to receive(:[]).with(:finished) do
          rotate_count += 1
          rotate_count < 35 ? false : true
        end
      end

      it 'rotate all combinations' do
        expect(@led_value_array).to receive(:rotate!).exactly(34).times

        @spinner_instance.loop_animation
      end

      it 'sends all configurations' do
        expect(@led_value_array).to receive(:rotate!).exactly(34).times.and_call_original
        expect(everloop_image).to receive(:new).with(led: @led_value_array).exactly(35).times
        expect(comm_instance).to receive(:send_configuration).exactly(35).times

        @spinner_instance.loop_animation
      end

      it 'resets the led_array instance variable' do
        @spinner_instance.loop_animation

        expect(@spinner_instance.instance_variable_get(:@led_array)).to eq(@led_value_array)
      end
    end

    context 'after first spin' do
      it 'sends configuration for the first 5 leds to be on' do
        rotate_count = 0
        allow(code_thread).to receive(:[]).with(:finished) do
          rotate_count += 1
          rotate_count <= 35 ? false : true
        end

        @spinner_instance.loop_animation

        expect(@spinner_instance.instance_variable_get(:@led_array)).to be(@led_value_array)
      end
    end
  end
end
