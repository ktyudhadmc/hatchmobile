import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/native/silent_install_channel.dart';
import '../../data/datasources/app_update_remote_datasource.dart';
import '../../data/update_apk_cleanup.dart';
import '../../domain/entities/app_update_info.dart';
import 'app_update_download_state.dart';

final appUpdateDownloadProvider =
    StateNotifierProvider<AppUpdateDownloadNotifier, AppUpdateDownloadState>((
      ref,
    ) {
      return AppUpdateDownloadNotifier(
        ref.watch(appUpdateRemoteDatasourceProvider),
      );
    });

/// Downloads the release APK to a temp file, then installs it. On a device
/// where this app is enrolled as Device Owner (Android Enterprise), that
/// install happens silently via [SilentInstallChannel] — no OS prompt at
/// all. Everywhere else, silent install isn't permitted by the platform, so
/// it falls back to handing the APK to the OS package installer, which
/// still shows its own confirmation prompt that can't be skipped without
/// that enrollment.
///
/// Deliberately NOT `.autoDispose`: the download is kicked off from the
/// Settings page banner, but the user is free to navigate elsewhere while it
/// runs — an autoDispose provider would tear down mid-download the moment
/// nothing was watching it, silently killing the transfer. Progress is only
/// ever shown on the Settings page (see AppUpdateBanner) — it isn't
/// surfaced globally, so leaving Settings just means not watching it happen.
class AppUpdateDownloadNotifier extends StateNotifier<AppUpdateDownloadState> {
  AppUpdateDownloadNotifier(this._remote) : super(const AppUpdateDownloadState());

  final AppUpdateRemoteDatasource _remote;

  Future<void> downloadAndInstall(AppUpdateInfo update) async {
    state = const AppUpdateDownloadState(status: AppUpdateDownloadStatus.downloading);

    try {
      final apkPath = await _downloadToTempFile(update);
      state = state.copyWith(status: AppUpdateDownloadStatus.installing);

      await _install(apkPath);

      state = const AppUpdateDownloadState();
    } catch (e) {
      state = state.copyWith(
        status: AppUpdateDownloadStatus.error,
        errorMessage: 'Failed to download update: $e',
      );
    }
  }

  Future<void> _install(String apkPath) async {
    if (await SilentInstallChannel.isDeviceOwner()) {
      try {
        await SilentInstallChannel.silentInstall(apkPath);
        // The APK's bytes are copied into the PackageInstaller session
        // during silentInstall, so the source file is no longer needed —
        // unlike the OpenFilex path below, nothing else still reads it.
        try {
          await File(apkPath).delete();
        } catch (_) {
          // Best-effort — a locked/already-gone file isn't worth failing
          // the (already successful) install over.
        }
        return;
      } catch (_) {
        // Fall through to the normal OS-installer flow below.
      }
    }

    final result = await OpenFilex.open(apkPath);
    if (result.type != ResultType.done) {
      throw Exception(result.message);
    }
    // Deliberately NOT deleted here — the OS installer activity we just
    // launched still needs to read this file while the user reviews and
    // confirms the install. It's swept up as a stale leftover the next
    // time an update downloads (see purgeStaleUpdateApks below).
  }

  Future<String> _downloadToTempFile(AppUpdateInfo update) async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/hatchmobile-${update.version}.apk';

    // Every past update's APK piles up in the OS temp dir otherwise —
    // nothing was ever deleting them, which is how this app ended up
    // reportedly using hundreds of MB of device storage over time.
    await purgeStaleUpdateApks(exceptPath: path);

    await _remote.downloadApk(
      update.apkUrl,
      path,
      onProgress: (received, total) {
        if (total <= 0) return;
        state = state.copyWith(progress: received / total);
      },
    );

    return path;
  }

  void reset() => state = const AppUpdateDownloadState();
}
