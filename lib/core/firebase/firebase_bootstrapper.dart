import 'analytics/data/firebase_analytics_service.dart';
import 'analytics/firebase_analytics_module.dart';
import 'firebase_connector.dart';
import 'firebase_module.dart';
import 'messaging/data/firebase_messaging_service.dart';
import 'messaging/firebase_messaging_module.dart';
import 'remote_config/data/firebase_remote_config_service.dart';
import 'remote_config/firebase_remote_config_module.dart';

/// Initializes Firebase core before independently configuring each enabled
/// Firebase product. Add a module here to enable a new product at app start.
class FirebaseBootstrapper {
  FirebaseBootstrapper({
    FirebaseConnector connector = const FirebaseConnector(),
    List<FirebaseModule> Function()? modulesFactory,
  }) : _connector = connector,
       _modulesFactory = modulesFactory ?? _defaultModules;

  final FirebaseConnector _connector;
  final List<FirebaseModule> Function() _modulesFactory;

  static List<FirebaseModule> _defaultModules() => [
    FirebaseAnalyticsModule(FirebaseAnalyticsService()),
    FirebaseRemoteConfigModule(FirebaseRemoteConfigService()),
    FirebaseMessagingModule(FirebaseMessagingService()),
  ];

  Future<void> initialize() async {
    await _connector.connect(); // Firebase.initializeApp() happens here
    final modules =
        _modulesFactory(); // ← services created AFTER Firebase is ready
    for (final module in modules) {
      await module.initialize();
    }
  }
}
