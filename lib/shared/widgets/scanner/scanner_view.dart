// core/widgets/scanner/scanner_view.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'scanner_sensitivity_tuner.dart';

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
  BarcodeFormat? _justDetectedFormat;
  Timer? _detectedFlashTimer;

  // Auto-torch: hitung berapa lama sejak terakhir kali tidak ada deteksi
  // sukses, nyalakan torch otomatis kalau kelamaan (indikasi gelap).
  Timer? _autoTorchTimer;
  bool _autoTorchTriggered = false;

  // Adapts zoom/focus in response to a string of failed detections — see
  // ScannerSensitivityTuner for why this matters most for off-angle scans.
  late final ScannerSensitivityTuner _sensitivityTuner;

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
    _sensitivityTuner = ScannerSensitivityTuner(controller: _controller)
      ..start();
  }

  void _onDetect(BarcodeCapture capture) {
    if (widget.isBusy || capture.barcodes.isEmpty) {
      _sensitivityTuner.recordFailure();
      return;
    }

    final barcode = capture.barcodes.first;
    final code = barcode.rawValue;
    if (code == null || code.isEmpty) {
      _sensitivityTuner.recordFailure();
      return;
    }

    _sensitivityTuner.recordSuccess();
    _flashDetected(barcode.format);
    HapticFeedback.mediumImpact();
    _cancelAutoTorchTimer();

    widget.onDetect(code);
  }

  void _flashDetected(BarcodeFormat format) {
    setState(() {
      _justDetected = true;
      _justDetectedFormat = format;
    });
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

  @override
  void dispose() {
    _detectedFlashTimer?.cancel();
    _autoTorchTimer?.cancel();
    _sensitivityTuner.dispose();
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
                      isQrDetected:
                          _justDetected &&
                          _justDetectedFormat == BarcodeFormat.qrCode,
                    ),
                  ),
                ),
              ),
              if (widget.instructionText != null &&
                  widget.instructionText!.isNotEmpty)
                Positioned(
                  left: 40,
                  right: 40,
                  top: guideRect.top - 130,
                  child: Text(
                    widget.instructionText!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      height: 1.3,
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
          color: Colors.amber,
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
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

/// Dims everything outside [guideRect] and draws rounded corner brackets
/// around it, like a typical QR-scanner viewfinder — purely a visual aid,
/// doesn't affect what area actually gets scanned. The brackets flash
/// briefly on a successful scan — amber for a QR code specifically
/// ([isQrDetected]), green for any other barcode format — giving instant
/// confirmation of what was just read.
class _ScanGuidePainter extends CustomPainter {
  const _ScanGuidePainter({
    required this.guideRect,
    required this.isDetected,
    required this.isQrDetected,
  });

  final Rect guideRect;
  final bool isDetected;
  final bool isQrDetected;

  static const _cornerRadius = 20.0;
  static const _cornerLength = 32.0;
  static const _strokeWidth = 4.0;

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

    final borderColor = isQrDetected
        ? Colors.amber
        : isDetected
        ? Colors.greenAccent
        : Colors.white;
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final r = guideRect;
    final c = _cornerRadius;
    final l = _cornerLength;
    const halfPi = 1.5707963267948966;
    const pi = 3.14159265358979323846;

    void drawCorner(Offset arcCenter, double startAngle, List<Offset> legs) {
      canvas.drawArc(
        Rect.fromCircle(center: arcCenter, radius: c),
        startAngle,
        halfPi,
        false,
        borderPaint,
      );
      for (var i = 0; i < legs.length; i += 2) {
        canvas.drawLine(legs[i], legs[i + 1], borderPaint);
      }
    }

    // Top-left: legs point down and right from the arc's tangent points.
    drawCorner(Offset(r.left + c, r.top + c), pi, [
      Offset(r.left, r.top + c),
      Offset(r.left, r.top + l),
      Offset(r.left + c, r.top),
      Offset(r.left + l, r.top),
    ]);
    // Top-right
    drawCorner(Offset(r.right - c, r.top + c), -halfPi, [
      Offset(r.right - c, r.top),
      Offset(r.right - l, r.top),
      Offset(r.right, r.top + c),
      Offset(r.right, r.top + l),
    ]);
    // Bottom-right
    drawCorner(Offset(r.right - c, r.bottom - c), 0, [
      Offset(r.right, r.bottom - c),
      Offset(r.right, r.bottom - l),
      Offset(r.right - c, r.bottom),
      Offset(r.right - l, r.bottom),
    ]);
    // Bottom-left
    drawCorner(Offset(r.left + c, r.bottom - c), halfPi, [
      Offset(r.left + c, r.bottom),
      Offset(r.left + l, r.bottom),
      Offset(r.left, r.bottom - c),
      Offset(r.left, r.bottom - l),
    ]);
  }

  @override
  bool shouldRepaint(covariant _ScanGuidePainter oldDelegate) =>
      oldDelegate.guideRect != guideRect ||
      oldDelegate.isDetected != isDetected ||
      oldDelegate.isQrDetected != isQrDetected;
}
