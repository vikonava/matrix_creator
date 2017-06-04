# Load Dependencies
require 'matrix_creator/driver_base'

module MatrixCreator
  # Module: IMU
  #
  # Communicate with the IMU driver
  module Imu
    # Configuration values for the IMU driver
    IMU_CONFIG = MatrixCreator.settings[:devices][:imu]

    # Base port to send data to IMU driver
    BASE_PORT = IMU_CONFIG[:port]

    ##
    # Detects and returns information from the IMU driver
    #
    # @param options [Hash] of keys and values that can contain speed, max_resp and/or max_secs
    # @return [Array] elements detected in JSON format
    #
    # @example Detect 3 values for the IMU driver
    #   MatrixCreator::Imu.detect(max_resp: 3)
    #
    # @example Detect values for the IMU driver for 30 seconds
    #   MatrixCreator::Imu.detect(max_secs: 30)
    #
    # @example Detect values for the IMU driver with a speed of 0.5 seconds per response
    #   MatrixCreator::Imu.detect(max_secs: 30, speed: 0.5)
    #
    # @example Detect values for the IMU driver for 15 seconds and process data when received
    #   MatrixCreator::Imu.detect(max_resp: 10){ |data|
    #     // Do something with the data
    #   }
    #
    def self.detect(options = {}, &block)
      MatrixCreator::DriverBase.detect(BASE_PORT, MatrixMalos::Imu, options, block)
    end

    ##
    # Detects one response from the IMU driver and returns its value
    #
    # @return [Hash] object with the IMU response values
    #
    def self.detect_once
      detect(max_resp: 1).first
    end
  end
end
