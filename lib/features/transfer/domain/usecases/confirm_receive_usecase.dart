import '../repositories/transfer_repository.dart';

class ConfirmReceiveUsecase {
  ConfirmReceiveUsecase(this._repository);

  final TransferRepository _repository;

  Future<void> call({
    required int transferId,
    required int transferBasketId,
    required List<({int id, int receivedQuantity})> grades,
  }) {
    return _repository.confirmReceive(
      transferId: transferId,
      transferBasketId: transferBasketId,
      grades: grades,
    );
  }
}
