import 'package:hatchmobile/core/utils/date_formatter.dart';
import 'package:hatchmobile/features/transfer/data/models/transfer_grade_model.dart';
import 'package:hatchmobile/features/transfer/domain/entities/transfer_history/entities.dart';

class TransferHistoryDetailModel extends TransferHistoryDetail {
  const TransferHistoryDetailModel({
    super.id,
    required super.basketCode,
    required super.receivedAt,
    required super.grades,
  });

  factory TransferHistoryDetailModel.fromJson(Map<String, dynamic> json) {
    final log = json['log'] as Map<String, dynamic>?;

    return TransferHistoryDetailModel(
      id: json['id'] as int?,
      basketCode: json['basket_code'] as String,
      receivedAt: DateFormatter.tryParse(log?['received_at'] as String?),
      grades: TransferGradeModel.fromJsonList(json['grades'] as List),
    );
  }

  static List<TransferHistoryDetailModel> fromJsonList(List<dynamic> json) {
    return json
        .map(
          (e) => TransferHistoryDetailModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }
}
