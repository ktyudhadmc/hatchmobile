import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/form/pin_code_input.dart';
import '../../../../shared/widgets/scanner/scanner_view.dart';
import '../../domain/entities/transfer_basket.dart';
import '../providers/transfer_provider.dart';
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
  TransferBasket? _scannedBasket;
  bool _basketNotFound = false;
  bool _isMockDialogOpen = false;

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

  Widget _buildMockScanButton() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: _onMockScan,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_outlined,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Basket Code',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Scan'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Same formula TransferScannerView feeds into ScannerView's
          // guideOffsetY — kept in sync so this button lands right under
          // the guide box's bottom edge, not just visually close to it.
          final bodyHeight = constraints.maxHeight;
          final guideCenterY = bodyHeight / 2 - bodyHeight * 0.18;
          final guideBottom =
              guideCenterY + ScannerView.defaultGuideBoxSize / 2;

          return Stack(
            children: [
              Positioned.fill(
                child: TransferScannerView(
                  paused:
                      _scannedBasket != null ||
                      _basketNotFound ||
                      _isMockDialogOpen,
                  onBasketFound: (basket) => setState(() {
                    _scannedBasket = basket;
                    _basketNotFound = false;
                  }),
                  onBasketNotFound: () => setState(() {
                    _scannedBasket = null;
                    _basketNotFound = true;
                  }),
                ),
              ),
              if (_scannedBasket == null &&
                  !_basketNotFound &&
                  !_isMockDialogOpen)
                Positioned(
                  top: guideBottom + 16,
                  left: 0,
                  right: 0,
                  child: Center(child: _buildMockScanButton()),
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
                  child: TransferNotFoundSheet(onDismiss: _resumeScanning),
                ),
            ],
          );
        },
      ),
    );
  }
}
