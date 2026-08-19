import '../entities/transfer_basket.dart';
import '../repositories/transfer_repository.dart';

class ScanBasketUsecase {
  ScanBasketUsecase(this._repository);

  final TransferRepository _repository;

  Future<TransferBasket> call(String code) => _repository.getBasketByCode(code);
}
