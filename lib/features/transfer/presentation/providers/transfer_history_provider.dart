import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../data/repositories/transfer_repository_impl.dart';
import '../../domain/entities/transfer_history/entities.dart';
import '../../domain/usecases/get_all_history_header_receive.dart';
import '../../domain/usecases/get_history_detail_receive_usecase.dart';

DateTimeRange _defaultHistoryDateRange() {
  final today = DateFormatter.dateOnly(DateTime.now());
  return DateTimeRange(start: today, end: today);
}

/// [start, end] date filter for the Riwayat header list — sent to the
/// backend as `start_date`/`end_date` (Y-m-d) on the riwayat-header
/// endpoint. Defaults to the last 7 days.
final historyDateRangeProvider = StateProvider<DateTimeRange>(
  (ref) => _defaultHistoryDateRange(),
);

/// Transfer headers for the Riwayat (history) list, filtered server-side by
/// [historyDateRangeProvider]. Refetches whenever the range changes.
final historyHeadersProvider =
    StateNotifierProvider<
      HistoryHeadersNotifier,
      AsyncValue<List<TransferHistory>>
    >((ref) {
      final range = ref.watch(historyDateRangeProvider);
      return HistoryHeadersNotifier(
        GetAllHistoryHeaderReceive(ref.watch(transferRepositoryProvider)),
        startDate: DateFormatter.toApiFormat(range.start),
        endDate: DateFormatter.toApiFormat(range.end),
      )..fetch();
    });

class HistoryHeadersNotifier
    extends StateNotifier<AsyncValue<List<TransferHistory>>> {
  HistoryHeadersNotifier(
    this._usecase, {
    required this.startDate,
    required this.endDate,
  }) : super(const AsyncValue.loading());

  final GetAllHistoryHeaderReceive _usecase;
  final String startDate;
  final String endDate;

  Future<void> fetch() async {
    state = await AsyncValue.guard(() => _usecase(startDate, endDate));
  }
}

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
