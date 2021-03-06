# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: definitions/protos/vision/vision.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message "admobilize_vision.Point" do
    optional :x, :float, 1
    optional :y, :float, 2
  end
  add_message "admobilize_vision.Rectangle" do
    optional :x, :float, 1
    optional :y, :float, 2
    optional :width, :float, 3
    optional :height, :float, 4
  end
  add_message "admobilize_vision.FacialRecognition" do
    optional :tag, :enum, 1, "admobilize_vision.EnumFacialRecognitionTag"
    optional :confidence, :float, 2
    optional :age, :int32, 3
    optional :gender, :enum, 4, "admobilize_vision.FacialRecognition.Gender"
    optional :emotion, :enum, 5, "admobilize_vision.FacialRecognition.Emotion"
    repeated :face_descriptor, :float, 6
    optional :face_id, :string, 7
    optional :pose_yaw, :float, 8
    optional :pose_roll, :float, 9
    optional :pose_pitch, :float, 10
    optional :basic_feature, :message, 11, "admobilize_vision.FacialRecognition.BasicFaceFeature"
  end
  add_message "admobilize_vision.FacialRecognition.BasicFaceFeature" do
    repeated :mouth, :message, 1, "admobilize_vision.Point"
    repeated :left_eye, :message, 2, "admobilize_vision.Point"
    repeated :right_eye, :message, 3, "admobilize_vision.Point"
    repeated :nose, :message, 4, "admobilize_vision.Point"
  end
  add_enum "admobilize_vision.FacialRecognition.Gender" do
    value :MALE, 0
    value :FEMALE, 1
  end
  add_enum "admobilize_vision.FacialRecognition.Emotion" do
    value :ANGRY, 0
    value :DISGUST, 1
    value :CONFUSED, 2
    value :HAPPY, 3
    value :SAD, 4
    value :SURPRISED, 5
    value :CALM, 6
  end
  add_message "admobilize_vision.VisionEvent" do
    optional :tag, :enum, 1, "admobilize_vision.EventTag"
    optional :tracking_id, :uint64, 2
    optional :session_time, :float, 3
    optional :dwell_time, :float, 4
  end
  add_message "admobilize_vision.RectangularDetection" do
    optional :algorithm, :enum, 1, "admobilize_vision.EnumDetectionAlgorithm"
    optional :location, :message, 2, "admobilize_vision.Rectangle"
    optional :tag, :enum, 3, "admobilize_vision.EnumDetectionTag"
    optional :confidence, :float, 4
    repeated :facial_recognition, :message, 5, "admobilize_vision.FacialRecognition"
    optional :image, :bytes, 6
    optional :image_small, :bytes, 7
    optional :tracking_id, :uint64, 8
  end
  add_message "admobilize_vision.ImageList" do
    repeated :image_data, :bytes, 1
    optional :frames_per_second, :int32, 2
  end
  add_message "admobilize_vision.Video" do
    optional :video_data, :bytes, 1
    optional :codec, :enum, 2, "admobilize_vision.EnumVideoCodec"
    repeated :tag, :string, 3
  end
  add_message "admobilize_vision.VisionResult" do
    repeated :rect_detection, :message, 1, "admobilize_vision.RectangularDetection"
    repeated :vision_event, :message, 4, "admobilize_vision.VisionEvent"
    optional :image, :bytes, 2
    optional :image_small, :bytes, 3
  end
  add_enum "admobilize_vision.EnumFacialRecognitionTag" do
    value :AGE, 0
    value :EMOTION, 1
    value :GENDER, 2
    value :FACE_ID, 3
    value :HEAD_POSE, 4
    value :FACE_FEATURES, 5
    value :FACE_DESCRIPTOR, 6
  end
  add_enum "admobilize_vision.EventTag" do
    value :TRACKING_START, 0
    value :TRACKING_END, 1
  end
  add_enum "admobilize_vision.EnumDetectionTag" do
    value :FACE, 0
    value :HAND_THUMB, 1
    value :HAND_PALM, 2
    value :HAND_PINCH, 3
    value :HAND_FIST, 4
    value :PERSON, 5
  end
  add_enum "admobilize_vision.EnumDetectionAlgorithm" do
    value :DEFAULT, 0
    value :FIRST_ALTERNATIVE, 1
  end
  add_enum "admobilize_vision.EnumVideoCodec" do
    value :UNDEFINED_VIDEO_CODEC, 0
    value :H264, 1
    value :MP4V, 2
    value :RV24, 3
    value :VP8, 4
    value :VP9, 5
  end
end

module AdmobilizeVision
  Point = Google::Protobuf::DescriptorPool.generated_pool.lookup("admobilize_vision.Point").msgclass
  Rectangle = Google::Protobuf::DescriptorPool.generated_pool.lookup("admobilize_vision.Rectangle").msgclass
  FacialRecognition = Google::Protobuf::DescriptorPool.generated_pool.lookup("admobilize_vision.FacialRecognition").msgclass
  FacialRecognition::BasicFaceFeature = Google::Protobuf::DescriptorPool.generated_pool.lookup("admobilize_vision.FacialRecognition.BasicFaceFeature").msgclass
  FacialRecognition::Gender = Google::Protobuf::DescriptorPool.generated_pool.lookup("admobilize_vision.FacialRecognition.Gender").enummodule
  FacialRecognition::Emotion = Google::Protobuf::DescriptorPool.generated_pool.lookup("admobilize_vision.FacialRecognition.Emotion").enummodule
  VisionEvent = Google::Protobuf::DescriptorPool.generated_pool.lookup("admobilize_vision.VisionEvent").msgclass
  RectangularDetection = Google::Protobuf::DescriptorPool.generated_pool.lookup("admobilize_vision.RectangularDetection").msgclass
  ImageList = Google::Protobuf::DescriptorPool.generated_pool.lookup("admobilize_vision.ImageList").msgclass
  Video = Google::Protobuf::DescriptorPool.generated_pool.lookup("admobilize_vision.Video").msgclass
  VisionResult = Google::Protobuf::DescriptorPool.generated_pool.lookup("admobilize_vision.VisionResult").msgclass
  EnumFacialRecognitionTag = Google::Protobuf::DescriptorPool.generated_pool.lookup("admobilize_vision.EnumFacialRecognitionTag").enummodule
  EventTag = Google::Protobuf::DescriptorPool.generated_pool.lookup("admobilize_vision.EventTag").enummodule
  EnumDetectionTag = Google::Protobuf::DescriptorPool.generated_pool.lookup("admobilize_vision.EnumDetectionTag").enummodule
  EnumDetectionAlgorithm = Google::Protobuf::DescriptorPool.generated_pool.lookup("admobilize_vision.EnumDetectionAlgorithm").enummodule
  EnumVideoCodec = Google::Protobuf::DescriptorPool.generated_pool.lookup("admobilize_vision.EnumVideoCodec").enummodule
end
