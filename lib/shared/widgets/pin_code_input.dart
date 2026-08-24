import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../core/theme/app_theme.dart';

/// PIN-style input: fixed-width boxed fields, one per character. Optionally
/// preceded by a static, non-editable label box (e.g. a fixed letter
/// prefix) styled to match the fields themselves.
class PinCodeInput extends StatelessWidget {
  const PinCodeInput({
    super.key,
    required this.length,
    required this.controller,
    this.prefix,
    this.fontSize = 20,
    this.autoFocus = true,
    this.keyboardType = TextInputType.number,
    this.fieldWidth = 40,
    this.fieldHeight = 50,
    this.onCompleted,
  });

  final int length;
  final double fontSize;
  final TextEditingController controller;
  final String? prefix;
  final bool autoFocus;
  final TextInputType keyboardType;
  final double fieldWidth;
  final double fieldHeight;

  /// Fired once the last field is filled in, with the full entered value
  /// (not including [prefix]).
  final ValueChanged<String>? onCompleted;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (prefix != null && prefix!.isNotEmpty) ...[
          Container(
            height: fieldHeight,
            margin: EdgeInsets.only(bottom: fontSize * 0.5, right: fontSize *0.5),
            child: Center(
              child: Text(
                prefix!,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
            ),
          ),
          // const SizedBox(width: 8),
        ],
        Expanded(
          child: PinCodeTextField(
            appContext: context,
            length: length,
            autoFocus: autoFocus,
            controller: controller,
            keyboardType: keyboardType,
            animationType: AnimationType.fade,
            textStyle: TextStyle(fontSize: fontSize),
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(8),
              fieldHeight: fieldHeight,
              fieldWidth: fieldWidth,
              activeColor: AppTheme.primaryColor,
              inactiveColor: const Color(0xFFF0F0F0),
              selectedColor: AppTheme.primaryColor,
            ),
            onCompleted: onCompleted,
          ),
        ),
      ],
    );
  }
}
