import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/bottom_bar_navigation.dart';
import '../../../../shared/widgets/refreshable_view.dart';
import '../../../transfer/presentation/providers/transfer_history_provider.dart';
import '../widgets/history_header_list.dart';
import '../widgets/history_search_filter_bar.dart';

/// Riwayat — history of past transfers. Search + "last N months" narrow
/// [historyHeadersProvider]'s list; tapping a header will open its detail
/// (transfer info + basket list) in a follow-up.
class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Column(
        children: [
          const HistorySearchFilterBar(),
          Expanded(
            child: RefreshableView(
              onRefresh: () =>
                  ref.read(historyHeadersProvider.notifier).fetch(),
              child: const HistoryHeaderList(),
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
