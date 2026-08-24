import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/mixins/async_state_handler_mixin.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/transfer_basket.dart';
import '../../domain/entities/transfer_grade.dart';
import '../providers/transfer_provider.dart';

enum _SheetStatus { idle, success, alreadyReceived }

/// Blocking sheet shown right after a basket is scanned, docked to the
/// bottom of the scan screen. SIMPAN (or the backend reporting the basket
/// as already received) auto-dismisses via [onDismiss] so the scanner can
/// resume; KEMBALI calls [onBack] to cancel and resume scanning right away.
/// Leaving the scan screen entirely is done through the page's own top bar,
/// not from here.
class TransferReceiveSheet extends ConsumerStatefulWidget {
  const TransferReceiveSheet({
    super.key,
    required this.basket,
    required this.onDismiss,
    required this.onBack,
  });

  final TransferBasket basket;
  final VoidCallback onDismiss;
  final VoidCallback onBack;

  @override
  ConsumerState<TransferReceiveSheet> createState() =>
      _TransferReceiveSheetState();
}

class _TransferReceiveSheetState extends ConsumerState<TransferReceiveSheet>
    with AsyncStateHandlerMixin {
  _SheetStatus _status = _SheetStatus.idle;
  String _message = '';

  @override
  void initState() {
    super.initState();

    listenAsync(
      provider: createReceiveProvider,
      loadingMessage: 'Menyimpan...',
      onData: (_) {
        unawaited(ref.read(recentsReceiveProvider.notifier).fetch());
        setState(() {
          _status = _SheetStatus.success;
          _message = 'Basket berhasil diterima!';
        });
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) widget.onDismiss();
        });
      },
      onError: (err, stack) {
        setState(() {
          _status = _SheetStatus.alreadyReceived;
          _message = err.toString();
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) widget.onDismiss();
        });
      },
    );
  }

  void _onSave() {
    ref
        .read(createReceiveProvider.notifier)
        .create(basketCode: widget.basket.basketCode);
  }

  @override
  Widget build(BuildContext context) {
    // `minimum` guards against gesture-nav Android devices where
    // MediaQuery.padding.bottom reports 0 (the gesture pill overlays
    // content transparently instead of reserving layout space) — without
    // it, KEMBALI/SIMPAN can end up flush against the system nav area.
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 16),
      child: _buildCard(),
    );
  }

  Widget _buildCard() {
    final basket = widget.basket;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                basket.basketCode,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
              Text(
                basket.transfer.transferCode,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Farm',
                    style: TextStyle(
                      color: Color(0xFF7B7B7B),
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                  Text(
                    'Tgl. Transfer',
                    style: TextStyle(
                      color: Color(0xFF7B7B7B),
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    basket.transfer.branch,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                  Text(
                    DateFormatter.format(basket.transfer.transferDate),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: basket.grades.map(_buildGradeBadge).toList(),
          ),
          const SizedBox(height: 24),
          _buildActionArea(),
        ],
      ),
    );
  }

  Widget _buildGradeBadge(TransferGrade grade) {
    return Column(
      children: [
        Text(
          grade.grade,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 56,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDADADA)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${grade.quantity}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionArea() {
    if (_status != _SheetStatus.idle) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: ShapeDecoration(
          color: AppTheme.successColor.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          _message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
      );
    }

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    );

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onBack,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: const BorderSide(color: AppTheme.primaryColor),
              shape: buttonShape,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'KEMBALI',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: _onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: buttonShape,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'SIMPAN',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
