import '../entities/app_update_info.dart';

abstract class AppUpdateRepository {
  /// Returns the latest stable release (from GitHub or GitLab, per
  /// [AppConstants.updateSource]) if it's newer than [currentVersion],
  /// otherwise null (fetched fine, nothing newer). Throws on network/parse
  /// failure — callers distinguish "checked, already latest" from "check
  /// failed" this way instead of collapsing both into null.
  Future<AppUpdateInfo?> checkForUpdate(String currentVersion);
}
