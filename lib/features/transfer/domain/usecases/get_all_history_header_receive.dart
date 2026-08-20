import '../entities/transfer_info.dart';
import '../repositories/transfer_repository.dart';

class GetAllHistoryHeaderReceive {
  GetAllHistoryHeaderReceive(this._repository);

  final TransferRepository _repository;

  Future<List<TransferInfo>> call() => _repository.getAllHistoryHeaderReceive();
}
