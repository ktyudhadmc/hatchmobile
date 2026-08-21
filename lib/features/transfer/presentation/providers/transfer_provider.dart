import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/transfer_repository_impl.dart';
import '../../domain/entities/transfer_basket.dart';
import '../../domain/entities/transfer_history_detail.dart';
import '../../domain/entities/transfer_info.dart';
import '../../domain/entities/transfer_recent/transfer_recent.dart';
import '../../domain/usecases/confirm_receive_usecase.dart';
import '../../domain/usecases/get_all_history_header_receive.dart';
import '../../domain/usecases/get_history_detail_receive_usecase.dart';
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
    state = await AsyncValue.guard(() => _usecase(code));
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
    state = await AsyncValue.guard(
      () => _usecase(
        transferId: transferId,
        transferBasketId: transferBasketId,
        grades: grades,
      ),
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
    state = await AsyncValue.guard(() => _usecase(basketCode: basketCode));
  }
}

/// Transfer headers for the Riwayat (history) list — fetched once when the
/// provider is first read, same eager pattern as [receivedBasketsProvider].
final historyHeadersProvider =
    StateNotifierProvider<HistoryHeadersNotifier, AsyncValue<List<TransferInfo>>>((
      ref,
    ) {
      return HistoryHeadersNotifier(
        GetAllHistoryHeaderReceive(ref.watch(transferRepositoryProvider)),
      )..fetch();
    });

class HistoryHeadersNotifier
    extends StateNotifier<AsyncValue<List<TransferInfo>>> {
  HistoryHeadersNotifier(this._usecase) : super(const AsyncValue.loading());

  final GetAllHistoryHeaderReceive _usecase;

  Future<void> fetch() async {
    state = await AsyncValue.guard(_usecase.call);
  }
}

/// Free-text search over the Riwayat header list — matched client-side
/// against transfer code / branch, since [historyHeadersProvider] already
/// holds the full list.
final historySearchQueryProvider = StateProvider<String>((ref) => '');

/// "Last N months" filter for the Riwayat header list — one of 1, 3, 6.
final historyMonthsFilterProvider = StateProvider<int>((ref) => 1);

/// [historyHeadersProvider], narrowed by [historySearchQueryProvider] and
/// [historyMonthsFilterProvider].
final filteredHistoryHeadersProvider = Provider<List<TransferInfo>>((ref) {
  final headers = ref.watch(historyHeadersProvider).valueOrNull ?? const [];
  final query = ref.watch(historySearchQueryProvider).trim().toLowerCase();
  final months = ref.watch(historyMonthsFilterProvider);

  final cutoff = DateTime.now().subtract(Duration(days: months * 30));

  return headers.where((header) {
    final matchesQuery =
        query.isEmpty ||
        header.transferCode.toLowerCase().contains(query) ||
        header.branch.toLowerCase().contains(query);
    final matchesRange = !header.transferDate.isBefore(cutoff);
    return matchesQuery && matchesRange;
  }).toList();
});

/// Which history pill is currently selected, by `transferCode`.
final selectedTransferCodeProvider = StateProvider<String?>((ref) => null);

final historyDetailProvider =
    StateNotifierProvider<
      HistoryDetailNotifier,
      AsyncValue<TransferHistoryDetail?>
    >((ref) {
      return HistoryDetailNotifier(
        GetHistoryDetailReceiveUsecase(ref.watch(transferRepositoryProvider)),
      );
    });

class HistoryDetailNotifier
    extends StateNotifier<AsyncValue<TransferHistoryDetail?>> {
  HistoryDetailNotifier(this._usecase) : super(const AsyncValue.data(null));

  final GetHistoryDetailReceiveUsecase _usecase;

  Future<void> load(String transferCode) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _usecase(transferCode));
  }
}
