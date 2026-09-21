import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/app_update_info.dart';
import '../providers/app_update_download_provider.dart';
import '../providers/app_update_download_state.dart';
import '../providers/app_update_provider.dart';
import '../providers/auto_update_provider.dart';

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

    // Auto-install as soon as a newer release is found, if the user opted
    // in via AutoUpdateToggle — skipped while a download is already running
    // so a refresh mid-download doesn't kick off a second one.
    ref.listen<AsyncValue<AppUpdateInfo?>>(appUpdateCheckProvider, (
      previous,
      next,
    ) {
      final info = next.valueOrNull;
      if (info == null) return;
      if (!ref.read(autoUpdateEnabledProvider)) return;
      if (ref.read(appUpdateDownloadProvider).isBusy) return;
      ref.read(appUpdateDownloadProvider.notifier).downloadAndInstall(info);
    });

    final List<Widget> textLines;
    if (isChecking) {
      textLines = const [
        _TitleText('Checking for updates…'),
        _SubtitleText('Please wait a moment'),
      ];
    } else if (hasFailed) {
      textLines = const [
        _TitleText('Update check failed'),
        _SubtitleText('Check your internet connection and try again'),
      ];
    } else if (hasUpdate) {
      textLines = [
        const _TitleText('Update available'),
        _SubtitleText('Version ${updateInfo.version} is ready to download'),
      ];
    } else {
      textLines = [
        const _TitleText(AppConstants.appName),
        if (currentVersion != null) _VersionText('v$currentVersion'),
        const _SubtitleText('You\'re on the latest version'),
      ];
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
                  children: textLines,
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
      final isDownloading = state.status == AppUpdateDownloadStatus.downloading;
      final knownProgress = isDownloading && state.progress > 0
          ? state.progress
          : null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isDownloading ? 'Downloading…' : 'Installing…',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (knownProgress != null)
                Text(
                  '${(knownProgress * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: knownProgress,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ],
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

class _TitleText extends StatelessWidget {
  const _TitleText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }
}

class _VersionText extends StatelessWidget {
  const _VersionText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.95),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SubtitleText extends StatelessWidget {
  const _SubtitleText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.85),
          fontSize: 11,
        ),
      ),
    );
  }
}
