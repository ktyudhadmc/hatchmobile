import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/mixins/async_state_handler_mixin.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/dialog_helper.dart';
import '../providers/transfer_provider.dart';

/// Live camera view that scans a basket QR code, fetches its detail, then
/// pushes the confirmation page. Used both as Home's main content and as
/// the standalone /scan route.
class TransferScannerView extends ConsumerStatefulWidget {
  const TransferScannerView({super.key});

  @override
  ConsumerState<TransferScannerView> createState() => _TransferScannerViewState();
}

class _TransferScannerViewState extends ConsumerState<TransferScannerView>
    with AsyncStateHandlerMixin {
  final _controller = MobileScannerController();
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();

    listenAsync(
      provider: scanBasketProvider,
      loadingMessage: 'Mencari basket...',
      onData: (basket) async {
        if (basket == null) {
          _isBusy = false;
          return;
        }

        await _controller.stop();
        if (!mounted) return;

        await context.push('/transfer/confirm', extra: basket);

        _isBusy = false;
        if (mounted) await _controller.start();
      },
      onError: (err, stack) {
        _isBusy = false;
        ToastHelper.error(err.toString());
      },
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isBusy || capture.barcodes.isEmpty) return;

    final code = capture.barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    _isBusy = true;
    ref.read(scanBasketProvider.notifier).scan(code);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryColor, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: Text(
              'Arahkan kamera ke QR code basket',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                shadows: [Shadow(blurRadius: 8, color: Colors.black)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
