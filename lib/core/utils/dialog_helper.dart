import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../theme/app_theme.dart';

class SnackBarHelper {
  SnackBarHelper._();

  static void _show(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  static void success(BuildContext context, String message) =>
      _show(context, message, AppTheme.successColor);

  static void error(BuildContext context, String message) =>
      _show(context, message, AppTheme.errorColor);

  static void warning(BuildContext context, String message) =>
      _show(context, message, AppTheme.warningColor);

  static void info(BuildContext context, String message) =>
      _show(context, message, Colors.blueGrey);
}

class DialogHelper {
  DialogHelper._();

  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Ya',
    String cancelLabel = 'Batal',
    bool isDanger = false,
  }) async {
    // final fillColor = isDanger ? AppTheme.errorColor : AppTheme.primaryColor;
    final fillColor = AppTheme.primaryColor;
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: fillColor,
                    side: BorderSide(color: fillColor),
                    shape: buttonShape,
                  ),
                  child: Text(cancelLabel.toUpperCase()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: fillColor,
                    foregroundColor: Colors.white,
                    shape: buttonShape,
                  ),
                  child: Text(confirmLabel.toUpperCase()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static void showLoading(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(message),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void hideLoading(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        final navigator = Navigator.of(context, rootNavigator: true);
        if (navigator.canPop()) navigator.pop();
      }
    });
  }
}

class ToastHelper {
  ToastHelper._();

  static void success(String message) {
    toastification.show(
      title: Text(message),
      style: ToastificationStyle.fillColored,
      type: ToastificationType.success,
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
    );
  }

  static void error(String message) {
    toastification.show(
      title: Text(message),
      style: ToastificationStyle.fillColored,
      type: ToastificationType.error,
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
    );
  }
}
