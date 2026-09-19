import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Every downloaded APK is named `hatchmobile-<version>.apk`, so this
/// matches all of them regardless of version.
final _downloadedApkPattern = RegExp(r'^hatchmobile-.*\.apk$');

/// Deletes every downloaded-update APK sitting in the temp dir, except
/// [exceptPath] if one's given (the file currently being installed).
///
/// Used in two places: [AppUpdateDownloadNotifier] calls it before each new
/// download so leftovers never accumulate going forward, and `main()` calls
/// it once at startup to reclaim whatever already piled up from before that
/// cleanup existed — past versions of this app downloaded a new APK on every
/// update and never deleted any of them, which is how installs were found
/// using hundreds of MB of device storage.
Future<void> purgeStaleUpdateApks({String? exceptPath}) async {
  final dir = await getTemporaryDirectory();
  if (!await dir.exists()) return;

  await for (final entry in dir.list()) {
    if (entry is! File) continue;
    if (entry.path == exceptPath) continue;
    if (!_downloadedApkPattern.hasMatch(entry.uri.pathSegments.last)) continue;
    await _deleteQuietly(entry.path);
  }
}

Future<void> _deleteQuietly(String path) async {
  try {
    await File(path).delete();
  } catch (_) {
    // Best-effort cleanup — a locked/already-gone file isn't worth failing
    // over.
  }
}
