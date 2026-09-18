import 'app_constants.dart';

/// Endpoints on GitHub's own API (api.github.com), not the app backend —
/// used by the in-app update feature to read this project's latest tagged
/// release.
class GithubEndpoints {
  GithubEndpoints._();

  static String get latestRelease =>
      '${AppConstants.githubApiBaseUrl}/repos/${AppConstants.githubRepoPath}/releases/latest';
}
