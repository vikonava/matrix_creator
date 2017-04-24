require 'spec_helper'

RSpec.describe MatrixCreator::Vision do
  let(:objects) {
    [ double('MatrixMalos::EnumMalosEyeDetectionType::OBJ') ]
  }

  describe 'self.detect_objects' do
    simulate_matrix_malos_config

    let(:vision_port) { 22013 }
    let(:comm_instance) { double('MatrixCreator::Comm') }

    before(:each) do
      allow(MatrixCreator::Comm).to receive(:new).and_return(comm_instance)
      allow(comm_instance).to receive(:send_configuration)
      allow(comm_instance).to receive(:perform)
      allow(comm_instance).to receive(:destroy)
    end

    it 'initializes a vision comm instance' do
      expect(MatrixCreator::Comm).to receive(:new).with(vision_port)

      MatrixCreator::Vision.detect_objects(objects)
    end

    it 'pushes objects for camera to detect into the MalosEyeConfig' do
      objects.each do |object|
        expect(malos_eye_obj_attr).to receive(:push).with(object)
      end

      MatrixCreator::Vision.detect_objects(objects)
    end

    it 'sends MatrixMalos config to the vision driver' do
      camera_setup = double('CameraConfig::Setup')
      malos_eye_setup = double('MalosEyeConfig::Setup')
      allow(malos_eye_setup).to receive(:object_to_detect).and_return(malos_eye_obj_attr)
      driver_setup = double('DriverConfig::Setup')

      expect(camera_config).to receive(:new).with(hash_including(camera_id: 0)).and_return(camera_setup)
      expect(malos_eye_config).to receive(:new).with(camera_config: camera_setup).and_return(malos_eye_setup)
      expect(driver_config).to receive(:new).with(hash_including(malos_eye_config: malos_eye_setup)).and_return(driver_setup)

      # Expect Detection Setup to be sent
      expect(comm_instance).to receive(:send_configuration).with(driver_setup)

      MatrixCreator::Vision.detect_objects(objects)
    end

    it 'retrieves data detected from the vision comm instance' do
      stub_const('AdmobilizeVision::VisionResult', vision_result)

      expect(comm_instance).to receive(:perform).with(vision_result, {})
      
      MatrixCreator::Vision.detect_objects(objects)
    end

    it 'retrieves data detected with max seconds limit' do
      stub_const('AdmobilizeVision::VisionResult', vision_result)

      expect(comm_instance).to receive(:perform).with(vision_result, max_secs: 10)
      
      MatrixCreator::Vision.detect_objects(objects, max_secs: 10)
    end

    it 'retrieves data detected with max responses limit' do
      stub_const('AdmobilizeVision::VisionResult', vision_result)

      expect(comm_instance).to receive(:perform).with(vision_result, max_resp: 10)
      
      MatrixCreator::Vision.detect_objects(objects, max_resp: 10)
    end

    it 'retrieves data detected with max seconds and max responses limit' do
      stub_const('AdmobilizeVision::VisionResult', vision_result)

      expect(comm_instance).to receive(:perform).with(vision_result, max_secs: 30, max_resp: 10)
      
      MatrixCreator::Vision.detect_objects(objects, max_secs: 30, max_resp: 10)
    end

    it 'stops capturing events when enough data has been received by the driver' do
      malos_eye_setup = double('MalosEyeConfig::Setup')
      driver_setup = double('DriverConfig::Setup')

      expect(malos_eye_config).to receive(:new).with(no_args).and_return(malos_eye_setup)
      expect(malos_eye_setup).to receive(:object_to_detect).and_return(malos_eye_obj_attr)
      expect(driver_config).to receive(:new).with(hash_including(malos_eye_config: malos_eye_setup)).and_return(driver_setup)

      # Expect Detection Stop to be sent
      expect(malos_eye_obj_attr).to receive(:push).with(0)
      expect(comm_instance).to receive(:send_configuration).with(driver_setup)

      MatrixCreator::Vision.detect_objects(objects)
    end

    it 'destroys vision comm context when finishing' do
      expect(comm_instance).to receive(:destroy)

      MatrixCreator::Vision.detect_objects(objects)
    end

    it 'returns data detected' do
      results = double('MatrixCreator::Comm.instance.result')

      allow(comm_instance).to receive(:perform).and_return(results)

      vision = MatrixCreator::Vision.detect_objects(objects)
      expect(vision).to eq(results)
    end
  end

  describe 'self.detect_once' do
    let(:object) { objects.first }
    let(:result) { [{ rectDetection: ['value'] }] }

    before(:each) do |example|
      unless example.metadata[:skip_detect_objects]
        allow(MatrixCreator::Vision).to receive(:detect_objects).and_return(result)
      end
    end

    it 'sends request to detect the object param' do
      expect(MatrixCreator::Vision).to receive(:detect_objects).with([object], anything)

      detection = MatrixCreator::Vision.detect_once(object)
    end

    it 'sends request to detect one response only' do
      expect(MatrixCreator::Vision).to receive(:detect_objects).with(anything, max_resp: 1)

      detection = MatrixCreator::Vision.detect_once(object)
    end

    it 'returns result from the detection' do
      detection = MatrixCreator::Vision.detect_once(object)

      expect(detection).to eq(result.first)
    end

    it 'loops until recDetection attribute is returned', skip_detect_objects: true do
      detection_count = 0

      expect(MatrixCreator::Vision).to receive(:detect_objects).at_least(:twice) do
        detection_count += 1

        if detection_count > 2
          result
        else
          [{ rectDetection: [] }]
        end
      end

      MatrixCreator::Vision.detect_once(object)

      expect(detection_count).to be > 2
    end
  end

  context 'helpers to detect a specific object once' do
    let(:detect_once_result) { double('MatrixCreator::Vision.detect_once.result') }

    before(:each) do
      allow(MatrixCreator::Vision).to receive(:detect_once).and_return(detect_once_result)
    end

    describe 'self.detect_face' do
      it 'detects face once' do
        malos_eye_detection_type = double('EnumMalosEyeDetectionType::FACE')
        stub_const('MatrixMalos::EnumMalosEyeDetectionType::FACE', malos_eye_detection_type)

        expect(MatrixCreator::Vision).to receive(:detect_once).with(malos_eye_detection_type)

        MatrixCreator::Vision.detect_face
      end

      it 'returns result from detect_once' do
        result = MatrixCreator::Vision.detect_face

        expect(result).to be(detect_once_result)
      end
    end

    describe 'self.detect_demographics' do
      it 'detects demographics once' do
        malos_eye_detection_type = double('EnumMalosEyeDetectionType::FACE_DEMOGRAPHICS')
        stub_const('MatrixMalos::EnumMalosEyeDetectionType::FACE_DEMOGRAPHICS', malos_eye_detection_type)

        expect(MatrixCreator::Vision).to receive(:detect_once).with(malos_eye_detection_type)

        MatrixCreator::Vision.detect_demographics
      end

      it 'returns result from detect_once' do
        result = MatrixCreator::Vision.detect_demographics

        expect(result).to be(detect_once_result)
      end
    end

    describe 'self.detect_thumb_up' do
      it 'detects thumb up once' do
        malos_eye_detection_type = double('EnumMalosEyeDetectionType::HAND_THUMB_UP')
        stub_const('MatrixMalos::EnumMalosEyeDetectionType::HAND_THUMB_UP', malos_eye_detection_type)

        expect(MatrixCreator::Vision).to receive(:detect_once).with(malos_eye_detection_type)

        MatrixCreator::Vision.detect_thumb_up
      end

      it 'returns result from detect_once' do
        result = MatrixCreator::Vision.detect_thumb_up

        expect(result).to be(detect_once_result)
      end
    end

    describe 'self.detect_palm' do
      it 'detects palm once' do
        malos_eye_detection_type = double('EnumMalosEyeDetectionType::HAND_PALM')
        stub_const('MatrixMalos::EnumMalosEyeDetectionType::HAND_PALM', malos_eye_detection_type)

        expect(MatrixCreator::Vision).to receive(:detect_once).with(malos_eye_detection_type)

        MatrixCreator::Vision.detect_palm
      end

      it 'returns result from detect_once' do
        result = MatrixCreator::Vision.detect_palm

        expect(result).to be(detect_once_result)
      end
    end

    describe 'self.detect_pinch' do
      it 'detects pinch once' do
        malos_eye_detection_type = double('EnumMalosEyeDetectionType::HAND_PINCH')
        stub_const('MatrixMalos::EnumMalosEyeDetectionType::HAND_PINCH', malos_eye_detection_type)

        expect(MatrixCreator::Vision).to receive(:detect_once).with(malos_eye_detection_type)

        MatrixCreator::Vision.detect_pinch
      end

      it 'returns result from detect_once' do
        result = MatrixCreator::Vision.detect_pinch

        expect(result).to be(detect_once_result)
      end
    end

    describe 'self.detect_first' do
      it 'detects fist once' do
        malos_eye_detection_type = double('EnumMalosEyeDetectionType::HAND_FIST')
        stub_const('MatrixMalos::EnumMalosEyeDetectionType::HAND_FIST', malos_eye_detection_type)

        expect(MatrixCreator::Vision).to receive(:detect_once).with(malos_eye_detection_type)

        MatrixCreator::Vision.detect_fist
      end

      it 'returns result from detect_once' do
        result = MatrixCreator::Vision.detect_fist

        expect(result).to be(detect_once_result)
      end
    end
  end
end
