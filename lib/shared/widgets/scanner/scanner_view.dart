// core/widgets/scanner/scanner_view.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ScannerView extends StatefulWidget {
  /// Default of [guideBoxSize] — exposed so callers positioning something
  /// relative to the guide box (e.g. a button under it) can agree with it
  /// without duplicating the number.
  static const double defaultGuideBoxSize = 260;

  /// Dipanggil sekali per QR code yang terdeteksi.
  /// Caller bertanggung jawab untuk set [isBusy] supaya tidak double scan.
  final void Function(String code) onDetect;

  /// Kalau true, scanner tidak akan memproses barcode baru.
  final bool isBusy;

  /// Badge di bagian bawah **dalam** guide box, lebar mengikuti guide box.
  /// Dipakai buat nampilin raw value QR yang barusan terdeteksi.
  final String? hint;

  /// Instruction shown centered just above the guide box (e.g. "Position
  /// the barcode within the frame provided"). Null/empty hides it.
  final String? instructionText;

  /// Ukuran kotak panduan visual. Murni dekoratif — deteksi tetap jalan di
  /// seluruh frame kamera, bukan cuma di dalam kotak ini.
  final double guideBoxSize;

  /// Geser posisi kotak panduan secara vertikal dari titik tengah layar.
  /// Nilai positif menggeser ke atas, negatif ke bawah. Default 0 (di tengah).
  final double guideOffsetY;

  /// Controller dari luar — opsional.
  /// Kalau tidak diisi, widget buat sendiri dan dispose sendiri.
  final MobileScannerController? controller;

  /// Kalau true, tampilkan tombol torch manual di pojok kanan bawah guide box.
  final bool showTorchButton;

  /// Kalau true, torch otomatis dinyalakan setelah [autoTorchDelay] tanpa
  /// deteksi barcode sama sekali (indikasi kondisi gelap).
  final bool enableAutoTorch;

  /// Durasi tanpa deteksi sebelum torch otomatis dinyalakan.
  final Duration autoTorchDelay;

  /// Kalau true, device yang terlalu miring akan menampilkan peringatan
  /// "Tegakkan kamera" lewat accelerometer.
  final bool enableTiltWarning;

  const ScannerView({
    super.key,
    required this.onDetect,
    this.isBusy = false,
    this.hint,
    this.instructionText,
    this.guideBoxSize = defaultGuideBoxSize,
    this.guideOffsetY = 0,
    this.controller,
    this.showTorchButton = true,
    this.enableAutoTorch = true,
    this.autoTorchDelay = const Duration(seconds: 4),
    this.enableTiltWarning = true,
  });

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  late final MobileScannerController _controller;
  late final bool _ownsController;

  // Zoom scale ([0, 1], MobileScanner's own scale) at the moment a pinch
  // gesture starts, so onScaleUpdate can apply the pinch delta relative to
  // it instead of jumping/resetting every frame.
  double _zoomAtGestureStart = 0;

  // Ditandai true sesaat setelah deteksi berhasil, dipakai buat kasih
  // feedback visual instan (border guide box jadi hijau) sebelum caller
  // sempat bereaksi (mis. pindah halaman).
  bool _justDetected = false;
  Timer? _detectedFlashTimer;

  // Auto-torch: hitung berapa lama sejak terakhir kali tidak ada deteksi
  // sukses, nyalakan torch otomatis kalau kelamaan (indikasi gelap).
  Timer? _autoTorchTimer;
  bool _autoTorchTriggered = false;

  // Adaptive sensitivity: kalau berkali-kali gagal detect, zoom out sedikit
  // supaya area tangkap lebih luas (kompensasi jarak/angle yang meleset).
  Timer? _sensitivityTimer;
  int _failCount = 0;
  static const _failThreshold = 10;
  static const _sensitivityCheckInterval = Duration(seconds: 1);

  // Tilt detection via accelerometer.
  StreamSubscription<AccelerometerEvent>? _accelSub;
  bool _isTilted = false;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        MobileScannerController(
          formats: [BarcodeFormat.qrCode],
          detectionSpeed: DetectionSpeed.unrestricted,
          cameraResolution: const Size(3840, 2160),
          autoStart: true,
          autoZoom: true,
        );

    if (widget.enableAutoTorch) _startAutoTorchTimer();
    _startSensitivityTimer();
    if (widget.enableTiltWarning) _startTiltDetection();
  }

  void _onDetect(BarcodeCapture capture) {
    if (widget.isBusy || capture.barcodes.isEmpty) {
      _failCount++;
      return;
    }

    final code = capture.barcodes.first.rawValue;
    if (code == null || code.isEmpty) {
      _failCount++;
      return;
    }

    _failCount = 0;
    _flashDetected();
    HapticFeedback.mediumImpact();
    _cancelAutoTorchTimer();

    widget.onDetect(code);
  }

  void _flashDetected() {
    setState(() => _justDetected = true);
    _detectedFlashTimer?.cancel();
    _detectedFlashTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _justDetected = false);
    });
  }

  // ─── Auto torch ────────────────────────────────────────────────────────

  void _startAutoTorchTimer() {
    _autoTorchTimer?.cancel();
    _autoTorchTimer = Timer(widget.autoTorchDelay, () {
      if (!mounted || _autoTorchTriggered) return;
      _autoTorchTriggered = true;
      _controller.toggleTorch();
    });
  }

  void _cancelAutoTorchTimer() {
    _autoTorchTimer?.cancel();
  }

  // ─── Adaptive sensitivity ──────────────────────────────────────────────

  void _startSensitivityTimer() {
    _sensitivityTimer?.cancel();
    _sensitivityTimer = Timer.periodic(_sensitivityCheckInterval, (_) {
      if (_failCount > _failThreshold) {
        _failCount = 0;
        _widenDetectionArea();
      }
    });
  }

  void _widenDetectionArea() {
    final currentZoom = _controller.value.zoomScale;
    if (currentZoom <= 0) return;
    _controller.setZoomScale((currentZoom - 0.1).clamp(0.0, 1.0));
  }

  // ─── Tilt detection ────────────────────────────────────────────────────

  void _startTiltDetection() {
    _accelSub = accelerometerEventStream().listen((event) {
      // z mendekati 0 berarti device hampir horizontal/miring ekstrem
      // relatif terhadap posisi memotret tegak lurus ke barcode.
      final tilted = event.z.abs() < 3.0;
      if (tilted != _isTilted && mounted) {
        setState(() => _isTilted = tilted);
      }
    });
  }

  @override
  void dispose() {
    _detectedFlashTimer?.cancel();
    _autoTorchTimer?.cancel();
    _sensitivityTimer?.cancel();
    _accelSub?.cancel();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final center =
              constraints.biggest.center(Offset.zero) -
              Offset(0, widget.guideOffsetY);
          final guideRect = Rect.fromCenter(
            center: center,
            width: widget.guideBoxSize,
            height: widget.guideBoxSize,
          );

          return Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                onScaleStart: (_) =>
                    _zoomAtGestureStart = _controller.value.zoomScale,
                onScaleUpdate: (details) {
                  // MobileScannerController's zoom scale is linear [0, 1],
                  // not a camera zoom factor, so map the pinch scale
                  // logarithmically to keep the gesture feeling proportional
                  // across the whole range instead of maxing out instantly.
                  final delta = (details.scale - 1) * 0.5;
                  _controller.setZoomScale(
                    (_zoomAtGestureStart + delta).clamp(0.0, 1.0),
                  );
                },
                child: MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                ),
              ),
              IgnorePointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: CustomPaint(
                    painter: _ScanGuidePainter(
                      guideRect: guideRect,
                      isDetected: _justDetected,
                    ),
                  ),
                ),
              ),
              if (widget.instructionText != null &&
                  widget.instructionText!.isNotEmpty)
                Positioned(
                  left: 24,
                  right: 24,
                  top: guideRect.top - 44,
                  child: Text(
                    widget.instructionText!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              if (widget.hint != null && widget.hint!.isNotEmpty)
                Positioned(
                  left: guideRect.left + _HintBadge.horizontalInset,
                  width: guideRect.width - _HintBadge.horizontalInset * 2,
                  top: guideRect.bottom - _HintBadge.height - 12,
                  child: _HintBadge(text: widget.hint!),
                ),
              if (widget.enableTiltWarning && _isTilted)
                const Positioned(
                  top: 48,
                  left: 0,
                  right: 0,
                  child: Center(child: _TiltWarningBanner()),
                ),
              if (widget.showTorchButton)
                Positioned(
                  right: 16,
                  bottom: guideRect.bottom + 16,
                  child: TorchButton(controller: _controller),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Tombol torch manual, warnanya ngikutin state torch dari controller.
class TorchButton extends StatelessWidget {
  const TorchButton({super.key, required this.controller});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MobileScannerState>(
      valueListenable: controller,
      builder: (context, state, _) {
        final isOn = state.torchState == TorchState.on;
        return InkWell(
          customBorder: const CircleBorder(),
          onTap: () => controller.toggleTorch(),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              isOn ? Icons.flash_on : Icons.flash_off,
              color: isOn ? Colors.amber : Colors.white,
              size: 22,
            ),
          ),
        );
      },
    );
  }
}

/// Banner peringatan saat device terdeteksi terlalu miring lewat accelerometer.
class _TiltWarningBanner extends StatelessWidget {
  const _TiltWarningBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.screen_rotation_alt, color: Colors.amber, size: 18),
          SizedBox(width: 8),
          Text(
            'Tegakkan kamera',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// Badge kecil di dalam guide box menampilkan [text] (biasanya raw value QR
/// yang barusan kedeteksi). Lebar mengikuti parent (guide box), jadi teks
/// panjang di-ellipsis daripada meluber keluar box.
class _HintBadge extends StatelessWidget {
  const _HintBadge({required this.text});

  final String text;

  static const double height = 28;

  /// Jarak minimum badge dari sisi kiri/kanan guide box, supaya walau
  /// teksnya panjang dan ke-clamp, badge tidak mepet ke garis box.
  static const double horizontalInset = 16;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(height / 2),
        ),
        // widthFactor: 1 shrink-wraps to the text so the badge stays narrow
        // for short values; without it Align expands to fill the row like
        // Container's own `alignment` did before.
        child: Align(
          widthFactor: 1,
          child: Text(
            text,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

/// Dims everything outside [guideRect] and draws a rounded border around it,
/// like a typical QR-scanner viewfinder — purely a visual aid, doesn't
/// affect what area actually gets scanned. The border turns green briefly
/// when [isDetected] is true, giving instant confirmation of a successful
/// scan.
class _ScanGuidePainter extends CustomPainter {
  const _ScanGuidePainter({required this.guideRect, required this.isDetected});

  final Rect guideRect;
  final bool isDetected;

  static const _cornerRadius = 20.0;
  static const _strokeWidth = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final holePath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          guideRect,
          const Radius.circular(_cornerRadius),
        ),
      );
    final overlayPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      holePath,
    );
    canvas.drawPath(
      overlayPath,
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );

    final borderPaint = Paint()
      ..color = isDetected ? Colors.greenAccent : Colors.white
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(guideRect, const Radius.circular(_cornerRadius)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanGuidePainter oldDelegate) =>
      oldDelegate.guideRect != guideRect ||
      oldDelegate.isDetected != isDetected;
}
