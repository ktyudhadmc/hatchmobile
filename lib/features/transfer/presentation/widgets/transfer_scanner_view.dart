import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/mixins/async_state_handler_mixin.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/dialog_helper.dart';
import '../../../../shared/widgets/scanner/scanner_view.dart';
import '../providers/transfer_provider.dart';

/// Live camera view that scans a basket QR code, fetches its detail, then
/// pushes the confirmation page. Only mounted once, as Home's main content
/// — see [ScanFab] for why it must not be pushed as a second route on top.
class TransferScannerView extends ConsumerStatefulWidget {
  const TransferScannerView({super.key, this.scannerBuilder});

  final Widget Function({
    required void Function(String) onDetect,
    required bool isBusy,
    MobileScannerController? controller,
  })?
  scannerBuilder;

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

        context.pushReplacement('/transfer/confirm', extra: basket);
      },
      onError: (err, stack) {
        _setBusy(false);
        ToastHelper.error(err.toString());

        // START SCAN AGAIN
        if (mounted) _controller.start();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Dev-only shortcut: pretend a QR was scanned and feed the code straight
  /// into the same [scanBasketProvider] flow a real detection would, so the
  /// rest of the pipeline (GET basket -> confirm page -> POST) is exercised
  /// against the real backend without needing a physical QR code.
  Future<void> _onMockScan() async {
    final controller = TextEditingController(text: 'A0001');

    final code = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mock scan'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Basket code'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('BATAL'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('SCAN'),
          ),
        ],
      ),
    );

    if (code == null || code.isEmpty) return;

    _setBusy(true);
    ref.read(scanBasketProvider.notifier).scan(code);
  }

  @override
  Widget build(BuildContext context) {
    // return ScannerView(
    //   controller: _controller, // ← pass controller dari luar
    //   isBusy: _isBusy,
    //   hint: 'Arahkan kamera ke QR code basket',
    //   onDetect: (code) {
    //     print('🔍 [SCAN] code: $code | isBusy: $_isBusy');
    //     _setBusy(true);
    //     ref.read(scanBasketProvider.notifier).scan(code);
    //   },
    // );
    final builder =
        widget.scannerBuilder ??
        ({required onDetect, required isBusy, controller}) => ScannerView(
          controller: controller,
          isBusy: isBusy,
          onDetect: onDetect,
          hint: 'Arahkan kamera ke QR code basket',
        );

    final scanner = builder(
      controller: _controller,
      isBusy: _isBusy,
      onDetect: (code) {
        _setBusy(true);
        ref.read(scanBasketProvider.notifier).scan(code);
      },
    );

    if (!kDebugMode) return scanner;

    // Dev-only — stripped from release builds by the kDebugMode check above.
    return Stack(
      children: [
        scanner,
        Positioned(
          top: 12,
          right: 12,
          child: FloatingActionButton.small(
            heroTag: 'mockScanFab',
            backgroundColor: AppTheme.warningColor,
            onPressed: _isBusy ? null : _onMockScan,
            child: const Icon(Icons.bug_report, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
