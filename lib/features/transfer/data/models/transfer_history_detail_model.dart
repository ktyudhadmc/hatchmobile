import '../../domain/entities/transfer_history_detail.dart';
import 'transfer_branch_model.dart';
import 'transfer_history_basket_model.dart';

class TransferHistoryDetailModel extends TransferHistoryDetail {
  const TransferHistoryDetailModel({
    required super.id,
    required super.transferCode,
    required super.transferDate,
    required super.basketSendCount,
    required super.basketReceiveCount,
    required super.branch,
    required super.baskets,
  });

  factory TransferHistoryDetailModel.fromJson(Map<String, dynamic> json) {
    return TransferHistoryDetailModel(
      id: json['id'] as int,
      transferCode: json['transfer_code'] as String,
      transferDate: DateTime.parse(json['transfer_date'] as String),
      basketSendCount: json['basket_send_count'] as int,
      basketReceiveCount: json['basket_receive_count'] as int,
      branch: TransferBranchModel.fromJson(
        json['branch'] as Map<String, dynamic>,
      ),
      baskets: (json['baskets'] as List)
          .map(
            (e) => TransferHistoryBasketModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}
