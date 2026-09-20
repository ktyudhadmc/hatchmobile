import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/dev_log.dart';
import '../../data/repositories/transfer_repository_impl.dart';
import '../../domain/entities/transfer_basket.dart';
import '../../domain/entities/transfer_recent/transfer_recent.dart';
import '../../domain/usecases/confirm_receive_usecase.dart';
import '../../domain/usecases/get_received_baskets_usecase.dart';
import '../../domain/usecases/get_recents_receive_usecase.dart';
import '../../domain/usecases/scan_basket_usecase.dart';
import '../../domain/usecases/create_receive_usecase.dart';

final scanBasketProvider =
    StateNotifierProvider<ScanBasketNotifier, AsyncValue<TransferBasket?>>((
      ref,
    ) {
      return ScanBasketNotifier(
        ScanBasketUsecase(ref.watch(transferRepositoryProvider)),
      );
    });

class ScanBasketNotifier extends StateNotifier<AsyncValue<TransferBasket?>> {
  ScanBasketNotifier(this._usecase) : super(const AsyncValue.data(null));

  final ScanBasketUsecase _usecase;

  Future<void> scan(String code) async {
    state = const AsyncValue.loading();
    DevLog.instance.add(DevLogTag.api, 'GET basket $code ...');
    state = await AsyncValue.guard(() => _usecase(code));
    state.when(
      data: (basket) => DevLog.instance.add(
        DevLogTag.api,
        'GET basket $code sukses (${basket?.basketCode ?? 'not found'})',
        level: DevLogLevel.success,
      ),
      error: (error, _) => DevLog.instance.add(
        DevLogTag.api,
        'GET basket $code gagal: $error',
        level: DevLogLevel.error,
      ),
      loading: () {},
    );
  }
}

/// Baskets this hatchery has received, fetched from the backend — sole
/// source of truth for the recap header and list on Home. No local
/// tracking: a failed confirm just shows an error, nothing is cached
/// client-side, and this list simply doesn't include it until the next
/// successful confirm triggers a refetch.
final receivedBasketsProvider =
    StateNotifierProvider<
      ReceivedBasketsNotifier,
      AsyncValue<List<TransferBasket>>
    >((ref) {
      return ReceivedBasketsNotifier(
        GetReceivedBasketsUsecase(ref.watch(transferRepositoryProvider)),
      )..fetch();
    });

class ReceivedBasketsNotifier
    extends StateNotifier<AsyncValue<List<TransferBasket>>> {
  ReceivedBasketsNotifier(this._usecase) : super(const AsyncValue.loading());

  final GetReceivedBasketsUsecase _usecase;

  Future<void> fetch() async {
    state = await AsyncValue.guard(_usecase.call);
  }
}

/// Ongoing/recent receive sessions — each with the baskets already received
/// under it, blame (who + when) included. Backs the "Keranjang diterima"
/// sheet on the scan page.
final recentsReceiveProvider =
    StateNotifierProvider<
      RecentsReceiveNotifier,
      AsyncValue<List<TransferRecent>>
    >((ref) {
      return RecentsReceiveNotifier(
        GetRecentsReceiveUsecase(ref.watch(transferRepositoryProvider)),
      )..fetch();
    });

class RecentsReceiveNotifier
    extends StateNotifier<AsyncValue<List<TransferRecent>>> {
  RecentsReceiveNotifier(this._usecase) : super(const AsyncValue.loading());

  final GetRecentsReceiveUsecase _usecase;

  Future<void> fetch() async {
    state = await AsyncValue.guard(_usecase.call);
  }
}

final confirmReceiveProvider =
    StateNotifierProvider<ConfirmReceiveNotifier, AsyncValue<void>>((ref) {
      return ConfirmReceiveNotifier(
        ConfirmReceiveUsecase(ref.watch(transferRepositoryProvider)),
      );
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
    DevLog.instance.add(
      DevLogTag.api,
      'POST confirmReceive basket $transferBasketId ...',
    );
    state = await AsyncValue.guard(
      () => _usecase(
        transferId: transferId,
        transferBasketId: transferBasketId,
        grades: grades,
      ),
    );
    state.when(
      data: (_) => DevLog.instance.add(
        DevLogTag.api,
        'POST confirmReceive basket $transferBasketId sukses',
        level: DevLogLevel.success,
      ),
      error: (error, _) => DevLog.instance.add(
        DevLogTag.api,
        'POST confirmReceive basket $transferBasketId gagal: $error',
        level: DevLogLevel.error,
      ),
      loading: () {},
    );
  }
}

final createReceiveProvider =
    StateNotifierProvider<CreateReceiveNotifier, AsyncValue<void>>((ref) {
      return CreateReceiveNotifier(
        CreateReceiveUsecase(ref.watch(transferRepositoryProvider)),
      );
    });

class CreateReceiveNotifier extends StateNotifier<AsyncValue<void>> {
  CreateReceiveNotifier(this._usecase) : super(const AsyncValue.data(null));

  final CreateReceiveUsecase _usecase;

  Future<void> create({required String basketCode}) async {
    state = const AsyncValue.loading();
    DevLog.instance.add(
      DevLogTag.api,
      'POST createReceive basket $basketCode ...',
    );
    state = await AsyncValue.guard(() => _usecase(basketCode: basketCode));
    state.when(
      data: (_) => DevLog.instance.add(
        DevLogTag.api,
        'POST createReceive basket $basketCode sukses',
        level: DevLogLevel.success,
      ),
      error: (error, _) => DevLog.instance.add(
        DevLogTag.api,
        'POST createReceive basket $basketCode gagal: $error',
        level: DevLogLevel.error,
      ),
      loading: () {},
    );
  }
}

