import '../../domain/entities/transfer_basket.dart';
import 'transfer_grade_model.dart';
import 'transfer_info_model.dart';

class TransferBasketModel extends TransferBasket {
  const TransferBasketModel({
    required super.id,
    required super.basketCode,
    required super.grades,
    required super.transfer,
  });

  factory TransferBasketModel.fromJson(Map<String, dynamic> json) {
    return TransferBasketModel(
      id: json['id'] as int,
      basketCode: json['basket_code'] as String,
      grades: (json['grades'] as List)
          .map((e) => TransferGradeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      transfer: TransferInfoModel.fromJson(
        json['transfer'] as Map<String, dynamic>,
      ),
    );
  }

  static List<TransferBasketModel> fromJsonList(List<dynamic> json) {
    return json
        .map((e) => TransferBasketModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
