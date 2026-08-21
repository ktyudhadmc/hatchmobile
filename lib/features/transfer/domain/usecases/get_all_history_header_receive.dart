import 'package:hatchmobile/features/transfer/domain/entities/transfer_history/entities.dart';

import '../repositories/transfer_repository.dart';

class GetAllHistoryHeaderReceive {
  GetAllHistoryHeaderReceive(this._repository);

  final TransferRepository _repository;

  Future<List<TransferHistory>> call({required int range}) =>
      _repository.getAllHistoryHeaderReceive(range: range);
}
