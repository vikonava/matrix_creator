# Load Dependencies
require 'matrix_creator/driver_base'

module MatrixCreator
  # Module: Humidity
  #
  # Communicate with the Humidity driver
  module Humidity
    # Configuration values for the Humidity driver
    HUMIDITY_CONFIG = MatrixCreator.settings[:devices][:humidity]

    # Base port to send data to Humidity driver
    BASE_PORT = HUMIDITY_CONFIG[:port]

    ##
    # Detects and returns information from the Humidity driver
    #
    # @param options [Hash] of keys and values that can contain speed, max_resp and/or max_secs
    # @return [Array] elements detected in JSON format
    #
    # @example Detect 3 values for the Humidity driver
    #   MatrixCreator::Humidity.detect(max_resp: 3)
    #
    # @example Detect values for the Humidity driver for 30 seconds
    #   MatrixCreator::Humidity.detect(max_secs: 30)
    #
    # @example Detect values for the Humidity driver with a speed of 0.5 seconds per response
    #   MatrixCreator::Humidity.detect(max_secs: 30, speed: 0.5)
    #
    # @example Detect values for the Humidity driver for 15 seconds and process data when received
    #   MatrixCreator::Humidity.detect(max_resp: 10){ |data|
    #     // Do something with the data
    #   }
    #
    def self.detect(options = {}, &block)
      MatrixCreator::DriverBase.detect(BASE_PORT, MatrixMalos::Humidity, options, block)
    end

    ##
    # Detects one response from the Humidity driver and returns its value
    #
    # @return [Hash] object with the Humidity response values
    #
    def self.detect_once
      detect(max_resp: 1).first
    end
  end
end
