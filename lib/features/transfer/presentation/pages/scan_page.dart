import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/transfer_provider.dart';
import '../widgets/scan_top_bar.dart';
import '../widgets/scanned_baskets_list.dart';
import '../widgets/transfer_scanner_view.dart';

/// App's launch screen — the camera is live as soon as this page opens, no
/// extra tap needed. A draggable sheet lists baskets already confirmed this
/// session, filling in as the user scans -> confirms -> comes back here.
class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  // Owned here (rather than inside TransferScannerView) so the top bar's
  // torch button can drive the same camera session.
  final _scannerController = MobileScannerController();

  @override
  void initState() {
    super.initState();

    // recentsReceiveProvider only fetches once, on first creation — it's a
    // long-lived singleton, not re-created per navigation. Without this,
    // reopening /scan just shows whatever it last held, even if the
    // backend's "ongoing" list has since shrunk/grown for reasons outside
    // the local confirm flow (which is the only other place that refetches).
    ref.read(recentsReceiveProvider.notifier).fetch();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  /// Dev-only shortcut: pretend a QR was scanned and feed the code straight
  /// into the same [scanBasketProvider] flow a real detection would, so the
  /// rest of the pipeline (GET basket -> confirm page -> POST) is exercised
  /// against the real backend without needing a physical QR code.
  Future<void> _onMockScan() async {
    final controller = TextEditingController(text: 'A0001');

    final code = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mock scan'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Basket code'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('BATAL'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('SCAN'),
          ),
        ],
      ),
    );

    if (code == null || code.isEmpty) return;

    ref.read(scanBasketProvider.notifier).scan(code);
  }

  @override
  Widget build(BuildContext context) {
    final transfers = ref.watch(recentsReceiveProvider).valueOrNull;

    final receivedBasketCount =
        transfers?.fold<int>(
          0,
          (sum, t) => sum + (t.receivedBasketCount ?? t.baskets?.length ?? 0),
        ) ??
        0;

    final sentBasketCount =
        transfers?.fold<int>(0, (sum, t) => sum + (t.sentbasketCount ?? 0)) ??
        0;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: TransferScannerView(controller: _scannerController),
          ),
          SafeArea(
            child: ScanTopBar(
              controller: _scannerController,
              sentCount: sentBasketCount,
              receivedCount: receivedBasketCount,
              onBack: () => context.go('/home'),
              debugAction: kDebugMode
                  ? RoundIconButton(
                      icon: Icons.bug_report,
                      backgroundColor: AppTheme.warningColor,
                      iconColor: Colors.white,
                      onTap: _onMockScan,
                    )
                  : null,
            ),
          ),
          const ScannedBasketsList(),
        ],
      ),
    );
  }
}
