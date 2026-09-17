import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/dialog_helper.dart';
import '../../domain/entities/app_update_info.dart';
import '../providers/app_update_download_provider.dart';
import '../providers/app_update_download_state.dart';
import '../providers/app_update_provider.dart';

/// Attention-grabbing banner shown only when [appUpdateCheckProvider] finds
/// a newer release — deliberately styled unlike the white/bordered profile
/// card (solid gradient, white text/icon) so it reads as an announcement,
/// not just another settings row. Renders nothing when there's no update,
/// so it never sits around as empty chrome.
class AppUpdateBanner extends ConsumerWidget {
  const AppUpdateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateInfo = ref.watch(appUpdateCheckProvider).valueOrNull;
    if (updateInfo == null) return const SizedBox.shrink();

    final downloadState = ref.watch(appUpdateDownloadProvider);

    ref.listen(appUpdateDownloadProvider, (previous, next) {
      if (next.status == AppUpdateDownloadStatus.error) {
        ToastHelper.error(next.errorMessage ?? 'Gagal mengunduh update');
      }
    });

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.system_update_alt_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Update tersedia',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Versi ${updateInfo.version} siap diunduh',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _ActionButton(info: updateInfo, state: downloadState),
        ],
      ),
    );
  }
}

class _ActionButton extends ConsumerWidget {
  const _ActionButton({required this.info, required this.state});

  final AppUpdateInfo info;
  final AppUpdateDownloadState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isBusy) {
      return SizedBox(
        width: 36,
        height: 36,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Colors.white,
          value:
              state.status == AppUpdateDownloadStatus.downloading &&
                  state.progress > 0
              ? state.progress
              : null,
        ),
      );
    }

    return ElevatedButton(
      onPressed: () =>
          ref.read(appUpdateDownloadProvider.notifier).downloadAndInstall(info),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: const Text(
        'Update',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}
