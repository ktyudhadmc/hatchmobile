import 'app_constants.dart';

/// Endpoints on GitLab's own API (gitlab.com), not the app backend — used by
/// the in-app update feature to read this project's latest tagged release
/// when the `app_update_source` Remote Config value resolves to
/// [UpdateSource.gitlab].
class GitlabEndpoints {
  GitlabEndpoints._();

  static String get _encodedProjectPath =>
      Uri.encodeComponent(AppConstants.gitlabProjectPath);

  static String get latestRelease =>
      '${AppConstants.gitlabApiBaseUrl}/projects/$_encodedProjectPath/releases/permalink/latest';
}
