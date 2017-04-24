module MatrixCreator
  module Everloop
    ##
    # Class to be inherited by Animations
    class Animation
      # Interval between animation updates in milliseconds
      ANIMATION_SPEED = 0.1 # 100ms

      ##
      # Run a block of code while displaying an animation on the Everloop driver
      #
      # @param color [Hash] with the rgb+w values for the color
      # @yield Block of code to be executed while displaying the spinner
      # @return response from the block of code execution
      #
      # @example Run a block of code and display a spinner until it finishes
      #
      #   MatrixCreator::Everloop::Spinner.run {
      #     // Do Something
      #   }
      #
      # @example Run a block of code and display a green spinner until it finishes
      #
      #   color = MatrixCreator::Everloop::Color::GREEN
      #
      #   MatrixCreator::Everloop::Spinner.run(color) {
      #     // Do Something
      #   }
      #
      # @example Run a block of code and display a pulse until it finishes
      #
      #   MatrixCreator::Everloop::Pulse.run {
      #     // Do Something
      #   }
      #
      def self.run(color = Color::WHITE, &block)
        result = nil

        code_thread = Thread.new do
          Thread.current[:finished] = false
          result = yield if block
          Thread.current[:finished] = true
        end

        animation_thread = Thread.new do
          animation = new(color, code_thread)
          animation.loop_animation
          animation.destroy_context
        end

        # Turn off the leds on the Everloop driver
        code_thread.join
        animation_thread.join
        Everloop.modify_color(Color::OFF)

        # Return result of the code block
        result
      end

      ##
      # Sends a request to destroy the context of the everloop comm instance
      def destroy_context
        @everloop_comm.destroy
      end
    end
  end
end
