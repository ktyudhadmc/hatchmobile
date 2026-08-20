import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/bottom_bar_navigation.dart';
import '../../../transfer/presentation/widgets/scanned_baskets_list.dart';
import '../../../transfer/presentation/widgets/transfer_scanner_view.dart';

/// Home doubles as the scan screen — the camera is live as soon as this
/// page opens, no extra tap needed. The bottom half lists baskets already
/// confirmed this session, filling in as the user scans -> confirms ->
/// comes back here.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Basket')),
      body: const Column(
        children: [
          Expanded(child: TransferScannerView()),
          Expanded(child: ScannedBasketsList()),
        ],
      ),
      floatingActionButton: const ScanFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomBarNavigation(currentRoute: currentRoute),
    );
  }
}
