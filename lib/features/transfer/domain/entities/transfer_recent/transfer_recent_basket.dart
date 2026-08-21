import '../transfer_grade.dart';
import 'transfer_recent_log.dart';

class TransferRecentBasket {
  const TransferRecentBasket({
    this.id,
    required this.basketCode,
    required this.grades,
    required this.blamed,
  });

  final int? id;
  final String basketCode;
  final List<TransferGrade> grades;
  final TransferRecentBlame blamed;
}
