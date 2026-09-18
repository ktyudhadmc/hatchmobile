import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/app_update_info.dart';
import '../providers/app_update_download_provider.dart';
import '../providers/app_update_download_state.dart';
import '../providers/app_update_provider.dart';

/// Update status card shown on the Settings page — reports the update
/// check's result (checking / up to date / update available / failed) and,
/// once there's an update, lets the user download and install it.
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
      title = 'Checking for updates…';
      subtitle = 'Please wait a moment';
    } else if (hasFailed) {
      title = 'Update check failed';
      subtitle = 'Check your internet connection and try again';
    } else if (hasUpdate) {
      title = 'Update available';
      subtitle = 'Version ${updateInfo.version} is ready to download';
    } else {
      title = currentVersion != null ? 'v$currentVersion' : 'Up to date';
      subtitle = 'You\'re on the latest version';
    }

    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
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
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasFailed || hasUpdate || downloadState.isBusy) ...[
            const SizedBox(height: 12),
            _ActionButton(
              info: updateInfo,
              state: downloadState,
              isChecking: isChecking,
              hasFailed: hasFailed,
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
    if (isChecking) return const SizedBox.shrink();

    if (state.isBusy) {
      return SizedBox(
        height: 32,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
              value:
                  state.status == AppUpdateDownloadStatus.downloading &&
                      state.progress > 0
                  ? state.progress
                  : null,
            ),
          ),
        ),
      );
    }

    if (hasFailed) {
      return SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () => ref.invalidate(appUpdateCheckProvider),
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Retry',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      );
    }

    final hasUpdate = info != null;
    if (!hasUpdate) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => ref
            .read(appUpdateDownloadProvider.notifier)
            .downloadAndInstall(info!),
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          'Update',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }
}
