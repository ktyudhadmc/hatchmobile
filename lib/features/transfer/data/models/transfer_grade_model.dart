import '../../domain/entities/transfer_grade.dart';

class TransferGradeModel extends TransferGrade {
  const TransferGradeModel({
    required super.id,
    required super.grade,
    required super.quantity,
    super.receivedQuantity,
  });

  factory TransferGradeModel.fromJson(Map<String, dynamic> json) {
    return TransferGradeModel(
      id: json['id'] as int,
      grade: json['grade'] as String,
      quantity: json['quantity'] as int,
      receivedQuantity: json['received_quantity'] as int?,
    );
  }
}
