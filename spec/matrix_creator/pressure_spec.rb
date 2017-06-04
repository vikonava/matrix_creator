require 'spec_helper'

RSpec.describe MatrixCreator::Pressure do
  describe 'self.detect' do
    it 'performs detect call to DriverBase' do
      expect(MatrixCreator::DriverBase).to receive(:detect)

      MatrixCreator::Pressure.detect
    end

    it 'sends the right port for Pressure' do
      expect(MatrixCreator::DriverBase).to receive(:detect).with(20025, anything, {}, nil)

      MatrixCreator::Pressure.detect
    end

    it 'sends the right decoder for Pressure' do
      expect(MatrixCreator::DriverBase).to receive(:detect).with(anything, MatrixMalos::Pressure, {}, nil)

      MatrixCreator::Pressure.detect
    end

    it 'passes a block of code if available' do
      expect(MatrixCreator::DriverBase).to receive(:detect).with(anything, anything, {}, anything)

      MatrixCreator::Pressure.detect{ Proc.new }
    end

    it 'returns detect response' do
      mock_result = double('MatrixCreator::DriverBase.detect.result')
      allow(MatrixCreator::DriverBase).to receive(:detect).and_return(mock_result)

      expect(MatrixCreator::Pressure.detect). to be(mock_result)
    end
  end

  describe 'self.detect_once' do
    let(:response_obj) { double('MatrixCreator::Comm.resp_obj') }
    let(:mock_result) { [response_obj] }

    before(:each) do
      allow(MatrixCreator::Pressure).to receive(:detect).and_return(mock_result)
    end

    it 'sends detect with max response of 1' do
      expect(MatrixCreator::Pressure).to receive(:detect).with(max_resp: 1)

      MatrixCreator::Pressure.detect_once
    end

    it 'returns one object from the array' do
      expect(MatrixCreator::Pressure).to receive(:detect).with(max_resp: 1)

      expect(MatrixCreator::Pressure.detect_once).to eq(response_obj)
    end
  end
end
