require 'spec_helper'

RSpec.describe MatrixCreator::Imu do
  describe 'self.detect' do
    it 'performs detect call to DriverBase' do
      expect(MatrixCreator::DriverBase).to receive(:detect)

      MatrixCreator::Imu.detect
    end

    it 'sends the right port for IMU' do
      expect(MatrixCreator::DriverBase).to receive(:detect).with(20013, anything, {}, nil)

      MatrixCreator::Imu.detect
    end

    it 'sends the right decoder for IMU' do
      expect(MatrixCreator::DriverBase).to receive(:detect).with(anything, MatrixMalos::Imu, {}, nil)

      MatrixCreator::Imu.detect
    end

    it 'passes a block of code if available' do
      expect(MatrixCreator::DriverBase).to receive(:detect).with(anything, anything, {}, anything)

      MatrixCreator::Imu.detect{ Proc.new }
    end

    it 'returns detect response' do
      mock_result = double('MatrixCreator::DriverBase.detect.result')
      allow(MatrixCreator::DriverBase).to receive(:detect).and_return(mock_result)

      expect(MatrixCreator::Imu.detect). to be(mock_result)
    end
  end

  describe 'self.detect_once' do
    let(:response_obj) { double('MatrixCreator::Comm.resp_obj') }
    let(:mock_result) { [response_obj] }

    before(:each) do
      allow(MatrixCreator::Imu).to receive(:detect).and_return(mock_result)
    end

    it 'sends detect with max response of 1' do
      expect(MatrixCreator::Imu).to receive(:detect).with(max_resp: 1)

      MatrixCreator::Imu.detect_once
    end

    it 'returns one object from the array' do
      expect(MatrixCreator::Imu).to receive(:detect).with(max_resp: 1)

      expect(MatrixCreator::Imu.detect_once).to eq(response_obj)
    end
  end
end
