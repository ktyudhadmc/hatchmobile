import 'package:hatchmobile/features/transfer/domain/entities/transfer_history/entities.dart';

import '../repositories/transfer_repository.dart';

class GetAllHistoryHeaderReceive {
  GetAllHistoryHeaderReceive(this._repository);

  final TransferRepository _repository;

  Future<List<TransferHistory>> call(String startDate, String endDate) =>
      _repository.getAllHistoryHeaderReceive(startDate, endDate);
}
