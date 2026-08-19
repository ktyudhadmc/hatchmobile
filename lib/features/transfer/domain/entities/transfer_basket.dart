import 'transfer_grade.dart';
import 'transfer_info.dart';

class TransferBasket {
  const TransferBasket({
    required this.id,
    required this.basketCode,
    required this.grades,
    required this.transfer,
  });

  final int id;
  final String basketCode;
  final List<TransferGrade> grades;
  final TransferInfo transfer;
}
