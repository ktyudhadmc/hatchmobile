import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_theme.dart';
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

    ref.read(scanBasketProvider.notifier).scan(code);
  }

  /// Persistent sheet-like bar pinned to the bottom of the screen, sized to
  /// ~16% of the screen height so it reads as a proper bottom sheet rather
  /// than a slim strip. Tapping it — or dragging its handle upward — slides
  /// the manual-entry sheet up from underneath.
  Widget _buildBasketCodeBar() {
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: _onMockScan,
      onVerticalDragEnd: (details) {
        // Dragged the handle upward fast enough — treat it as "open".
        if (details.primaryVelocity != null && details.primaryVelocity! < -200) {
          _onMockScan();
        }
      },
      child: Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        elevation: 6,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: screenHeight * 0.16,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(
                        Icons.search_outlined,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Basket Code',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppTheme.fontFamily,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
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
