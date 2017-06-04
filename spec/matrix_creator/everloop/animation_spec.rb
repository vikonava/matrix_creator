require 'spec_helper'

RSpec.describe MatrixCreator::Everloop::Animation do
  let(:animation_instance) { MatrixCreator::Everloop::Animation.new }

  describe 'self.run' do
    let(:code_block) { double('CodeBlock') }
    let(:mock_result) { double('CodeBlock::Result') }
    let(:mock_proc) { Proc.new{ code_block.call } }

    before(:each) do
      allow(MatrixCreator::Everloop::Animation).to receive(:new).and_return(animation_instance)
      allow(animation_instance).to receive(:loop_animation)
      allow(animation_instance).to receive(:destroy_context)
      allow(code_block).to receive(:call).and_return(mock_result)
    end

    it 'runs block sent as a parameter if specified' do
      expect(code_block).to receive(:call)

      MatrixCreator::Everloop::Animation.run(&mock_proc)
    end

    it 'creates a new animation instance' do
      expect(MatrixCreator::Everloop::Animation).to receive(:new).and_return(animation_instance)

      MatrixCreator::Everloop::Animation.run
    end

    it 'starts loop for the animation instance' do
      expect(animation_instance).to receive(:loop_animation)

      MatrixCreator::Everloop::Animation.run
    end

    it 'destroys context of the animation instance' do
      expect(animation_instance).to receive(:destroy_context)

      MatrixCreator::Everloop::Animation.run
    end

    it 'turns off leds of the everloop after animation ends' do
      color_off = { r:0, g:0, b:0, w:0 }
      expect(MatrixCreator::Everloop).to receive(:modify_color).with(color_off)

      MatrixCreator::Everloop::Animation.run
    end

    it 'returns result from the code of block' do
      result = MatrixCreator::Everloop::Animation.run(&mock_proc)

      expect(result).to be(mock_result)
    end
  end

  describe 'destroy_context' do
    let(:comm_instance) { double('MatrixCreator::Comm.instance') }

    before(:each) do
      animation_instance.instance_variable_set(:@everloop_comm, comm_instance)
    end

    it 'destroys comm instance context' do
      expect(comm_instance).to receive(:destroy)

      animation_instance.destroy_context
    end
  end
end

