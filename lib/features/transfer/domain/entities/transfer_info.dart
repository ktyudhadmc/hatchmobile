import 'transfer_branch.dart';

class TransferInfo {
  const TransferInfo({
    required this.id,
    required this.transferCode,
    required this.transferDate,
    required this.branch,
  });

  final int id;
  final String transferCode;
  final DateTime transferDate;
  final TransferBranch branch;
}
