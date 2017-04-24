# Load Protos
require 'protos/malos/driver_pb'

# Load Dependencies
require 'matrix_creator/comm'
require 'matrix_creator/everloop/color'
require 'matrix_creator/everloop/spinner'
require 'matrix_creator/everloop/pulse'

module MatrixCreator
  # Module: Everloop
  #
  # Communicate with the Everloop driver
  module Everloop
    # Configuration values for the Everloop driver
    EVERLOOP_CONFIG = MatrixCreator.settings[:devices][:everloop]

    # Base port to send data to Everloop driver
    BASE_PORT = EVERLOOP_CONFIG[:port]

    ##
    # Change the color of all of the Leds on the Everloop driver
    #
    # @param color [Hash] with the rgb+w values for the color
    #
    # @example Change leds using predetermined color
    #   MatrixCreator::Everloop.modify_color(MatrixCreator::Everloop::Color::GREEN)
    #
    # @example Change leds using custom
    #   MatrixCreator::Everloop.modify_color({ r: 5, g: 3, b: 9, w: 0 })
    #
    def self.modify_color(color)
      everloop_comm = MatrixCreator::Comm.new(BASE_PORT)

      # Generate 35 instances of LedValue with the same color
      image = (1..35).map do
        MatrixMalos::LedValue.new(red: color[:r], green: color[:g],
                                  blue: color[:b], white: color[:w])
      end

      everloop_image = MatrixMalos::EverloopImage.new(led: image)
      msg = MatrixMalos::DriverConfig.new(image: everloop_image)
      everloop_comm.send_configuration(msg)

      everloop_comm.destroy
    end
  end
end
