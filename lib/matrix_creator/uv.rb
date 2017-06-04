# Load Dependencies
require 'matrix_creator/driver_base'

module MatrixCreator
  # Module: UV
  #
  # Communicate with the UV driver
  module Uv
    # Configuration values for the UV driver
    UV_CONFIG = MatrixCreator.settings[:devices][:uv]

    # Base port to send data to UV driver
    BASE_PORT = UV_CONFIG[:port]

    ##
    # Detects and returns information from the UV driver
    #
    # @param options [Hash] of keys and values that can contain speed, max_resp and/or max_secs
    # @return [Array] elements detected in JSON format
    #
    # @example Detect 3 values for the UV driver
    #   MatrixCreator::Uv.detect(max_resp: 3)
    #
    # @example Detect values for the UV driver for 30 seconds
    #   MatrixCreator::Uv.detect(max_secs: 30)
    #
    # @example Detect values for the UV driver with a speed of 0.5 seconds per response
    #   MatrixCreator::Uv.detect(max_secs: 30, speed: 0.5)
    #
    # @example Detect values for the UV driver for 15 seconds and process data when received
    #   MatrixCreator::Uv.detect(max_resp: 10){ |data|
    #     // Do something with the data
    #   }
    #
    def self.detect(options = {}, &block)
      MatrixCreator::DriverBase.detect(BASE_PORT, MatrixMalos::UV, options, block)
    end

    ##
    # Detects one response from the UV driver and returns its value
    #
    # @return [Hash] object with the UV response values
    #
    def self.detect_once
      detect(max_resp: 1).first
    end
  end
end
