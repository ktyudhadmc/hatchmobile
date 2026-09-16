import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../shared/widgets/scanner/scanner_view.dart';
import '../../domain/entities/transfer_basket.dart';
import '../providers/transfer_provider.dart';

/// Live camera view that scans a basket QR code and fetches its detail,
/// handing the result to [onBasketFound] (or [onBasketNotFound] if the
/// lookup fails) — the parent (ScanPage) owns what happens next (showing
/// [TransferReceiveSheet] or a not-found sheet) and tells this widget when
/// to resume via [paused]. Only mounted once, as Home's main content — see
/// [ScanFab] for why it must not be pushed as a second route on top.
class TransferScannerView extends ConsumerStatefulWidget {
  const TransferScannerView({
    super.key,
    this.scannerBuilder,
    this.controller,
    this.paused = false,
    required this.onBasketFound,
    required this.onBasketNotFound,
  });

  final Widget Function({
    required void Function(String) onDetect,
    required bool isBusy,
    MobileScannerController? controller,
  })?
  scannerBuilder;

  /// Controller from outside. When omitted, this widget creates and
  /// disposes its own.
  final MobileScannerController? controller;

  /// Set by the parent while a scanned basket is being confirmed — camera
  /// stays stopped and detections are ignored until this flips back false.
  final bool paused;

  final void Function(TransferBasket basket) onBasketFound;
  final VoidCallback onBasketNotFound;

  @override
  ConsumerState<TransferScannerView> createState() =>
      _TransferScannerViewState();
}

class _TransferScannerViewState extends ConsumerState<TransferScannerView> {
  late final MobileScannerController _controller;
  late final bool _ownsController;

  // No isBusy gate on the scanner itself — detection runs on every frame
  // (like dailyreport's QR scanner) so it feels instant in the field. What
  // we still need to avoid is hammering the API with the same code on every
  // frame while its lookup is in flight, so this tracks just that.
  String? _lookupCode;

  // Deliberately not the shared listenAsync/DialogHelper loading dialog:
  // that dialog dismisses itself via a postFrameCallback, which races with
  // anything pushed as a route right after it (see the receive sheet's
  // history for the bug this caused). An inline overlay needs no Navigator,
  // so there's nothing for it to race with.
  bool _isLookingUpBasket = false;

  late final ProviderSubscription<AsyncValue<TransferBasket?>>
  _scanSubscription;

  void _resetLookup() {
    if (mounted) setState(() => _lookupCode = null);
  }

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        MobileScannerController(
          formats: [BarcodeFormat.qrCode],
          detectionSpeed: DetectionSpeed.unrestricted,
          cameraResolution: const Size(1920, 1080),
          autoStart: true,
        );

    _scanSubscription = ref.listenManual<AsyncValue<TransferBasket?>>(
      scanBasketProvider,
      (previous, next) {
        next.when(
          loading: () {
            if (mounted) setState(() => _isLookingUpBasket = true);
          },
          data: (basket) async {
            if (mounted) setState(() => _isLookingUpBasket = false);

            if (basket == null) {
              _resetLookup();
              return;
            }

            await _controller.stop();
            if (!mounted) return;

            widget.onBasketFound(basket);
          },
          error: (err, stack) {
            if (mounted) setState(() => _isLookingUpBasket = false);
            _resetLookup();
            widget.onBasketNotFound();
          },
        );
      },
      fireImmediately: false,
    );
  }

  @override
  void didUpdateWidget(covariant TransferScannerView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.paused && widget.paused) {
      _controller.stop();
    } else if (oldWidget.paused && !widget.paused) {
      _resetLookup();
      _controller.start();
    }
  }

  @override
  void dispose() {
    _scanSubscription.close();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder rather than MediaQuery — this reports the space this
    // widget actually has (body area, below the AppBar), which is what
    // ScannerView's own guide-box math is relative to. ScanPage replicates
    // this same formula to position the debug button under the guide box,
    // so both need to agree on the same height.
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ScannerView(
              controller: _controller,
              guideOffsetY: constraints.maxHeight * 0.18,
              onDetect: (code) {
                if (code == _lookupCode) return;
                setState(() => _lookupCode = code);
                ref.read(scanBasketProvider.notifier).scan(code);
              },
            ),
            if (_isLookingUpBasket)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black45,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 12),
                        Text(
                          'Mencari basket...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
