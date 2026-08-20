import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/transfer_history_basket.dart';
import 'transfer_grade_model.dart';

class TransferHistoryBasketModel extends TransferHistoryBasket {
  const TransferHistoryBasketModel({
    required super.id,
    required super.basketCode,
    required super.receivedAt,
    required super.grades,
  });

  factory TransferHistoryBasketModel.fromJson(Map<String, dynamic> json) {
    return TransferHistoryBasketModel(
      id: json['id'] as int,
      basketCode: json['basket_code'] as String,
      receivedAt: DateFormatter.tryParse(json['received_at'] as String?),
      grades: (json['grades'] as List)
          .map((e) => TransferGradeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
