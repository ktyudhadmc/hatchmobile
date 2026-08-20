class TransferInfo {
  const TransferInfo({
    required this.id,
    required this.transferCode,
    required this.transferDate,
    required this.productionDate,
    required this.branch,
  });

  final int id;
  final String transferCode;
  final DateTime transferDate;
  final DateTime productionDate;
  final String branch;
}
