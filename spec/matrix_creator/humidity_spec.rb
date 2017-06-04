require 'spec_helper'

RSpec.describe MatrixCreator::Humidity do
  describe 'self.detect' do
    it 'performs detect call to DriverBase' do
      expect(MatrixCreator::DriverBase).to receive(:detect)

      MatrixCreator::Humidity.detect
    end

    it 'sends the right port for Humidity' do
      expect(MatrixCreator::DriverBase).to receive(:detect).with(20017, anything, {}, nil)

      MatrixCreator::Humidity.detect
    end

    it 'sends the right decoder for Humidity' do
      expect(MatrixCreator::DriverBase).to receive(:detect).with(anything, MatrixMalos::Humidity, {}, nil)

      MatrixCreator::Humidity.detect
    end

    it 'passes a block of code if available' do
      expect(MatrixCreator::DriverBase).to receive(:detect).with(anything, anything, {}, anything)

      MatrixCreator::Humidity.detect{ Proc.new }
    end

    it 'returns detect response' do
      mock_result = double('MatrixCreator::DriverBase.detect.result')
      allow(MatrixCreator::DriverBase).to receive(:detect).and_return(mock_result)

      expect(MatrixCreator::Humidity.detect). to be(mock_result)
    end
  end

  describe 'self.detect_once' do
    let(:response_obj) { double('MatrixCreator::Comm.resp_obj') }
    let(:mock_result) { [response_obj] }

    before(:each) do
      allow(MatrixCreator::Humidity).to receive(:detect).and_return(mock_result)
    end

    it 'sends detect with max response of 1' do
      expect(MatrixCreator::Humidity).to receive(:detect).with(max_resp: 1)

      MatrixCreator::Humidity.detect_once
    end

    it 'returns one object from the array' do
      expect(MatrixCreator::Humidity).to receive(:detect).with(max_resp: 1)

      expect(MatrixCreator::Humidity.detect_once).to eq(response_obj)
    end
  end
end
