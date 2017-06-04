# Load Dependencies
require 'matrix_creator/driver_base'

module MatrixCreator
  # Module: Pressure
  #
  # Communicate with the Pressure driver
  module Pressure
    # Configuration values for the Pressure driver
    PRESSURE_CONFIG = MatrixCreator.settings[:devices][:pressure]

    # Base port to send data to Pressure driver
    BASE_PORT = PRESSURE_CONFIG[:port]

    ##
    # Detects and returns information from the Pressure driver
    #
    # @param options [Hash] of keys and values that can contain speed, max_resp and/or max_secs
    # @return [Array] elements detected in JSON format
    #
    # @example Detect 3 values for the Pressure driver
    #   MatrixCreator::Pressure.detect(max_resp: 3)
    #
    # @example Detect values for the Pressure driver for 30 seconds
    #   MatrixCreator::Pressure.detect(max_secs: 30)
    #
    # @example Detect values for the Pressure driver with a speed of 0.5 seconds per response
    #   MatrixCreator::Pressure.detect(max_secs: 30, speed: 0.5)
    #
    # @example Detect values for the Pressure driver for 15 seconds and process data when received
    #   MatrixCreator::Pressure.detect(max_resp: 10){ |data|
    #     // Do something with the data
    #   }
    #
    def self.detect(options = {}, &block)
      MatrixCreator::DriverBase.detect(BASE_PORT, MatrixMalos::Pressure, options, block)
    end

    ##
    # Detects one response from the Pressure driver and returns its value
    #
    # @return [Hash] object with the Pressure response values
    #
    def self.detect_once
      detect(max_resp: 1).first
    end
  end
end
