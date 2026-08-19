import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/transfer_repository_impl.dart';
import '../../domain/entities/transfer_basket.dart';
import '../../domain/usecases/confirm_receive_usecase.dart';
import '../../domain/usecases/scan_basket_usecase.dart';

final scanBasketProvider = StateNotifierProvider<ScanBasketNotifier, AsyncValue<TransferBasket?>>((ref) {
  return ScanBasketNotifier(ScanBasketUsecase(ref.watch(transferRepositoryProvider)));
});

class ScanBasketNotifier extends StateNotifier<AsyncValue<TransferBasket?>> {
  ScanBasketNotifier(this._usecase) : super(const AsyncValue.data(null));

  final ScanBasketUsecase _usecase;

  Future<void> scan(String code) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _usecase(code));
  }
}

final confirmReceiveProvider = StateNotifierProvider<ConfirmReceiveNotifier, AsyncValue<void>>((ref) {
  return ConfirmReceiveNotifier(ConfirmReceiveUsecase(ref.watch(transferRepositoryProvider)));
});

class ConfirmReceiveNotifier extends StateNotifier<AsyncValue<void>> {
  ConfirmReceiveNotifier(this._usecase) : super(const AsyncValue.data(null));

  final ConfirmReceiveUsecase _usecase;

  Future<void> confirm({
    required int transferId,
    required int transferBasketId,
    required List<({int id, int receivedQuantity})> grades,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _usecase(transferId: transferId, transferBasketId: transferBasketId, grades: grades),
    );
  }
}
