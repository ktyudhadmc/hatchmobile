import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

class FormTextField extends StatelessWidget {
  const FormTextField({
    super.key,
    required this.controller,
    this.label,
    this.placeholder,
    this.isReadOnly = false,
    this.isObscure = false,
    this.isTextArea = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.prefix,
    this.explanation = '',
    this.isRequired = true,
    this.focusNode,
  });

  final String? label;
  final String? placeholder;
  final TextEditingController controller;

  final bool isTextArea;
  final bool isObscure;
  final bool isReadOnly;

  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefix;
  final bool isRequired;
  final String? explanation;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label ',
                  style: TextStyle(
                    color: const Color(0xFF353535),
                    fontSize: screenWidth * 0.03,
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w600,
                    height: 1.20,
                    letterSpacing: -0.28,
                  ),
                ),
                if (explanation != null && explanation!.isNotEmpty)
                  TextSpan(
                    text: '($explanation) ',
                    style: const TextStyle(
                      color: Color(0xFF7B7B7B),
                      fontSize: 10,
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w400,
                      height: 1.20,
                      letterSpacing: -0.28,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                if (isRequired)
                  const TextSpan(
                    text: '*',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 14,
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w600,
                      height: 1.20,
                      letterSpacing: -0.28,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: isObscure,
            autocorrect: !isObscure,
            enableSuggestions: !isObscure,
            readOnly: isReadOnly,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLines: isObscure ? 1 : (isTextArea ? 3 : 1),
            decoration: InputDecoration(
              hintText: placeholder,
              prefixIcon: prefix != null
                  ? Padding(padding: const EdgeInsets.all(12.0), child: prefix)
                  : null,
              hintStyle: const TextStyle(
                color: Color(0xFF9C9C9C),
                fontFamily: AppTheme.fontFamily,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.12,
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF0F0F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}
