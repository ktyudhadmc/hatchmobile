import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Shown in place of a toast when a scanned code doesn't resolve to a
/// basket — auto-dismisses via [onDismiss] after a short delay, or right
/// away if KEMBALI is tapped, either way resuming the scanner.
class TransferNotFoundSheet extends StatefulWidget {
  const TransferNotFoundSheet({
    super.key,
    required this.onDismiss,
    required this.code,
  });

  final VoidCallback onDismiss;

  /// The raw code that was scanned/entered and failed to resolve, shown so
  /// the user can tell whether it was misread or genuinely doesn't exist.
  final String code;

  @override
  State<TransferNotFoundSheet> createState() => _TransferNotFoundSheetState();
}

class _TransferNotFoundSheetState extends State<TransferNotFoundSheet> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    // See TransferReceiveSheet for why `minimum` is needed on gesture-nav
    // Android devices.
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppTheme.errorColor,
              size: 40,
            ),
            const SizedBox(height: 12),
            const Text(
              'Basket Not Found',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.code,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: widget.onDismiss,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: const BorderSide(color: AppTheme.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
    );
  }
}
