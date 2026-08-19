import '../entities/transfer_basket.dart';

abstract class TransferRepository {
  Future<TransferBasket> getBasketByCode(String code);

  Future<void> confirmReceive({
    required int transferId,
    required int transferBasketId,
    required List<({int id, int receivedQuantity})> grades,
  });
}
