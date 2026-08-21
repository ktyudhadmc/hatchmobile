import '../../../domain/entities/transfer_recent/transfer_recent.dart';
import 'transfer_recent_basket_model.dart';

class TransferRecentModel extends TransferRecent {
  const TransferRecentModel({
    super.id,
    required super.transferCode,
    required super.transferDate,
    required super.productionDate,
    required super.branch,
    super.sentbasketCount,
    super.receivedBasketCount,
    super.baskets,
  });

  factory TransferRecentModel.fromJson(Map<String, dynamic> json) {
    return TransferRecentModel(
      id: json['id'] as int?,
      transferCode: json['transfer_code'] as String,
      transferDate: DateTime.parse(
        (json['transfer_date'] ?? json['production_date']) as String,
      ),
      productionDate: DateTime.parse(json['production_date'] as String),
      branch: json['farm'] as String,
      sentbasketCount: json['basket_shipped'] as int?,
      receivedBasketCount: json['basket_received'] as int?,
      baskets: json['items'] == null
          ? null
          : (json['items'] as List)
                .map(
                  (e) => TransferRecentBasketModel.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList(),
    );
  }

  static List<TransferRecentModel> fromJsonList(List<dynamic> json) {
    return json
        .map((e) => TransferRecentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
