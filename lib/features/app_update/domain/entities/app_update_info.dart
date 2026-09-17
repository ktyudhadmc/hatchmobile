import 'package:equatable/equatable.dart';

/// A newer release found on GitLab, ready to offer the user.
class AppUpdateInfo extends Equatable {
  const AppUpdateInfo({required this.version, required this.apkUrl});

  /// Release version without the leading "v" (e.g. "1.2.0").
  final String version;

  /// Direct download URL of the release's APK asset.
  final String apkUrl;

  @override
  List<Object?> get props => [version, apkUrl];
}
