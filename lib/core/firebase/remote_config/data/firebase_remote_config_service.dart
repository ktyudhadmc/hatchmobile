import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import '../domain/remote_config_service.dart';

class FirebaseRemoteConfigService implements RemoteConfigService {
  FirebaseRemoteConfigService([FirebaseRemoteConfig? remoteConfig])
    : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  final FirebaseRemoteConfig _remoteConfig;

  /// Configure defaults before a fetch so every consumer has predictable
  /// values, including on first launch or while offline.
  Future<void> initialize({Map<String, Object> defaults = const {}}) async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: kDebugMode
            ? const Duration(minutes: 1)
            : const Duration(hours: 12),
      ),
    );
    await _remoteConfig.setDefaults(defaults);
    await refresh();
  }

  @override
  Future<void> refresh() async {
    // Remote Config enhances the app; a failed network fetch must not block it.
    try {
      await _remoteConfig.fetchAndActivate();
    } on FirebaseException {
      // Defaults / last activated values remain available.
    }
  }

  @override
  bool getBool(String key) => _remoteConfig.getBool(key);

  @override
  double getDouble(String key) => _remoteConfig.getDouble(key);

  @override
  int getInt(String key) => _remoteConfig.getInt(key);

  @override
  String getString(String key) => _remoteConfig.getString(key);
}
