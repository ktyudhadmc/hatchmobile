import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_theme.dart';

/// Overlay drawn on top of the live scanner: back button + title on the
/// left/center, torch toggle top-right, and the sent/received counters
/// stacked underneath the torch button.
class ScanTopBar extends StatelessWidget {
  const ScanTopBar({
    super.key,
    required this.controller,
    required this.sentCount,
    required this.receivedCount,
    required this.onBack,
    this.debugAction,
  });

  final MobileScannerController controller;
  final int sentCount;
  final int receivedCount;
  final VoidCallback onBack;

  /// Dev-only affordance (e.g. a mock-scan trigger), rendered below the
  /// "Diterima" badge. Null in release builds.
  final Widget? debugAction;

  @override
  Widget build(BuildContext context) {
    final isComplete = sentCount > 0 && receivedCount >= sentCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RoundIconButton(
            icon: Icons.chevron_left,
            backgroundColor: Colors.black.withValues(alpha: 0.45),
            iconColor: Colors.white,
            onTap: onBack,
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                'Basket Scanner',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
            ),
          ),
          Column(
            children: [
              ValueListenableBuilder<MobileScannerState>(
                valueListenable: controller,
                builder: (context, state, _) {
                  final isOn = state.torchState == TorchState.on;
                  return RoundIconButton(
                    icon: isOn ? Icons.flash_on : Icons.flash_off,
                    backgroundColor: AppTheme.warningColor,
                    iconColor: Colors.white,
                    onTap: controller.toggleTorch,
                  );
                },
              ),
              const SizedBox(height: 16),
              _CountBadge(
                count: sentCount,
                label: 'Dikirim',
                circleColor: AppTheme.successColor,
                labelColor: Colors.black87,
              ),
              const SizedBox(height: 10),
              _CountBadge(
                count: receivedCount,
                label: 'Diterima',
                circleColor: isComplete ? AppTheme.successColor : Colors.black87,
                labelColor: isComplete ? AppTheme.successColor : Colors.black87,
              ),
              if (debugAction != null) ...[
                const SizedBox(height: 10),
                debugAction!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: iconColor, size: 22),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({
    required this.count,
    required this.label,
    required this.circleColor,
    required this.labelColor,
  });

  final int count;
  final String label;
  final Color circleColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: circleColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
      ],
    );
  }
}
