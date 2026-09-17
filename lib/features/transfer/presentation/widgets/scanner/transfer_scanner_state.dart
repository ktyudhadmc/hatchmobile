/// Menyimpan state internal Transfer Scanner.
///
/// Dipisah dari widget agar mudah di-test dan dibaca terpisah dari UI.
class TransferScannerState {
  const TransferScannerState({
    this.lookupCode,
    this.isLookingUp = false,
  });

  /// QR code yang sedang / terakhir di-lookup.
  /// Null berarti belum ada scan aktif.
  final String? lookupCode;

  /// True saat API lookup sedang berjalan.
  final bool isLookingUp;

  /// Apakah [code] sudah sedang diproses (debounce guard).
  bool isAlreadyScanning(String code) => code == lookupCode;

  TransferScannerState copyWith({
    String? lookupCode,
    bool? isLookingUp,
  }) {
    return TransferScannerState(
      lookupCode: lookupCode ?? this.lookupCode,
      isLookingUp: isLookingUp ?? this.isLookingUp,
    );
  }

  /// Reset [lookupCode] ke null agar QR yang sama bisa di-scan ulang.
  TransferScannerState resetLookup() {
    return TransferScannerState(
      lookupCode: null,
      isLookingUp: isLookingUp,
    );
  }
}