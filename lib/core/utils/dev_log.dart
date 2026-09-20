import 'package:flutter/foundation.dart';

enum DevLogLevel { info, success, error }

/// Closed set of log sources — every [DevLog.add] call must pick one of
/// these instead of typing a free-form string, so the tag shown on
/// [DevLogPage] always matches what's actually registered here.
enum DevLogTag {
  scanner('Scanner'),
  api('API');

  const DevLogTag(this.label);

  /// Display label shown on [DevLogPage].
  final String label;
}

class DevLogEntry {
  DevLogEntry({
    required this.tag,
    required this.message,
    required this.level,
    required this.timestamp,
  });

  final DevLogTag tag;
  final String message;
  final DevLogLevel level;
  final DateTime timestamp;
}

/// In-memory log of scanner/API activity, surfaced on the pre-release
/// build's developer log page (see [DeviceInfoHelper.isBeta]) so field testers can show
/// a screen instead of describing what happened over chat.
///
/// Kept as a plain [ChangeNotifier] singleton rather than a Riverpod
/// provider — it needs to be writable from usecases/repositories that don't
/// have a `WidgetRef`, and it never needs to be overridden in tests.
class DevLog extends ChangeNotifier {
  DevLog._();

  static final DevLog instance = DevLog._();

  static const int _maxEntries = 200;

  final List<DevLogEntry> _entries = [];

  List<DevLogEntry> get entries => List.unmodifiable(_entries.reversed);

  void add(
    DevLogTag tag,
    String message, {
    DevLogLevel level = DevLogLevel.info,
  }) {
    _entries.add(
      DevLogEntry(
        tag: tag,
        message: message,
        level: level,
        timestamp: DateTime.now(),
      ),
    );
    if (_entries.length > _maxEntries) _entries.removeAt(0);
    notifyListeners();
  }

  void clear() {
    _entries.clear();
    notifyListeners();
  }
}
