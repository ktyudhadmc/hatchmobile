import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/connectivity_service.dart';
import '../../../core/theme/app_theme.dart';

/// Non-dismissible bottom sheet shown whenever there's no internet
/// connection, blocking the user from continuing until it comes back.
/// Opened/closed automatically by [ConnectivityGate] — not meant to be
/// shown directly.
class NoInternetSheet extends ConsumerStatefulWidget {
  const NoInternetSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const NoInternetSheet(),
    );
  }

  @override
  ConsumerState<NoInternetSheet> createState() => _NoInternetSheetState();
}

class _NoInternetSheetState extends ConsumerState<NoInternetSheet> {
  bool _isChecking = false;

  Future<void> _retry() async {
    setState(() => _isChecking = true);
    final isConnected = await ref
        .read(connectivityServiceProvider)
        .isConnected();
    if (!mounted) return;
    setState(() => _isChecking = false);

    if (isConnected && Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 56,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'Oops!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'No Internet Connection found.\nCheck your connection',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF7B7B7B)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : _retry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isChecking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'RETRY',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: AppTheme.fontFamily,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
