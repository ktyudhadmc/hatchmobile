import '../../constants/app_constants.dart';
import '../firebase_module.dart';
import 'data/firebase_remote_config_service.dart';

/// Keys read via [RemoteConfigService] elsewhere in the app — kept here
/// next to their defaults so the two never drift apart.
abstract final class RemoteConfigKeys {
  /// Remote kill-switch for the developer log page (see DevLogPage),
  /// independent of DeviceInfoHelper.isCanaryBuild. Lets support turn on
  /// scanner/API logging on a *stable* build already in someone's hand —
  /// to chase down a report — without shipping a new APK.
  static const enableDevLog = 'enable_dev_log';

  /// Which host (`"github"` or `"gitlab"`) the in-app updater reads
  /// Releases from — see [UpdateSource.fromRemoteConfigValue]. Lets that
  /// host be switched (e.g. GitHub rate-limited, migrating to GitLab)
  /// without shipping a new build.
  static const appUpdateSource = 'app_update_source';
}

class FirebaseRemoteConfigModule implements FirebaseModule {
  const FirebaseRemoteConfigModule(this._service);

  final FirebaseRemoteConfigService _service;

  @override
  Future<void> initialize() => _service.initialize(
    defaults: {
      RemoteConfigKeys.enableDevLog: false,
      RemoteConfigKeys.appUpdateSource: AppConstants.updateSource.name,
    },
  );
}
