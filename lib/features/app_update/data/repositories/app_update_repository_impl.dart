import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_update_info.dart';
import '../../domain/repositories/app_update_repository.dart';
import '../datasources/app_update_remote_datasource.dart';

final appUpdateRepositoryProvider = Provider<AppUpdateRepository>((ref) {
  return AppUpdateRepositoryImpl(ref.watch(appUpdateRemoteDatasourceProvider));
});

class AppUpdateRepositoryImpl implements AppUpdateRepository {
  AppUpdateRepositoryImpl(this._remote);

  final AppUpdateRemoteDatasource _remote;

  @override
  Future<AppUpdateInfo?> checkForUpdate(String currentVersion) async {
    // Network/parse failures are intentionally NOT caught here — they
    // propagate so appUpdateCheckProvider resolves to AsyncError, letting
    // the UI tell "check failed" apart from "checked fine, already latest"
    // (both of which would otherwise collapse into the same null).
    final latest = await _remote.fetchLatestRelease();
    if (latest == null) return null;
    return _isNewer(latest.version, currentVersion) ? latest : null;
  }

  /// Compares two `X.Y.Z` version strings numerically, part by part
  /// (so "1.9.0" < "1.10.0", unlike a plain string comparison).
  bool _isNewer(String latest, String current) {
    final latestParts = _parseParts(latest);
    final currentParts = _parseParts(current);
    if (latestParts == null || currentParts == null) return false;

    for (var i = 0; i < 3; i++) {
      if (latestParts[i] != currentParts[i]) {
        return latestParts[i] > currentParts[i];
      }
    }
    return false;
  }

  List<int>? _parseParts(String version) {
    final segments = version.split('.');
    if (segments.length != 3) return null;
    final parts = segments.map(int.tryParse).toList();
    return parts.contains(null) ? null : parts.cast<int>();
  }
}
