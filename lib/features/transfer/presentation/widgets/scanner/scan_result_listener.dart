import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hatchmobile/features/transfer/domain/entities/transfer_basket.dart';
import 'package:hatchmobile/features/transfer/presentation/widgets/scanner/transfer_scanner_state.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Menangani perubahan state dari [scanBasketProvider] dan menerjemahkannya
/// ke aksi UI (loading, found, not found).
///
/// Dipisah dari widget agar logic reaksi mudah dibaca dan di-test sendiri.
class ScanResultListener {
  const ScanResultListener({
    required this.controller,
    required this.onStateChanged,
    required this.onBasketFound,
    required this.onBasketNotFound,
  });

  final MobileScannerController controller;
  final void Function(TransferScannerState state) onStateChanged;
  final void Function(TransferBasket basket) onBasketFound;
  final void Function(String code) onBasketNotFound;

  /// Dipanggil setiap kali [scanBasketProvider] berubah.
  void handle(AsyncValue<TransferBasket?> next, String? currentLookupCode) {
    next.when(
      loading: _onLoading,
      data: (basket) => _onData(basket),
      error: (err, stack) => _onError(currentLookupCode),
    );
  }

  void _onLoading() {
    onStateChanged(const TransferScannerState(isLookingUp: true));
  }

  Future<void> _onData(TransferBasket? basket) async {
    onStateChanged(const TransferScannerState(isLookingUp: false));

    if (basket == null) {
      // Reset agar QR yang sama bisa di-scan ulang
      onStateChanged(const TransferScannerState().resetLookup());
      return;
    }

    await controller.stop();
    onBasketFound(basket);
  }

  void _onError(String? code) {
    onStateChanged(
      const TransferScannerState(isLookingUp: false).resetLookup(),
    );
    onBasketNotFound(code ?? '');
  }
}
