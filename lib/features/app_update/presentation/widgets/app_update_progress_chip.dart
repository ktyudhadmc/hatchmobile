import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/dialog_helper.dart';
import '../providers/app_update_download_provider.dart';
import '../providers/app_update_download_state.dart';

/// Small persistent chip shown at the top of every page (wired in
/// main.dart's `MaterialApp.router` builder, next to [ConnectivityGate])
/// while an update download/install is in progress.
///
/// [appUpdateDownloadProvider] is deliberately not `.autoDispose`, so the
/// download survives the user navigating away from the Profile page where
/// it was started — this chip is what tells them it's still happening
/// wherever they end up, and warns them not to close the app.
class AppUpdateProgressChip extends ConsumerWidget {
  const AppUpdateProgressChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appUpdateDownloadProvider);

    ref.listen(appUpdateDownloadProvider, (previous, next) {
      if (next.status == AppUpdateDownloadStatus.error) {
        ToastHelper.error(next.errorMessage ?? 'Gagal mengunduh update');
        ref.read(appUpdateDownloadProvider.notifier).reset();
      }
    });

    if (!state.isBusy) return const SizedBox.shrink();

    final isInstalling = state.status == AppUpdateDownloadStatus.installing;
    final label = isInstalling
        ? 'Menyiapkan installer…'
        : 'Mengunduh update ${(state.progress * 100).clamp(0, 100).toStringAsFixed(0)}%';

    return SafeArea(
      bottom: false,
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(color: Color(0x33000000), blurRadius: 8),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      'Jangan tutup atau hapus aplikasi sampai selesai',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
