import '../../../domain/entities/transfer_recent/transfer_recent_basket.dart';
import '../transfer_grade_model.dart';
import 'transfer_recent_blame_model.dart';

class TransferRecentBasketModel extends TransferRecentBasket {
  const TransferRecentBasketModel({
    super.id,
    required super.basketCode,
    required super.grades,
    required super.blamed,
  });

  factory TransferRecentBasketModel.fromJson(Map<String, dynamic> json) {
    return TransferRecentBasketModel(
      id: json['id'] as int?,
      basketCode: json['basket_code'] as String,
      grades: (json['grades'] as List)
          .map((e) => TransferGradeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      blamed: TransferRecentBlameModel.fromJson(
        json['log'] as Map<String, dynamic>,
      ),
    );
  }
}
