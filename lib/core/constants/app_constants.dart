/// Which host the in-app update feature reads Releases from.
enum UpdateSource {
  github,
  gitlab;

  static UpdateSource fromRemoteConfigValue(String value) {
    switch (value.trim().toLowerCase()) {
      case 'github':
        return UpdateSource.github;
      case 'gitlab':
        return UpdateSource.gitlab;
      default:
        return AppConstants.updateSource;
    }
  }
}

/// Set via --dart-define=DISTRIBUTION_CHANNEL=play in the "play" Gradle
/// flavor build. Play Store handles app updates itself, so that build must
/// not show the in-app updater UI (its APK install flow needs
/// REQUEST_INSTALL_PACKAGES, which the play flavor's manifest strips).
const bool isPlayDistribution =
    String.fromEnvironment('DISTRIBUTION_CHANNEL') == 'play';

class AppConstants {
  AppConstants._();

  static const String appName = 'Hatchery';
  static const String appVersion = '0.1.0';

  // Toggle this when pointing the app at a local backend during development.
  static const bool useLocalBackend = false;
  static const String _prodBaseUrl = 'https://api-hatchery.appdmc.my.id';
  static const String _localBaseUrl = 'http://192.168.68.181:8000';
  static String get baseUrl => useLocalBackend ? _localBaseUrl : _prodBaseUrl;

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static const UpdateSource updateSource = UpdateSource.gitlab;

  static const String githubApiBaseUrl = 'https://api.github.com';
  static const String githubRepoPath = 'ktyudhadmc/hatchmobile';

  static const String gitlabApiBaseUrl = 'https://gitlab.com/api/v4';
  static const String gitlabProjectPath = 'developerdmc/hatchery/mobile';

  // Secure storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'auth_user';

  // Pagination
  static const int defaultPageSize = 20;

  // Date formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String apiDateFormat = 'yyyy-MM-dd';
}
