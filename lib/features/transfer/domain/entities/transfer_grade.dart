class TransferGrade {
  const TransferGrade({
    this.id,
    required this.grade,
    required this.quantity,
    this.receivedQuantity,
    this.henhouse,
  });

  final int? id;
  final String grade;
  final int quantity;

  /// Value returned by the backend for this field — used to pre-fill the
  /// confirmation form, then overwritten by whatever the user enters.
  final int? receivedQuantity;
  final String? henhouse;
}
