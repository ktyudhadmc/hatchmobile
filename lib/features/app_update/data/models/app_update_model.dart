import '../../domain/entities/app_update_info.dart';

class AppUpdateModel extends AppUpdateInfo {
  const AppUpdateModel({required super.version, required super.apkUrl});

  /// Parses a GitHub `GET /repos/{owner}/{repo}/releases/latest` response.
  ///
  /// Returns null if the release has no tag matching `vX.Y.Z` (pre-release
  /// tags like `-rc.1` are intentionally excluded from auto-update) or has
  /// no `.apk` asset attached yet.
  static AppUpdateModel? fromGithubRelease(Map<String, dynamic> json) {
    final version = _stableVersion(json['tag_name'] as String?);
    if (version == null) return null;

    final assets = json['assets'];
    if (assets is! List) return null;

    final apkUrl = assets
        .whereType<Map<String, dynamic>>()
        .map((asset) => asset['browser_download_url'] as String?)
        .firstWhere((url) => url != null && url.endsWith('.apk'), orElse: () => null);
    if (apkUrl == null) return null;

    return AppUpdateModel(version: version, apkUrl: apkUrl);
  }

  /// Parses a GitLab `GET /releases/permalink/latest` response.
  ///
  /// Same rules as [fromGithubRelease], just a different asset shape.
  static AppUpdateModel? fromGitlabRelease(Map<String, dynamic> json) {
    final version = _stableVersion(json['tag_name'] as String?);
    if (version == null) return null;

    final links = (json['assets'] as Map<String, dynamic>?)?['links'];
    if (links is! List) return null;

    final apkUrl = links
        .whereType<Map<String, dynamic>>()
        .map((link) => link['url'] as String?)
        .firstWhere((url) => url != null && url.endsWith('.apk'), orElse: () => null);
    if (apkUrl == null) return null;

    return AppUpdateModel(version: version, apkUrl: apkUrl);
  }

  static final _stableTagPattern = RegExp(r'^v(\d+\.\d+\.\d+)$');

  static String? _stableVersion(String? tagName) {
    if (tagName == null) return null;
    return _stableTagPattern.firstMatch(tagName)?.group(1);
  }
}
