import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hatchmobile/features/transfer/domain/entities/transfer_basket.dart';
import 'package:hatchmobile/features/transfer/presentation/providers/transfer_provider.dart';
import 'package:hatchmobile/features/transfer/presentation/widgets/scanner/scan_result_listener.dart';
import 'package:hatchmobile/features/transfer/presentation/widgets/scanner/scanner_loading_overlay.dart';
import 'package:hatchmobile/features/transfer/presentation/widgets/scanner/transfer_scanner_controller.dart';
import 'package:hatchmobile/features/transfer/presentation/widgets/scanner/transfer_scanner_state.dart';
import 'package:hatchmobile/shared/widgets/scanner/scanner_view.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Live camera view yang scan basket QR dan fetch detailnya.
///
/// Tanggung jawab widget ini hanya:
///   1. Render kamera + overlay
///   2. Delegasi semua logic ke kelas-kelas terpisah
///
/// Logic sensitivitas  → [buildTransferScannerController]
/// Logic state          → [TransferScannerState]
/// Logic reaksi hasil   → [ScanResultListener]
/// Loading overlay UI  → [ScannerLoadingOverlay]
class TransferScannerView extends ConsumerStatefulWidget {
  const TransferScannerView({
    super.key,
    this.controller,
    this.paused = false,
    this.showTorchButton = true,
    required this.onBasketFound,
    required this.onBasketNotFound,
  });

  /// Controller dari luar (opsional).
  /// Jika null, widget buat dan dispose sendiri.
  final MobileScannerController? controller;

  /// Saat true: kamera berhenti dan deteksi diabaikan.
  final bool paused;

  /// Kalau false, ScannerView tidak menampilkan tombol torch bawaannya —
  /// dipakai saat caller (mis. ScanPage) menaruh tombol torch sendiri di
  /// AppBar dan berbagi [controller] yang sama.
  final bool showTorchButton;

  final void Function(TransferBasket basket) onBasketFound;
  final void Function(String code) onBasketNotFound;

  @override
  ConsumerState<TransferScannerView> createState() =>
      _TransferScannerViewState();
}

class _TransferScannerViewState extends ConsumerState<TransferScannerView> {
  // ─── Controller ────────────────────────────────────────────────────────────

  late final MobileScannerController _controller;
  late final bool _ownsController;

  // ─── State ─────────────────────────────────────────────────────────────────

  TransferScannerState _scanState = const TransferScannerState();

  // ─── Listener ──────────────────────────────────────────────────────────────

  late final ScanResultListener _resultListener;
  late final ProviderSubscription<AsyncValue<TransferBasket?>> _subscription;

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initController();
    _initListener();
  }

  void _initController() {
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? buildTransferScannerController();
  }

  void _initListener() {
    _resultListener = ScanResultListener(
      controller: _controller,
      onStateChanged: _applyState,
      onBasketFound: widget.onBasketFound,
      onBasketNotFound: widget.onBasketNotFound,
    );

    _subscription = ref.listenManual<AsyncValue<TransferBasket?>>(
      scanBasketProvider,
      (_, next) => _resultListener.handle(next, _scanState.lookupCode),
      fireImmediately: false,
    );
  }

  @override
  void didUpdateWidget(covariant TransferScannerView old) {
    super.didUpdateWidget(old);
    _handlePauseChange(wasPaused: old.paused, isPaused: widget.paused);
  }

  @override
  void dispose() {
    _subscription.close();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  void _applyState(TransferScannerState next) {
    if (!mounted) return;
    setState(() => _scanState = next);
  }

  void _handlePauseChange({required bool wasPaused, required bool isPaused}) {
    if (!wasPaused && isPaused) {
      _controller.stop();
    } else if (wasPaused && !isPaused) {
      _applyState(_scanState.resetLookup());
      _controller.start();
    }
  }

  /// Dipanggil sekali per QR code yang terdeteksi kamera.
  ///
  /// [code] adalah raw value hasil decode QR (isi [BarcodeCapture.rawValue]
  /// di [ScannerView]) — untuk basket transfer, ini seharusnya basket code
  /// (mis. "A0001"), bukan payload JSON atau URL.
  void _onDetect(String code) {
    if (_scanState.isAlreadyScanning(code)) return;
    debugPrint('[TransferScanner] detected raw code: $code');

    _applyState(_scanState.copyWith(lookupCode: code));
    ref.read(scanBasketProvider.notifier).scan(code);
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ScannerView(
              controller: _controller,
              guideOffsetY: constraints.maxHeight * 0.18,
              onDetect: _onDetect,
              hint: _scanState.lookupCode,
              showTorchButton: widget.showTorchButton,
            ),
            if (_scanState.isLookingUp) const ScannerLoadingOverlay(),
          ],
        );
      },
    );
  }
}
