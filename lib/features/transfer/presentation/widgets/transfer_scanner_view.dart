import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/mixins/async_state_handler_mixin.dart';
import '../../../../shared/widgets/scanner/scanner_view.dart';
import '../../../../core/utils/dialog_helper.dart';
import '../providers/transfer_provider.dart';

/// Live camera view that scans a basket QR code, fetches its detail, then
/// pushes the confirmation page. Only mounted once, as Home's main content
/// — see [ScanFab] for why it must not be pushed as a second route on top.
class TransferScannerView extends ConsumerStatefulWidget {
  const TransferScannerView({super.key});

  @override
  ConsumerState<TransferScannerView> createState() =>
      _TransferScannerViewState();
}

class _TransferScannerViewState extends ConsumerState<TransferScannerView>
    with AsyncStateHandlerMixin {
  final _controller = MobileScannerController();
  bool _isBusy = false;

  void _setBusy(bool value) {
    if (mounted) setState(() => _isBusy = value); // ← pakai setState!
  }

  @override
  void initState() {
    super.initState();

    listenAsync(
      provider: scanBasketProvider,
      loadingMessage: 'Mencari basket...',
      onData: (basket) async {
        if (basket == null) {
          _setBusy(false);
          return;
        }

        await _controller.stop();
        if (!mounted) return;

        await context.push('/transfer/confirm', extra: basket);

        _setBusy(false);
        if (mounted) await _controller.start();
      },
      onError: (err, stack) {
        _setBusy(false);
        ToastHelper.error(err.toString());
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScannerView(
      controller: _controller, // ← pass controller dari luar
      isBusy: _isBusy,
      hint: 'Arahkan kamera ke QR code basket',
      onDetect: (code) {
        _setBusy(false);
        ref.read(scanBasketProvider.notifier).scan(code);
      },
    );
  }
}
