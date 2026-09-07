import 'transfer_recent_basket.dart';

class TransferRecent {
  const TransferRecent({
    this.id,
    required this.transferCode,
    required this.transferDate,
    required this.productionDate,
    required this.branch,
    this.sentbasketCount,
    this.receivedBasketCount,
    this.baskets,
  });

  final int? id;
  final String transferCode;
  final DateTime transferDate;
  final DateTime productionDate;
  final String branch;
  final int? sentbasketCount;
  final int? receivedBasketCount;
  final List<TransferRecentBasket>? baskets;
}
