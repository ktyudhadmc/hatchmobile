import 'package:hatchmobile/features/transfer/domain/entities/transfer_info.dart';

import '../entities/transfer_basket.dart';

abstract class TransferRepository {
  Future<TransferBasket> getBasketByCode(String code);

  Future<void> confirmReceive({
    required int transferId,
    required int transferBasketId,
    required List<({int id, int receivedQuantity})> grades,
  });

  // ADJUSTMENT
  Future<void> createReceive({required String basketCode});

  /// Baskets this hatchery has already received, per the backend — used
  /// for the recap header on the scan list. Callers should treat a failure
  /// here as "not available yet" rather than a hard error.
  Future<List<TransferBasket>> getReceivedBaskets();

  // GET ALL TRANSFER HISTORY
  Future<List<TransferInfo>> getAllHistoryHeaderReceive();
}
