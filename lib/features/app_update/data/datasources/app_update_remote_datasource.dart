import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/github_endpoints.dart';
import '../../../../core/constants/gitlab_endpoints.dart';
import '../../../../core/firebase/remote_config/domain/remote_config_service.dart';
import '../../../../core/firebase/remote_config/firebase_remote_config_module.dart';
import '../../../../core/firebase/remote_config/presentation/remote_config_provider.dart';
import '../../../../core/network/github_dio_client.dart';
import '../../../../core/network/gitlab_dio_client.dart';
import '../models/app_update_model.dart';

final appUpdateRemoteDatasourceProvider = Provider<AppUpdateRemoteDatasource>(
  (ref) => AppUpdateRemoteDatasource(
    github: ref.watch(githubDioProvider),
    gitlab: ref.watch(gitlabDioProvider),
    remoteConfig: ref.watch(remoteConfigServiceProvider),
  ),
);

class AppUpdateRemoteDatasource {
  AppUpdateRemoteDatasource({
    required Dio github,
    required Dio gitlab,
    required RemoteConfigService remoteConfig,
  }) : _github = github,
       _gitlab = gitlab,
       _remoteConfig = remoteConfig;

  final Dio _github;
  final Dio _gitlab;
  final RemoteConfigService _remoteConfig;

  /// Which host the update check should use — read fresh off Remote
  /// Config every call (rather than cached at construction) so a toggle
  /// in the Firebase console takes effect on this device's next periodic
  /// fetch without needing a restart. See
  /// [UpdateSource.fromRemoteConfigValue] for the fallback when unset.
  UpdateSource get _activeSource => UpdateSource.fromRemoteConfigValue(
    _remoteConfig.getString(RemoteConfigKeys.appUpdateSource),
  );

  Dio get _activeDio =>
      _activeSource == UpdateSource.github ? _github : _gitlab;

  Future<AppUpdateModel?> fetchLatestRelease() async {
    switch (_activeSource) {
      case UpdateSource.github:
        final response = await _github.get(GithubEndpoints.latestRelease);
        return AppUpdateModel.fromGithubRelease(
          response.data as Map<String, dynamic>,
        );
      case UpdateSource.gitlab:
        final response = await _gitlab.get(GitlabEndpoints.latestRelease);
        return AppUpdateModel.fromGitlabRelease(
          response.data as Map<String, dynamic>,
        );
    }
  }

  Future<void> downloadApk(
    String url,
    String savePath, {
    void Function(int received, int total)? onProgress,
  }) {
    return _activeDio.download(url, savePath, onReceiveProgress: onProgress);
  }
}
