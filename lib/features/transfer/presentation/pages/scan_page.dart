import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/dev_log.dart';
import '../../../../shared/widgets/form/pin_code_input.dart';
import '../../../../shared/widgets/scanner/scanner_view.dart';
import '../../domain/entities/transfer_basket.dart';
import '../providers/transfer_provider.dart';
import '../widgets/scanner/transfer_scanner_controller.dart';
import '../widgets/transfer_not_found_sheet.dart';
import '../widgets/transfer_receive_sheet.dart';
import '../widgets/transfer_scanner_view.dart';

/// App's launch screen — the camera is live as soon as this page opens, no
/// extra tap needed.
class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  // Owned here (instead of letting TransferScannerView create its own) so
  // the torch action in the AppBar can control the same camera session.
  late final MobileScannerController _controller =
      buildTransferScannerController();

  TransferBasket? _scannedBasket;
  bool _basketNotFound = false;
  String _notFoundCode = '';
  bool _isMockDialogOpen = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _resumeScanning() {
    setState(() {
      _scannedBasket = null;
      _basketNotFound = false;
    });
  }

  /// Manual entry shortcut: pretend a QR was scanned and feed the code
  /// straight into the same [scanBasketProvider] flow a real detection
  /// would, so the rest of the pipeline (GET basket -> receive sheet ->
  /// POST) can be exercised without needing a physical QR code. Basket
  /// codes are always "A" + a 4-digit number, so "A" is a fixed prefix and
  /// only the digits are entered, PIN-field style.
  Future<void> _onMockScan() async {
    final pinController = TextEditingController();

    final screenHeight = MediaQuery.of(context).size.height;

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    );

    setState(() => _isMockDialogOpen = true);

    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Basket Code',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: AppTheme.fontFamily,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 16),
              PinCodeInput(
                prefix: 'A',
                length: 4,
                fontSize: screenHeight * 0.026,
                fieldHeight: screenHeight * 0.04,
                controller: pinController,
                onCompleted: (pin) => Navigator.of(context).pop('A$pin'),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).pop('A${pinController.text.trim()}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: buttonShape,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'SEARCH',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                    shape: buttonShape,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'BACK',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (mounted) setState(() => _isMockDialogOpen = false);

    if (code == null || code.length <= 1) return;

    DevLog.instance.add(
      DevLogTag.scanner,
      'Kode basket dimasukkan manual: $code',
      source: 'ScanPage._onMockScan (input manual, bukan kamera)',
    );
    ref.read(scanBasketProvider.notifier).scan(code);
  }

  /// Floating pill button hovering above the bottom of the screen — tapping
  /// it opens the manual-entry sheet. Styled like a "checkout" CTA (pill
  /// shape, icon badge on the left, circular arrow affordance on the
  /// right) rather than looking like a piece of chrome docked to the
  /// screen edge, so it reads as a clear, inviting action instead of a
  /// utility bar.
  Widget _buildBasketCodeBar() {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Material(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(100),
        elevation: 8,
        shadowColor: AppTheme.primaryColor.withValues(alpha: 0.5),
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: () {
            HapticFeedback.selectionClick();
            _onMockScan();
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 10, 14),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Search Basket Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppTheme.primaryColor,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Scan', style: TextStyle(color: Colors.white)),
        actions: [
          TorchButton(controller: _controller),
          const SizedBox(width: 12),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: TransferScannerView(
              controller: _controller,
              showTorchButton: false,
              paused:
                  _scannedBasket != null ||
                  _basketNotFound ||
                  _isMockDialogOpen,
              onBasketFound: (basket) => setState(() {
                _scannedBasket = basket;
                _basketNotFound = false;
              }),
              onBasketNotFound: (code) => setState(() {
                _scannedBasket = null;
                _basketNotFound = true;
                _notFoundCode = code;
              }),
            ),
          ),
          if (_scannedBasket == null && !_basketNotFound && !_isMockDialogOpen)
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildBasketCodeBar(),
            ),
          if (_scannedBasket != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: TransferReceiveSheet(
                basket: _scannedBasket!,
                onDismiss: _resumeScanning,
                onBack: _resumeScanning,
              ),
            ),
          if (_basketNotFound)
            Align(
              alignment: Alignment.bottomCenter,
              child: TransferNotFoundSheet(
                onDismiss: _resumeScanning,
                code: _notFoundCode,
              ),
            ),
        ],
      ),
    );
  }
}
