import 'package:camera/camera.dart';

import '../../../../shared/widgets/scanner/zxing_camera_controller.dart';

/// Factory untuk membuat [ZxingCameraController] dengan konfigurasi
/// standar Transfer Scanner.
///
/// Dipisah agar konfigurasi kamera mudah diubah tanpa menyentuh UI.
ZxingCameraController buildTransferScannerController() {
  return ZxingCameraController(
    lensDirection: CameraLensDirection.back,
    resolution: ResolutionPreset.high,
  );
}
