import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/native/silent_install_channel.dart';

/// Whether the OS currently lets this app hand a downloaded APK to the
/// installer at all. False on a fresh install on Android 8+ until the user
/// grants it once via [SilentInstallChannel.openInstallUpdatesSettings] —
/// see [AllowInstallUpdatesCard].
final canInstallUpdatesProvider = FutureProvider<bool>((ref) {
  return SilentInstallChannel.canInstallUpdates();
});
