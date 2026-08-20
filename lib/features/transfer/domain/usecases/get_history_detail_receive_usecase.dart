import '../entities/transfer_history_detail.dart';
import '../repositories/transfer_repository.dart';

class GetHistoryDetailReceiveUsecase {
  GetHistoryDetailReceiveUsecase(this._repository);

  final TransferRepository _repository;

  Future<TransferHistoryDetail> call(String transferCode) =>
      _repository.getHistoryDetailReceive(transferCode);
}
