import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

/// Camera state exposed by [ZxingCameraController] — mirrors the small
/// slice of `MobileScannerController`'s state this app actually used, so
/// [TorchButton] and the pinch-zoom gesture didn't need to change shape
/// when the scanning engine swapped from mobile_scanner (ML Kit) to
/// flutter_zxing.
@immutable
class ZxingCameraValue {
  const ZxingCameraValue({
    this.isInitialized = false,
    this.isTorchOn = false,
    this.isTorchAvailable = true,
    this.zoomScale = 0,
    this.error,
  });

  final bool isInitialized;
  final bool isTorchOn;
  final bool isTorchAvailable;

  /// Normalized [0, 1] regardless of the actual device zoom range, same
  /// contract `MobileScannerController.zoomScale` had — callers (pinch
  /// gesture, [ScannerSensitivityTuner]) work in this normalized space.
  final double zoomScale;

  final String? error;

  ZxingCameraValue copyWith({
    bool? isInitialized,
    bool? isTorchOn,
    bool? isTorchAvailable,
    double? zoomScale,
    String? error,
  }) {
    return ZxingCameraValue(
      isInitialized: isInitialized ?? this.isInitialized,
      isTorchOn: isTorchOn ?? this.isTorchOn,
      isTorchAvailable: isTorchAvailable ?? this.isTorchAvailable,
      zoomScale: zoomScale ?? this.zoomScale,
      error: error,
    );
  }
}

/// Owns the [CameraController] that backs [ScannerView] — camera lifecycle,
/// torch and zoom only. Per-frame decoding is [ScannerView]'s job (it owns
/// the crop rect and the `onDetect` callback), this class just gives it
/// something to point [CameraController.startImageStream] at.
///
/// Replaces `MobileScannerController` (mobile_scanner/ML Kit) now that
/// scanning runs entirely on flutter_zxing (ZXing-cpp) — ML Kit struggled
/// with codes that are dense, skewed, or have a logo cut into the center,
/// and ZXing is meaningfully more tolerant of exactly that.
class ZxingCameraController extends ValueNotifier<ZxingCameraValue> {
  ZxingCameraController({
    this.lensDirection = CameraLensDirection.back,
    this.resolution = ResolutionPreset.high,
  }) : super(const ZxingCameraValue());

  final CameraLensDirection lensDirection;
  final ResolutionPreset resolution;

  CameraController? _cameraController;
  double _minZoomLevel = 1;
  double _maxZoomLevel = 1;
  bool _initializing = false;
  void Function(CameraImage image)? _onImage;

  /// The underlying controller, once [initialize] has completed — needed by
  /// [ScannerView] to build the `CameraPreview`.
  CameraController? get rawController => _cameraController;

  /// Idempotent — safe to call even if another caller already triggered it
  /// (e.g. a rebuilt [ScannerView] reusing the same externally-owned
  /// controller).
  Future<void> initialize() async {
    if (value.isInitialized || _initializing) return;
    _initializing = true;

    try {
      final cameras = await availableCameras();
      final description = cameras.firstWhere(
        (camera) => camera.lensDirection == lensDirection,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        description,
        resolution,
        enableAudio: false,
      );
      _cameraController = controller;

      await controller.initialize();
      _minZoomLevel = await controller.getMinZoomLevel();
      _maxZoomLevel = await controller.getMaxZoomLevel();
      await controller.setFlashMode(FlashMode.off);

      value = value.copyWith(isInitialized: true);
    } catch (e) {
      value = value.copyWith(error: e.toString());
    } finally {
      _initializing = false;
    }
  }

  /// Starts feeding camera frames to [onImage]. Stored so [start] can
  /// resume the same callback after a [stop].
  Future<void> startImageStream(void Function(CameraImage image) onImage) async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isStreamingImages) return;

    _onImage = onImage;
    await controller.startImageStream(onImage);
  }

  Future<void> toggleTorch() async {
    final controller = _cameraController;
    if (controller == null || !value.isTorchAvailable) return;

    final turningOn = !value.isTorchOn;
    try {
      await controller.setFlashMode(turningOn ? FlashMode.torch : FlashMode.off);
      value = value.copyWith(isTorchOn: turningOn);
    } catch (_) {
      value = value.copyWith(isTorchAvailable: false);
    }
  }

  /// [scale] is normalized [0, 1] — mapped onto the device's actual zoom
  /// range, same contract `MobileScannerController.setZoomScale` had.
  Future<void> setZoomScale(double scale) async {
    final controller = _cameraController;
    if (controller == null) return;

    final clamped = scale.clamp(0.0, 1.0);
    final level = _minZoomLevel + clamped * (_maxZoomLevel - _minZoomLevel);
    try {
      await controller.setZoomLevel(level);
      value = value.copyWith(zoomScale: clamped);
    } catch (_) {
      // Zoom level out of range on this device — ignore, state stays as-is.
    }
  }

  /// Pauses the camera — stops feeding frames and freezes the preview.
  /// Used while a result sheet covers the scanner, not on page exit.
  Future<void> stop() async {
    final controller = _cameraController;
    if (controller == null) return;

    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
      await controller.pausePreview();
    } catch (_) {
      // Already stopped/disposed — nothing to do.
    }
  }

  /// Resumes a [stop]ped camera with the same frame callback it had before.
  Future<void> start() async {
    final controller = _cameraController;
    if (controller == null) return;

    try {
      await controller.resumePreview();
      final onImage = _onImage;
      if (onImage != null && !controller.value.isStreamingImages) {
        await controller.startImageStream(onImage);
      }
    } catch (_) {
      // Controller not in a resumable state — nothing to do.
    }
  }

  @override
  Future<void> dispose() async {
    final controller = _cameraController;
    _cameraController = null;
    if (controller != null) {
      try {
        if (controller.value.isStreamingImages) {
          await controller.stopImageStream();
        }
        await controller.dispose();
      } catch (_) {
        // Best-effort — already gone.
      }
    }
    super.dispose();
  }
}
