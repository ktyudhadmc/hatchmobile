import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/datasources/app_update_remote_datasource.dart';
import '../../domain/entities/app_update_info.dart';
import 'app_update_download_state.dart';

final appUpdateDownloadProvider =
    StateNotifierProvider.autoDispose<
      AppUpdateDownloadNotifier,
      AppUpdateDownloadState
    >((ref) {
      return AppUpdateDownloadNotifier(
        ref.watch(appUpdateRemoteDatasourceProvider),
      );
    });

/// Downloads the release APK to a temp file, then hands it straight to the
/// OS package installer — the closest thing to "install otomatis" Android
/// allows a regular (non-system) app to do; the user still gets the OS's
/// own install confirmation prompt, which cannot be skipped without root.
class AppUpdateDownloadNotifier extends StateNotifier<AppUpdateDownloadState> {
  AppUpdateDownloadNotifier(this._remote) : super(const AppUpdateDownloadState());

  final AppUpdateRemoteDatasource _remote;

  Future<void> downloadAndInstall(AppUpdateInfo update) async {
    state = const AppUpdateDownloadState(status: AppUpdateDownloadStatus.downloading);

    try {
      final apkPath = await _downloadToTempFile(update);
      state = state.copyWith(status: AppUpdateDownloadStatus.installing);

      final result = await OpenFilex.open(apkPath);
      if (result.type != ResultType.done) {
        state = state.copyWith(
          status: AppUpdateDownloadStatus.error,
          errorMessage: result.message,
        );
        return;
      }

      state = const AppUpdateDownloadState();
    } catch (e) {
      state = state.copyWith(
        status: AppUpdateDownloadStatus.error,
        errorMessage: 'Gagal mengunduh update: $e',
      );
    }
  }

  Future<String> _downloadToTempFile(AppUpdateInfo update) async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/hatchmobile-${update.version}.apk';

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
