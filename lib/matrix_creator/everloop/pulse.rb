# Load Dependencies
require 'matrix_creator/everloop/animation'

module MatrixCreator
  module Everloop
    ##
    # Pulse animation class
    class Pulse < Animation
      ##
      # Initializes the variables on the instance to prepare for the
      # loop animation
      #
      # @param color [Hash] with the rgb+w values for the color
      # @param code_thread [Thread] instance with main thread
      def initialize(color, code_thread)
        @everloop_comm = MatrixCreator::Comm.new(BASE_PORT)
        @code_thread = code_thread
        @intensity = 0
        @intensity_next_value = 1

        # Generate everloop messages
        @everloop_msgs = (0..10).map do |msg_intensity|
          image = (1..35).map do
            MatrixMalos::LedValue.new(
              red: ((color[:r] / 10) * msg_intensity).round,
              green: ((color[:g] / 10) * msg_intensity).round,
              blue: ((color[:b] / 10) * msg_intensity).round,
              white: ((color[:w] / 10) * msg_intensity).round
            )
          end

          MatrixMalos::DriverConfig.new(
            image: MatrixMalos::EverloopImage.new(led: image)
          )
        end
      end

      ##
      # Loop animation until main code thread finishes
      def loop_animation
        loop do
          @everloop_comm.send_configuration(@everloop_msgs[@intensity])

          @intensity += @intensity_next_value

          # Pulse intensity behavior
          if @intensity == 11
            @intensity = 10
            @intensity_next_value = -1
          elsif @intensity == -1
            @intensity = 0
            @intensity_next_value = 1
          end

          sleep(ANIMATION_SPEED)

          break if @code_thread[:finished]
        end
      end
    end
  end
end
