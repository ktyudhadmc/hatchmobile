/// Product-neutral analytics contract used by application features.
abstract interface class AnalyticsService {
  Future<void> logEvent(String name, {Map<String, Object>? parameters});

  Future<void> setUserId(String? userId);

  Future<void> setUserProperty({required String name, required String? value});
}
