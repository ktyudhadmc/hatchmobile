/// Read-only contract exposed to features. Firebase-specific value objects do
/// not escape this boundary.
abstract interface class RemoteConfigService {
  Future<void> refresh();

  bool getBool(String key);
  int getInt(String key);
  double getDouble(String key);
  String getString(String key);
}
