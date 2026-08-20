// core/widgets/scanner/scanner_view.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_theme.dart';

class ScannerView extends StatefulWidget {
  /// Dipanggil sekali per QR code yang terdeteksi.
  /// Caller bertanggung jawab untuk set [isBusy] supaya tidak double scan.
  final void Function(String code) onDetect;

  /// Kalau true, scanner tidak akan memproses barcode baru.
  final bool isBusy;

  /// Label di bawah scan box. Default sudah ada.
  final String? hint;

  /// Ukuran kotak scan. Default 240.
  final double scanBoxSize;

  /// Controller dari luar — opsional.
  /// Kalau tidak diisi, widget buat sendiri dan dispose sendiri.
  final MobileScannerController? controller;

  const ScannerView({
    super.key,
    required this.onDetect,
    this.isBusy = false,
    this.hint,
    this.scanBoxSize = 240,
    this.controller,
  });

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  late final MobileScannerController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? MobileScannerController();
  }

  void _onDetect(BarcodeCapture capture) {
    if (widget.isBusy || capture.barcodes.isEmpty) return;

    final code = capture.barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    _controller.stop();
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
          final scanWindow = Rect.fromCenter(
            center: constraints.biggest.center(Offset.zero),
            width: widget.scanBoxSize,
            height: widget.scanBoxSize,
          );

          return Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(
                controller: _controller,
                onDetect: _onDetect,
                scanWindow: scanWindow,
              ),
              Positioned.fromRect(
                rect: scanWindow,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.primaryColor, width: 3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 24,
                right: 24,
                child: Text(
                  widget.hint ?? 'Arahkan kamera ke QR code',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    shadows: [Shadow(blurRadius: 8, color: Colors.black)],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
