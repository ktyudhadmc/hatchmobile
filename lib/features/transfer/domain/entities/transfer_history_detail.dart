import 'transfer_branch.dart';
import 'transfer_history_basket.dart';

class TransferHistoryDetail {
  const TransferHistoryDetail({
    required this.id,
    required this.transferCode,
    required this.transferDate,
    required this.basketSendCount,
    required this.basketReceiveCount,
    required this.branch,
    required this.baskets,
  });

  final int id;
  final String transferCode;
  final DateTime transferDate;
  final int basketSendCount;
  final int basketReceiveCount;
  final TransferBranch branch;
  final List<TransferHistoryBasket> baskets;
}
