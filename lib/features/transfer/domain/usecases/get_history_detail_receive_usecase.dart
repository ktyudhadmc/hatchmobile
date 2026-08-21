import 'package:hatchmobile/features/transfer/domain/entities/transfer_history/entities.dart';

import '../repositories/transfer_repository.dart';

class GetHistoryDetailReceiveUsecase {
  GetHistoryDetailReceiveUsecase(this._repository);

  final TransferRepository _repository;

  Future<List<TransferHistoryDetail>> call(String transferCode) =>
      _repository.getHistoryDetailReceive(transferCode);
}
