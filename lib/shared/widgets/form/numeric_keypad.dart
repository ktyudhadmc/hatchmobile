import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';

/// On-screen 0-9 keypad with backspace. Replaces the system keyboard so the
/// surrounding sheet keeps a fixed height instead of jumping with the IME.
class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    this.keyHeight = 52,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final double keyHeight;

  @override
  Widget build(BuildContext context) {
    Widget row(List<Widget> keys) => Row(
      children: [
        for (final k in keys)
          Expanded(
            child: Padding(padding: const EdgeInsets.all(4), child: k),
          ),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final r in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          row([for (final d in r) _digitKey(d)]),
        row([
          const SizedBox.shrink(),
          _digitKey('0'),
          _key(
            child: const Icon(Icons.backspace_outlined, size: 22),
            onTap: onBackspace,
          ),
        ]),
      ],
    );
  }

  Widget _digitKey(String d) => _key(
    child: Text(
      d,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        fontFamily: AppTheme.fontFamily,
      ),
    ),
    onTap: () => onDigit(d),
  );

  Widget _key({required Widget child, required VoidCallback onTap}) {
    return Material(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: SizedBox(
          height: keyHeight,
          child: Center(child: child),
        ),
      ),
    );
  }
}
