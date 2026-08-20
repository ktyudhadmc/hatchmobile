class AppConstants {
  AppConstants._();

  static const String appName = 'Hatchery';
  static const String appVersion = '0.1.0';

  // Toggle this when pointing the app at a local backend during development.
  static const bool useLocalBackend = true;
  static const String _prodBaseUrl = 'https://api-hatchery.appdmc.my.id';
  static const String _localBaseUrl = 'http://192.168.68.181:8000';
  static String get baseUrl => useLocalBackend ? _localBaseUrl : _prodBaseUrl;

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

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
