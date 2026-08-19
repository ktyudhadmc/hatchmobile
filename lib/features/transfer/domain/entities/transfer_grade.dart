class TransferGrade {
  const TransferGrade({
    required this.id,
    required this.grade,
    required this.quantity,
    required this.receivedQuantity,
  });

  final int id;
  final String grade;
  final int quantity;

  /// Value returned by the backend for this field — used to pre-fill the
  /// confirmation form, then overwritten by whatever the user enters.
  final int receivedQuantity;
}
