import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/app_update_info.dart';
import '../providers/app_update_download_provider.dart';
import '../providers/app_update_download_state.dart';
import '../providers/app_update_provider.dart';

/// Update status card, always visible on the Profile page — not just when a
/// newer release is found. While [appUpdateCheckProvider] is loading it
/// shows a neutral "checking" state; once resolved it either offers the
/// update (newer release found), confirms the app is already up to date, or
/// — if the check itself failed (network/parse error) — says so explicitly
/// with a retry button, instead of quietly looking the same as "up to date".
class AppUpdateBanner extends ConsumerWidget {
  const AppUpdateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkState = ref.watch(appUpdateCheckProvider);
    final isChecking = checkState.isLoading;
    final hasFailed = checkState.hasError && !isChecking;
    final updateInfo = checkState.valueOrNull;
    final hasUpdate = updateInfo != null;

    final currentVersion = ref.watch(currentAppVersionProvider).valueOrNull;
    final downloadState = ref.watch(appUpdateDownloadProvider);

    final String title;
    final String subtitle;
    if (isChecking) {
      title = 'Memeriksa pembaruan…';
      subtitle = 'Mohon tunggu sebentar';
    } else if (hasFailed) {
      title = 'Gagal memeriksa pembaruan';
      subtitle = 'Periksa koneksi internet, lalu coba lagi';
    } else if (hasUpdate) {
      title = 'Update tersedia';
      subtitle = 'Versi ${updateInfo.version} siap diunduh';
    } else {
      title = 'Sudah versi terbaru';
      subtitle = 'Tidak ada pembaruan baru saat ini';
    }

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasFailed
                      ? Icons.error_outline_rounded
                      : hasUpdate
                      ? Icons.system_update_alt_rounded
                      : Icons.check_circle_outline_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _ActionButton(
                info: updateInfo,
                state: downloadState,
                isChecking: isChecking,
                hasFailed: hasFailed,
              ),
            ],
          ),
          if (currentVersion != null) ...[
            const SizedBox(height: 10),
            Text(
              'Versi terpasang: v$currentVersion',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends ConsumerWidget {
  const _ActionButton({
    required this.info,
    required this.state,
    required this.isChecking,
    required this.hasFailed,
  });

  final AppUpdateInfo? info;
  final AppUpdateDownloadState state;
  final bool isChecking;
  final bool hasFailed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isChecking || state.isBusy) {
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

    if (hasFailed) {
      return ElevatedButton(
        onPressed: () => ref.invalidate(appUpdateCheckProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primaryColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          'Coba lagi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      );
    }

    final hasUpdate = info != null;

    return ElevatedButton(
      onPressed: hasUpdate
          ? () => ref
                .read(appUpdateDownloadProvider.notifier)
                .downloadAndInstall(info!)
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: hasUpdate
            ? Colors.white
            : Colors.white.withValues(alpha: 0.3),
        foregroundColor: AppTheme.primaryColor,
        disabledBackgroundColor: Colors.white.withValues(alpha: 0.3),
        disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        hasUpdate ? 'Update' : 'Terbaru',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}
