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

  /// True for a pre-release build — i.e. one tagged `vX.Y.Z-rc.N`,
  /// `-beta.N` or `-snapshot.N` in CI (see .github/workflows/build.yml),
  /// which becomes this build's versionName via `--build-name`. Gates the
  /// developer log page (see DevLogPage) so it only ever shows up on a
  /// build cut from one of those tags, never on a stable release.
  bool isBeta = false;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    final packageInfo = await PackageInfo.fromPlatform();
    appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    isBeta = RegExp(
      r'-(rc|beta|snapshot)\.\d+',
    ).hasMatch(packageInfo.version);

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
