import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/network/dio_client.dart';

const _autoUpdateStorageKey = 'auto_update_enabled';

/// Whether a newer release should be downloaded and installed automatically
/// as soon as [appUpdateCheckProvider] finds one, instead of waiting for the
/// user to tap Update. Persisted so the choice survives app restarts.
final autoUpdateEnabledProvider =
    StateNotifierProvider<AutoUpdateEnabledNotifier, bool>((ref) {
      return AutoUpdateEnabledNotifier(ref.watch(secureStorageProvider));
    });

class AutoUpdateEnabledNotifier extends StateNotifier<bool> {
  AutoUpdateEnabledNotifier(this._storage) : super(false) {
    _load();
  }

  final FlutterSecureStorage _storage;

  Future<void> _load() async {
    final raw = await _storage.read(key: _autoUpdateStorageKey);
    state = raw == 'true';
  }

  Future<void> setEnabled(bool value) async {
    state = value;
    await _storage.write(key: _autoUpdateStorageKey, value: value.toString());
  }
}
