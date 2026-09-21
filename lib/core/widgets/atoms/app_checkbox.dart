import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Smallest reusable checkbox building block — a tappable checkbox + label
/// pair, sized to its content (no fixed [ListTile]-style padding), so
/// callers composing several of these (see `CheckboxGroup`) fully control
/// the spacing between them instead of fighting built-in tile insets.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.labelStyle,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: value,
            onChanged: (checked) => onChanged(checked ?? false),
            activeColor: activeColor ?? AppTheme.primaryColor,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style:
                labelStyle ??
                const TextStyle(fontSize: 14, fontFamily: AppTheme.fontFamily),
          ),
        ],
      ),
    );
  }
}
