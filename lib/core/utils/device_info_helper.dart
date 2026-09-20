import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Collects device/app metadata once at startup so it can be attached to
/// every outgoing API request (see [core/network/dio_client.dart]).
class DeviceInfoHelper {
  DeviceInfoHelper._();
  static final DeviceInfoHelper instance = DeviceInfoHelper._();

  String platform = Platform.operatingSystem;
  String appVersion = '';
  String deviceId = '';

  /// This build's release channel, parsed off the versionName CI set via
  /// `--build-name` from the git tag (see .github/workflows/build.yml):
  /// `vX.Y.Z-alpha.N` → `alpha`, `-beta.N` → `beta`, `-rc.N` → `rc`,
  /// `-snapshot.N` → `snapshot`; a plain `vX.Y.Z` → `stable`. Reported to
  /// Analytics as the `build_channel` user property (see
  /// FirebaseAnalyticsModule) so canary/production usage can be told apart
  /// in dashboards.
  String buildChannel = 'stable';

  /// True for a pre-release build — i.e. [buildChannel] is anything but
  /// `stable`. Gates the developer log page (see DevLogPage) so it only
  /// ever shows up on a build cut from one of those tags, never on a
  /// stable release.
  bool get isCanaryBuild => buildChannel != 'stable';

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    final packageInfo = await PackageInfo.fromPlatform();
    appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    final channelMatch = RegExp(
      r'-(alpha|beta|rc|snapshot)\.\d+',
    ).firstMatch(packageInfo.version);
    buildChannel = channelMatch?.group(1) ?? 'stable';

    final deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final info = await deviceInfoPlugin.androidInfo;
        deviceId = info.id;
      } else if (Platform.isIOS) {
        final info = await deviceInfoPlugin.iosInfo;
        deviceId = info.identifierForVendor ?? '';
      }
    } catch (_) {
      deviceId = '';
    }

    _initialized = true;
  }

  String get userAgent => 'hatchmobile/$appVersion ($platform)';
}
