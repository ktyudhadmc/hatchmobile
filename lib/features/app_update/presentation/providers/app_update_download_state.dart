enum AppUpdateDownloadStatus { idle, downloading, installing, error }

/// State machine for the download → install flow triggered by the Update
/// button. Kept separate from [AppUpdateDownloadNotifier] so it's easy to
/// test/read on its own.
class AppUpdateDownloadState {
  const AppUpdateDownloadState({
    this.status = AppUpdateDownloadStatus.idle,
    this.progress = 0,
    this.errorMessage,
  });

  final AppUpdateDownloadStatus status;

  /// 0.0–1.0. Only meaningful while [status] is downloading.
  final double progress;

  final String? errorMessage;

  bool get isBusy => status == AppUpdateDownloadStatus.downloading || status == AppUpdateDownloadStatus.installing;

  AppUpdateDownloadState copyWith({
    AppUpdateDownloadStatus? status,
    double? progress,
    String? errorMessage,
  }) {
    return AppUpdateDownloadState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage,
    );
  }
}
