import '../repositories/transfer_repository.dart';

class CreateReceiveUsecase {
  CreateReceiveUsecase(this._repository);

  final TransferRepository _repository;

  Future<void> call({required String basketCode}) {
    return _repository.createReceive(basketCode: basketCode);
  }
}
