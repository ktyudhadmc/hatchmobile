import '../transfer_grade.dart';

class TransferHistoryDetail {
  const TransferHistoryDetail({
    this.id,
    required this.basketCode,
    required this.receivedAt,
    required this.grades,
  });

  final int? id;
  final String basketCode;
  final DateTime? receivedAt;
  final List<TransferGrade> grades;
}
