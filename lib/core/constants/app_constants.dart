/// Which host the in-app update feature reads Releases from.
enum UpdateSource { github, gitlab }

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

  // In-app update: checks the chosen host's latest release (published on
  // every vX.Y.Z tag) and offers the APK asset as an update. No auth token
  // needed for either host — both projects are public, so their Releases
  // API and APK assets are readable anonymously.
  //
  // Toggle this to switch which host the update check reads from.
  static const UpdateSource updateSource = UpdateSource.github;

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
