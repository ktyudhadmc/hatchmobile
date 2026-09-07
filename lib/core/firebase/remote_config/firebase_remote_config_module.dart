import '../firebase_module.dart';
import 'data/firebase_remote_config_service.dart';

class FirebaseRemoteConfigModule implements FirebaseModule {
  const FirebaseRemoteConfigModule(this._service);

  final FirebaseRemoteConfigService _service;

  @override
  Future<void> initialize() => _service.initialize();
}
