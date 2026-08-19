import '../../domain/entities/transfer_branch.dart';

class TransferBranchModel extends TransferBranch {
  const TransferBranchModel({required super.id, required super.name});

  factory TransferBranchModel.fromJson(Map<String, dynamic> json) {
    return TransferBranchModel(id: json['id'] as int, name: json['name'] as String);
  }
}
