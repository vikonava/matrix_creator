module MatrixProtobuf
  def simulate_matrix_malos_config
    let(:driver_config) { double('MatrixMalos:DriverConfig') }
    let(:malos_eye_config) { double('MatrixMalos::MalosEyeConfig') }
    let(:camera_config) { double('MatrixMalos:CameraConfig') }
    let(:driver_config_instance) { double('MatrixMalos:DriverConfig.instance') }
    let(:malos_eye_config_instance) { double('MatrixMalos::MalosEyeConfig.instance') }
    let(:malos_eye_obj_attr) { double('MatrisMalos::MalosEyeConfig.object_to_detect') }
    let(:camera_config_instance) { double('MatrixMalos:CameraConfig.instance') }

    let(:vision_result) { double('AdmobilizeVision::VisionResult') }

    before(:each) do
      stub_const('MatrixMalos::DriverConfig', driver_config)
      stub_const('MatrixMalos::MalosEyeConfig', malos_eye_config)
      stub_const('MatrixMalos::CameraConfig', camera_config)

      allow(driver_config).to receive(:new).and_return(driver_config_instance)
      allow(malos_eye_config).to receive(:new).and_return(malos_eye_config_instance)
      allow(camera_config).to receive(:new).and_return(camera_config_instance)

      allow(malos_eye_config_instance).to receive(:object_to_detect).and_return(malos_eye_obj_attr)
      allow(malos_eye_obj_attr).to receive(:push)
    end
  end

  def simulate_malos_everloop
    let(:led_value) { double('MatrixMalos::LedValue') }
    let(:everloop_image) { double('MatrixMalos::EverloopImage') }
    let(:driver_config) { double('MatrixMalos::DriverConfig') }
    let(:led_value_instance) { double('MatrixMalos::LedValue.instance') }
    let(:everloop_image_instance) { double('MatrixMalos::EverloopImage.instance') }
    let(:driver_config_instance) { double('MatrixMalos::DriverConfig.instance') }

    before(:each) do
      stub_const('MatrixMalos::LedValue', led_value)
      stub_const('MatrixMalos::EverloopImage', everloop_image)
      stub_const('MatrixMalos::DriverConfig', driver_config)

      allow(led_value).to receive(:new).and_return(led_value_instance)
      allow(everloop_image).to receive(:new).and_return(everloop_image_instance)
      allow(driver_config).to receive(:new).and_return(driver_config_instance)
    end
  end
end
