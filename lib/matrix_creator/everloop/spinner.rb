# Load Dependencies
require 'matrix_creator/everloop/animation'

module MatrixCreator
  module Everloop
    ##
    # Spinner animation class
    class Spinner < Animation
      ##
      # Initializes the variables on the instance to prepare for the
      # loop animation
      #
      # @param color [Hash] with the rgb+w values for the color
      # @param code_thread [Thread] instance with main thread
      def initialize(color, code_thread)
        @everloop_comm = MatrixCreator::Comm.new(BASE_PORT)
        @code_thread = code_thread

        # Generating array of led messages
        @led_array = (1..35).map do |i|
          if i <= 5
            MatrixMalos::LedValue.new(
              red: (color[:r] * i * 2) / 10,
              green: (color[:g] * i * 2) / 10,
              blue: (color[:b] * i * 2) / 10,
              white: (color[:w] * i * 2) / 10
            )
          else
            MatrixMalos::LedValue.new(red: 0, green: 0, blue: 0, white: 0)
          end
        end
      end

      ##
      # Loop animation until main code thread finishes
      def loop_animation
        loop do
          everloop_image = MatrixMalos::EverloopImage.new(led: @led_array)
          msg = MatrixMalos::DriverConfig.new(image: everloop_image)
          @everloop_comm.send_configuration(msg)

          sleep(ANIMATION_SPEED)

          break if @code_thread[:finished]

          # Rotate the 5 led instances order in the array
          @led_array.rotate!(-1)
        end
      end
    end
  end
end
