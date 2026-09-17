// core/widgets/scanner/scanner_view.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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

  /// Ukuran kotak panduan visual. Murni dekoratif — deteksi tetap jalan di
  /// seluruh frame kamera, bukan cuma di dalam kotak ini.
  final double guideBoxSize;

  /// Geser posisi kotak panduan secara vertikal dari titik tengah layar.
  /// Nilai positif menggeser ke atas, negatif ke bawah. Default 0 (di tengah).
  final double guideOffsetY;

  /// Controller dari luar — opsional.
  /// Kalau tidak diisi, widget buat sendiri dan dispose sendiri.
  final MobileScannerController? controller;

  const ScannerView({
    super.key,
    required this.onDetect,
    this.isBusy = false,
    this.hint,
    this.guideBoxSize = defaultGuideBoxSize,
    this.guideOffsetY = 0,
    this.controller,
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
  }

  void _onDetect(BarcodeCapture capture) {
    if (widget.isBusy || capture.barcodes.isEmpty) return;

    final code = capture.barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    widget.onDetect(code);
  }

  @override
  void dispose() {
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
                child: CustomPaint(
                  painter: _ScanGuidePainter(guideRect: guideRect),
                ),
              ),
              if (widget.hint != null && widget.hint!.isNotEmpty)
                Positioned(
                  left: guideRect.left + _HintBadge.horizontalInset,
                  width: guideRect.width - _HintBadge.horizontalInset * 2,
                  top: guideRect.bottom - _HintBadge.height - 12,
                  child: _HintBadge(text: widget.hint!),
                ),
            ],
          );
        },
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

/// Dims everything outside [guideRect] and draws corner brackets around it,
/// like a typical QR-scanner viewfinder — purely a visual aid, doesn't
/// affect what area actually gets scanned.
class _ScanGuidePainter extends CustomPainter {
  const _ScanGuidePainter({required this.guideRect});

  final Rect guideRect;

  static const _cornerLength = 28.0;
  static const _cornerRadius = 0.0;
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

    final cornerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    void drawCorner(Offset a, Offset b, Offset c) {
      canvas.drawPath(
        Path()
          ..moveTo(a.dx, a.dy)
          ..lineTo(b.dx, b.dy)
          ..lineTo(c.dx, c.dy),
        cornerPaint,
      );
    }

    final r = guideRect;
    drawCorner(
      Offset(r.left, r.top + _cornerLength),
      Offset(r.left, r.top),
      Offset(r.left + _cornerLength, r.top),
    );
    drawCorner(
      Offset(r.right - _cornerLength, r.top),
      Offset(r.right, r.top),
      Offset(r.right, r.top + _cornerLength),
    );
    drawCorner(
      Offset(r.right, r.bottom - _cornerLength),
      Offset(r.right, r.bottom),
      Offset(r.right - _cornerLength, r.bottom),
    );
    drawCorner(
      Offset(r.left + _cornerLength, r.bottom),
      Offset(r.left, r.bottom),
      Offset(r.left, r.bottom - _cornerLength),
    );
  }

  @override
  bool shouldRepaint(covariant _ScanGuidePainter oldDelegate) =>
      oldDelegate.guideRect != guideRect;
}
