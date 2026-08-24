import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/mixins/async_state_handler_mixin.dart';
import '../../../../core/utils/dialog_helper.dart';
import '../../../../shared/widgets/scanner/scanner_view.dart';
import '../providers/transfer_provider.dart';

/// Live camera view that scans a basket QR code, fetches its detail, then
/// pushes the confirmation page. Only mounted once, as Home's main content
/// — see [ScanFab] for why it must not be pushed as a second route on top.
class TransferScannerView extends ConsumerStatefulWidget {
  const TransferScannerView({super.key, this.scannerBuilder, this.controller});

  final Widget Function({
    required void Function(String) onDetect,
    required bool isBusy,
    MobileScannerController? controller,
  })?
  scannerBuilder;

  /// Controller from outside — e.g. so a parent overlay can toggle the
  /// torch. When omitted, this widget creates and disposes its own.
  final MobileScannerController? controller;

  @override
  ConsumerState<TransferScannerView> createState() =>
      _TransferScannerViewState();
}

class _TransferScannerViewState extends ConsumerState<TransferScannerView>
    with AsyncStateHandlerMixin {
  late final MobileScannerController _controller;
  late final bool _ownsController;
  bool _isBusy = false;

  void _setBusy(bool value) {
    if (mounted) setState(() => _isBusy = value); // ← pakai setState!
  }

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? MobileScannerController();

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

        context.pushReplacement('/transfer/confirm', extra: basket);
      },
      onError: (err, stack) {
        // START SCAN AGAIN #1
        // _setBusy(false);
        ToastHelper.error(err.toString());

        // START SCAN AGAIN #2
        // if (mounted) _controller.start();

        if (mounted) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) _controller.start();
          });
        }
      },
    );
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final builder =
        widget.scannerBuilder ??
        ({required onDetect, required isBusy, controller}) => ScannerView(
          controller: controller,
          isBusy: isBusy,
          onDetect: onDetect,
          hint: 'Arahkan kamera ke QR code basket',
          centerOffsetY: screenHeight * 0.18,
        );

    return builder(
      controller: _controller,
      isBusy: _isBusy,
      onDetect: (code) {
        _setBusy(true);
        ref.read(scanBasketProvider.notifier).scan(code);
      },
    );
  }
}
