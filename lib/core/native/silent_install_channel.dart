import 'package:flutter/services.dart';

/// Bridge to the native (Android) side that installs an APK through
/// [PackageInstaller] without the OS's install-confirmation prompt.
///
/// That prompt can only be skipped when this app is the device's
/// [Device Owner](https://developer.android.com/work/dpc/build-dpc#device_owner)
/// (Android Enterprise provisioning) — on any other device [isDeviceOwner]
/// returns false and callers should fall back to the normal
/// hand-the-APK-to-the-OS-installer flow.
class SilentInstallChannel {
  SilentInstallChannel._();

  static const _channel = MethodChannel('com.appdmc.hatchery/silent_install');

  static Future<bool> isDeviceOwner() async {
    try {
      return await _channel.invokeMethod<bool>('isDeviceOwner') ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Installs the APK at [apkPath] silently. Throws [PlatformException] if
  /// this device isn't Device Owner or the install otherwise fails.
  static Future<void> silentInstall(String apkPath) {
    return _channel.invokeMethod('silentInstall', {'apkPath': apkPath});
  }
}
