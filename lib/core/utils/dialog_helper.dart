import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../navigation/app_navigator.dart';
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

  /// Same confirm/cancel contract as [confirm], but as a bottom sheet
  /// (close button + icon + message, cancel outlined above confirm filled)
  /// instead of an [AlertDialog].
  static Future<bool> confirmSheet(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Ya',
    String cancelLabel = 'Tidak',
    bool isDanger = false,
  }) async {
    final fillColor = AppTheme.primaryColor;
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    );

    final result = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 8),
              Icon(
                isDanger ? Icons.error_outline : Icons.help_outline,
                color: isDanger ? AppTheme.errorColor : fillColor,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF7B7B7B)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: fillColor,
                    side: BorderSide(color: fillColor),
                    shape: buttonShape,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(cancelLabel.toUpperCase()),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: fillColor,
                    foregroundColor: Colors.white,
                    shape: buttonShape,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(confirmLabel.toUpperCase()),
                ),
              ),
            ],
          ),
        ),
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

  // Deliberately not `Navigator.of(context, rootNavigator: true)` — the
  // calling page can be unmounted (e.g. a redirect fires right after login
  // succeeds, swapping /login for /scan) before this deferred callback
  // runs, and a stale context is silently skipped by `context.mounted`,
  // leaving the loading dialog stuck open forever. appNavigatorKey stays
  // valid for the app's whole lifetime regardless of which page opened it.
  static void hideLoading(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = appNavigatorKey.currentState;
      if (navigator != null && navigator.canPop()) {
        navigator.pop();
      }
    });
  }

  /// Cupertino date wheel in a bottom sheet — pick, then confirm.
  static Future<DateTime?> showCupertinoDatePicker(
    BuildContext context, {
    required DateTime initialDate,
    DateTime? minDate,
    DateTime? maxDate,
    String? label,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (context) {
        var selectedDate = initialDate;

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                SizedBox(
                  height: 216,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: selectedDate,
                    minimumDate: minDate ?? DateTime(2000),
                    maximumDate: maxDate ?? DateTime.now(),
                    onDateTimeChanged: (date) => selectedDate = date,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(selectedDate),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('PILIH'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
