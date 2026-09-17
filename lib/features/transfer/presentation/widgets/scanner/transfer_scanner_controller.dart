import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';

/// Factory untuk membuat [MobileScannerController] dengan konfigurasi
/// standar Transfer Scanner.
///
/// Dipisah agar konfigurasi kamera mudah diubah tanpa menyentuh UI.
MobileScannerController buildTransferScannerController() {
  return MobileScannerController(
    autoStart: true,
    autoZoom: true,
    detectionSpeed: DetectionSpeed.unrestricted,
    cameraResolution: const Size(1920, 1080),
    formats: [BarcodeFormat.all],
  );
}
