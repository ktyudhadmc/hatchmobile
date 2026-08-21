import '../../domain/entities/transfer_grade.dart';

class TransferGradeModel extends TransferGrade {
  const TransferGradeModel({
    super.id,
    required super.grade,
    required super.quantity,
    super.receivedQuantity,
  });

  factory TransferGradeModel.fromJson(Map<String, dynamic> json) {
    return TransferGradeModel(
      id: json['id'] as int?,
      grade: json['grade'] as String,
      quantity: json['quantity'] as int,
      receivedQuantity: json['received_quantity'] as int?,
    );
  }

  static List<TransferGradeModel> fromJsonList(List<dynamic> json) {
    return json
        .map((e) => TransferGradeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
