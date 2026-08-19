import '../../domain/entities/transfer_info.dart';
import 'transfer_branch_model.dart';

class TransferInfoModel extends TransferInfo {
  const TransferInfoModel({
    required super.id,
    required super.transferCode,
    required super.transferDate,
    required super.branch,
  });

  factory TransferInfoModel.fromJson(Map<String, dynamic> json) {
    return TransferInfoModel(
      id: json['id'] as int,
      transferCode: json['transfer_code'] as String,
      transferDate: DateTime.parse(json['transfer_date'] as String),
      branch: TransferBranchModel.fromJson(json['branch'] as Map<String, dynamic>),
    );
  }
}
