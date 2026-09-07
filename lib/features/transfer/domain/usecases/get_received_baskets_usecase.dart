import '../entities/transfer_basket.dart';
import '../repositories/transfer_repository.dart';

class GetReceivedBasketsUsecase {
  GetReceivedBasketsUsecase(this._repository);

  final TransferRepository _repository;

  Future<List<TransferBasket>> call() => _repository.getReceivedBaskets();
}
