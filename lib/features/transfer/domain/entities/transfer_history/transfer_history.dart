class TransferHistory {
  const TransferHistory({
    this.id,
    required this.transferCode,
    required this.transferDate,
    required this.productionDate,
    required this.branch,
    this.sentbasketCount,
    this.receivedBasketCount,
  });

  final int? id;
  final String transferCode;
  final DateTime transferDate;
  final DateTime productionDate;
  final String branch;
  final int? sentbasketCount;
  final int? receivedBasketCount;

  int get basketRemaining =>
      (sentbasketCount ?? 0) - (receivedBasketCount ?? 0);

  bool get isComplete => basketRemaining == 0;
}
