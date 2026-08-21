import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/transfer_repository_impl.dart';
import '../../domain/entities/transfer_history/entities.dart';
import '../../domain/usecases/get_all_history_header_receive.dart';
import '../../domain/usecases/get_history_detail_receive_usecase.dart';

/// "Last N months" filter for the Riwayat header list — one of 1, 3, 6. Sent
/// to the backend as the `range` query param on the riwayat-header endpoint.
final historyMonthsFilterProvider = StateProvider<int>((ref) => 1);

/// Transfer headers for the Riwayat (history) list, filtered server-side by
/// [historyMonthsFilterProvider]. Refetches whenever the range changes.
final historyHeadersProvider =
    StateNotifierProvider<
      HistoryHeadersNotifier,
      AsyncValue<List<TransferHistory>>
    >((ref) {
      final range = ref.watch(historyMonthsFilterProvider);
      return HistoryHeadersNotifier(
        GetAllHistoryHeaderReceive(ref.watch(transferRepositoryProvider)),
        range: range,
      )..fetch();
    });

class HistoryHeadersNotifier
    extends StateNotifier<AsyncValue<List<TransferHistory>>> {
  HistoryHeadersNotifier(this._usecase, {required this.range})
    : super(const AsyncValue.loading());

  final GetAllHistoryHeaderReceive _usecase;
  final int range;

  Future<void> fetch() async {
    state = await AsyncValue.guard(() => _usecase(range: range));
  }
}

/// Free-text search over the Riwayat header list — matched client-side
/// against transfer code / branch, since [historyHeadersProvider] already
/// holds the range-filtered list from the backend.
final historySearchQueryProvider = StateProvider<String>((ref) => '');

/// [historyHeadersProvider], narrowed by [historySearchQueryProvider].
final filteredHistoryHeadersProvider = Provider<List<TransferHistory>>((ref) {
  final headers = ref.watch(historyHeadersProvider).valueOrNull ?? const [];
  final query = ref.watch(historySearchQueryProvider).trim().toLowerCase();

  if (query.isEmpty) return headers;

  return headers
      .where(
        (header) =>
            header.transferCode.toLowerCase().contains(query) ||
            header.branch.toLowerCase().contains(query),
      )
      .toList();
});

/// Which history header is currently open in the detail sheet, by
/// `transferCode`.
final selectedTransferCodeProvider = StateProvider<String?>((ref) => null);

/// Baskets received under the selected transfer — fetched from the
/// riwayat-detail endpoint via [HistoryDetailNotifier.load] once a header is
/// tapped. The summary info (code/date/branch/counts) doesn't come from
/// here; it's already on hand from the tapped [TransferHistory] header.
final historyDetailProvider =
    StateNotifierProvider<
      HistoryDetailNotifier,
      AsyncValue<List<TransferHistoryDetail>>
    >((ref) {
      return HistoryDetailNotifier(
        GetHistoryDetailReceiveUsecase(ref.watch(transferRepositoryProvider)),
      );
    });

class HistoryDetailNotifier
    extends StateNotifier<AsyncValue<List<TransferHistoryDetail>>> {
  HistoryDetailNotifier(this._usecase) : super(const AsyncValue.data([]));

  final GetHistoryDetailReceiveUsecase _usecase;

  Future<void> load(String transferCode) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _usecase(transferCode));
  }
}
