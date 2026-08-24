import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';

class FormTextField extends StatefulWidget {
  const FormTextField({
    super.key,
    required this.controller,
    this.label,
    this.placeholder,
    this.isReadOnly = false,
    this.isObscure = false,
    this.isPassword = false,
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

  /// Renders an eye/eye-off suffix icon that toggles obscuring the field's
  /// text, for password inputs. Starts obscured.
  final bool isPassword;
  final bool isReadOnly;

  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefix;
  final bool isRequired;
  final String? explanation;
  final FocusNode? focusNode;

  @override
  State<FormTextField> createState() => _FormTextFieldState();
}

class _FormTextFieldState extends State<FormTextField> {
  late bool _obscureText = widget.isPassword ? true : widget.isObscure;

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
                  text: '${widget.label} ',
                  style: TextStyle(
                    color: const Color(0xFF353535),
                    fontSize: screenWidth * 0.03,
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w600,
                    height: 1.20,
                    letterSpacing: -0.28,
                  ),
                ),
                if (widget.explanation != null && widget.explanation!.isNotEmpty)
                  TextSpan(
                    text: '(${widget.explanation}) ',
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
                if (widget.isRequired)
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
            controller: widget.controller,
            focusNode: widget.focusNode,
            obscureText: _obscureText,
            autocorrect: !_obscureText,
            enableSuggestions: !_obscureText,
            readOnly: widget.isReadOnly,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            maxLines: _obscureText ? 1 : (widget.isTextArea ? 3 : 1),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              prefixIcon: widget.prefix != null
                  ? Padding(padding: const EdgeInsets.all(12.0), child: widget.prefix)
                  : null,
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF9C9C9C),
                      ),
                      onPressed: () => setState(() => _obscureText = !_obscureText),
                    )
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
