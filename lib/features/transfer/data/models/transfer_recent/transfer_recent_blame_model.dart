import '../../../domain/entities/transfer_recent/transfer_recent_log.dart';

class TransferRecentBlameModel extends TransferRecentBlame {
  const TransferRecentBlameModel({
    required super.receivedBy,
    required super.receivedAt,
  });

  factory TransferRecentBlameModel.fromJson(Map<String, dynamic> json) {
    return TransferRecentBlameModel(
      receivedBy: json['received_by'] as String,
      receivedAt: DateTime.parse(json['received_at'] as String),
    );
  }
}
