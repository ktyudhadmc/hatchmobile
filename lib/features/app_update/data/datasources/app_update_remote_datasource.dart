import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/github_endpoints.dart';
import '../../../../core/constants/gitlab_endpoints.dart';
import '../../../../core/network/github_dio_client.dart';
import '../../../../core/network/gitlab_dio_client.dart';
import '../models/app_update_model.dart';

final appUpdateRemoteDatasourceProvider = Provider<AppUpdateRemoteDatasource>(
  (ref) => AppUpdateRemoteDatasource(
    github: ref.watch(githubDioProvider),
    gitlab: ref.watch(gitlabDioProvider),
  ),
);

class AppUpdateRemoteDatasource {
  AppUpdateRemoteDatasource({required Dio github, required Dio gitlab})
    : _github = github,
      _gitlab = gitlab;

  final Dio _github;
  final Dio _gitlab;

  /// Which host's Dio client and download link the update check should use,
  /// per [AppConstants.updateSource].
  Dio get _activeDio =>
      AppConstants.updateSource == UpdateSource.github ? _github : _gitlab;

  Future<AppUpdateModel?> fetchLatestRelease() async {
    switch (AppConstants.updateSource) {
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
