import '../entities/transfer_recent/transfer_recent.dart';
import '../repositories/transfer_repository.dart';

class GetRecentsReceiveUsecase {
  GetRecentsReceiveUsecase(this._repository);

  final TransferRepository _repository;

  Future<List<TransferRecent>> call() => _repository.getRecentsReceive();
}
