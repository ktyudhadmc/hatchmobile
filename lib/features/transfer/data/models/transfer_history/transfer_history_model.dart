import 'package:hatchmobile/features/transfer/domain/entities/transfer_history/transfer_history.dart';

class TransferHistoryModel extends TransferHistory {
  const TransferHistoryModel({
    super.id,
    required super.transferCode,
    required super.transferDate,
    required super.productionDate,
    required super.branch,
    super.sentbasketCount,
    super.receivedBasketCount,
  });

  factory TransferHistoryModel.fromJson(Map<String, dynamic> json) {
    return TransferHistoryModel(
      id: json['id'] as int?,
      transferCode: json['transfer_code'] as String,
      transferDate: DateTime.parse(
        (json['transfer_date'] ?? json['production_date']) as String,
      ),
      productionDate: DateTime.parse(json['production_date'] as String),
      branch: json['farm'] as String,
      sentbasketCount: json['basket_shipped'] as int?,
      receivedBasketCount: json['basket_received'] as int?,
    );
  }

  static List<TransferHistoryModel> fromJsonList(List<dynamic> json) {
    return json
        .map((e) => TransferHistoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
