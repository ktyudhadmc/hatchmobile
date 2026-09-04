import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/firebase_remote_config_service.dart';
import '../domain/remote_config_service.dart';

final remoteConfigServiceProvider = Provider<RemoteConfigService>(
  (_) => FirebaseRemoteConfigService(),
);
