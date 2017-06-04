# Load Protos
require 'protos/malos/driver_pb'
require 'protos/vision/vision_pb'

# Load Dependencies
require 'matrix_creator/comm'

module MatrixCreator
  # Module: Vision
  #
  # Communicate with the vision driver
  module Vision
    # Configuration values for the Vision driver
    VISION_CONFIG = MatrixCreator.settings[:devices][:vision]

    # Base port to send data to Vision driver
    BASE_PORT = VISION_CONFIG[:port]

    # Camera width value
    CAMERA_WIDTH = 1280

    # Camera height value
    CAMERA_HEIGHT = 720

    ##
    # Detect a list of objects that are on detected by the camera, specifying
    # the amount of max responses or max seconds to detect elements on camera
    #
    # @param objects [Array] of MatrixMalos::EnumMalosEyeDetectionType
    # @param options [Hash] of keys and values that can contain max_resp and/or max_secs
    # @return [Array] elements detected in JSON format
    #
    # @example Detect thumbs up for ten ocurrances
    #   thumbs_up = MatrixMalos::EnumMalosEyeDetectionType::HAND_THUMB_UP
    #   MatrixMalos::Vision.detect_objects(thumbs_up, max_resp: 10)
    #
    # @example Detect face and palms for 30 seconds
    #   objects = [
    #     MatrixMalos::EnumMalosEyeDetectionType::HAND_PALM,
    #     MatrixMalos::EnumMalosEyeDetectionType::FACE
    #   ]
    #   MatrixCreator::Vision.detect_objects(objects, max_secs: 30)
    #
    # @example Detect face for 10 seconds and process data on each occurance when received
    #   objects = [MatrixMalos::EnumMalosEyeDetectionType::FACE]
    #   MatrixCreator::Vision.detect_objects(objects, max_secs: 10) { |data|
    #     // Do something with data
    #   }
    #
    def self.detect_objects(objects, options = {}, &block)
      @vision_comm = MatrixCreator::Comm.new(BASE_PORT)

      # Setup MalosEye configuration
      malos_eye_config = MatrixMalos::MalosEyeConfig.new(
        camera_config: MatrixMalos::CameraConfig.new(
          camera_id: 0,
          width: CAMERA_WIDTH,
          height: CAMERA_HEIGHT
        )
      )

      # Generate driver configuration
      config = MatrixMalos::DriverConfig.new(
        malos_eye_config: malos_eye_config,
        delay_between_updates: 0.1,
        timeout_after_last_ping: 4
      )
      @vision_comm.send_configuration(config)

      # Setup objects to detect
      malos_eye_config = MatrixMalos::MalosEyeConfig.new
      objects.each do |object|
        malos_eye_config.object_to_detect.push(object)
      end
      config = MatrixMalos::DriverConfig.new(
        malos_eye_config: malos_eye_config
      )
      @vision_comm.send_configuration(config)

      # Query Demographics
      result = @vision_comm.perform(AdmobilizeVision::VisionResult, options, block)

      # Stop capturing events
      malos_eye_config = MatrixMalos::MalosEyeConfig.new
      malos_eye_config.object_to_detect.push(MatrixMalos::EnumMalosEyeDetectionType::STOP)
      config = MatrixMalos::DriverConfig.new(malos_eye_config: malos_eye_config)
      @vision_comm.send_configuration(config)

      # Destroy context
      @vision_comm.destroy

      result
    end

    ##
    # Detects an object once
    #
    # @example
    #   object = MatrixMalos::EnumMalosEyeDetectionType::HAND_FIST
    #   MatrixCreator::Vision.detect_once(object)
    #
    def self.detect_once(object)
      result = nil

      # Loop until recDetection is returned
      loop do
        result = detect_objects([object], max_resp: 1).first
        break unless result[:rectDetection].empty?
      end

      result
    end

    ##
    # Detect one face message
    #
    # @example
    #   MatrixCreator::Vision.detect_face
    #
    def self.detect_face
      detect_once(MatrixMalos::EnumMalosEyeDetectionType::FACE)
    end

    ##
    # Detect demographics of a face
    #
    # @example
    #   MatrixCreator::Vision.detect_demographics
    #
    def self.detect_demographics
      detect_once(MatrixMalos::EnumMalosEyeDetectionType::FACE_DEMOGRAPHICS)
    end

    ##
    # Detect a thumbs up
    #
    # @example
    #   MatrixCreator::Vision.detect_thumbs_up
    #
    def self.detect_thumb_up
      detect_once(MatrixMalos::EnumMalosEyeDetectionType::HAND_THUMB_UP)
    end

    ##
    # Detect a palm
    #
    # @example
    #   MatrixCreator::Vision.detect_palm
    #
    def self.detect_palm
      detect_once(MatrixMalos::EnumMalosEyeDetectionType::HAND_PALM)
    end

    ##
    # Detect a pinch
    #
    # @example
    #   MatrixCreator::Vision.detect_pinch
    #
    def self.detect_pinch
      detect_once(MatrixMalos::EnumMalosEyeDetectionType::HAND_PINCH)
    end

    ##
    # Detect a fist
    #
    # @example
    #   MatrixCreator::Vision.detect_fist
    #
    def self.detect_fist
      detect_once(MatrixMalos::EnumMalosEyeDetectionType::HAND_FIST)
    end
  end
end
