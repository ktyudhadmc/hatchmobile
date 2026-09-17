import '../entities/app_update_info.dart';

abstract class AppUpdateRepository {
  /// Returns the latest stable release on GitLab if it's newer than
  /// [currentVersion], otherwise null. Also null (not thrown) on any
  /// network/parse failure — a failed check should never block the user
  /// from using the app.
  Future<AppUpdateInfo?> checkForUpdate(String currentVersion);
}
