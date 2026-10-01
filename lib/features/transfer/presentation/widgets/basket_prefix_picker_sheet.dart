import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Bottom sheet with one radio per basket-code prefix. Picking a radio
/// closes the sheet and returns that prefix; dismissing it returns `null`.
class BasketPrefixPickerSheet extends StatelessWidget {
  const BasketPrefixPickerSheet({
    super.key,
    required this.prefixes,
    required this.selectedPrefix,
  });

  final List<String> prefixes;
  final String selectedPrefix;

  static Future<String?> show(
    BuildContext context, {
    required List<String> prefixes,
    required String selectedPrefix,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BasketPrefixPickerSheet(
        prefixes: prefixes,
        selectedPrefix: selectedPrefix,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Same insets as the header of the Basket Code sheet, so the
            // close button sits in the same spot in both.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Basket Code Prefix',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: AppTheme.fontFamily,
                      ),
                    ),
                  ),
                  // Mirrors the close button's width so the title stays
                  // centred.
                  const SizedBox(width: 48),
                ],
              ),
            ),
            RadioGroup<String>(
              groupValue: selectedPrefix,
              onChanged: (value) => Navigator.of(context).pop(value),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final prefix in prefixes)
                    RadioListTile<String>(
                      value: prefix,
                      dense: true,
                      visualDensity: const VisualDensity(vertical: -3),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      activeColor: AppTheme.primaryColor,
                      title: Text(
                        prefix,
                        style: const TextStyle(fontFamily: AppTheme.fontFamily),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
