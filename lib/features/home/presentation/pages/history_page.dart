import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/bottom_bar_navigation.dart';
import '../../../../shared/widgets/refreshable_view.dart';
import '../../../transfer/presentation/providers/transfer_provider.dart';
import '../widgets/history_detail_view.dart';
import '../widgets/history_filter_pills.dart';

/// Beranda — history of past transfers. Pills are built from
/// [historyHeadersProvider]; picking one loads its detail (sent vs.
/// received basket/grade counts) via [historyDetailProvider]. A single
/// header auto-selects itself, no tap needed.
class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  void _select(WidgetRef ref, String transferCode) {
    ref.read(selectedTransferCodeProvider.notifier).state = transferCode;
    ref.read(historyDetailProvider.notifier).load(transferCode);
  }

  Future<void> _refresh(WidgetRef ref) async {
    final selected = ref.read(selectedTransferCodeProvider);

    await Future.wait([
      ref.read(historyHeadersProvider.notifier).fetch(),
      if (selected != null) ref.read(historyDetailProvider.notifier).load(selected),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final headers = ref.watch(historyHeadersProvider);
    final selected = ref.watch(selectedTransferCodeProvider);
    final detail = ref.watch(historyDetailProvider);

    ref.listen(historyHeadersProvider, (previous, next) {
      next.whenData((value) {
        if (value.length == 1 && selected != value.first.transferCode) {
          _select(ref, value.first.transferCode);
        }
      });
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Penerimaan')),
      body: Column(
        children: [
          if (headers.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            HistoryFilterPills(
              headers: headers.valueOrNull ?? const [],
              selectedTransferCode: selected,
              onSelect: (code) => _select(ref, code),
            ),
          Expanded(
            child: RefreshableView(
              onRefresh: () => _refresh(ref),
              child: HistoryDetailView(
                detail: detail,
                hasHeaders: (headers.valueOrNull ?? const []).isNotEmpty,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: const ScanFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomBarNavigation(currentRoute: currentRoute),
    );
  }
}
