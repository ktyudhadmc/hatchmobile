import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/dev_log.dart';

/// Developer log page — only reachable from pre-release builds (see
/// [DeviceInfoHelper.isBeta]). Shows scanner detections and API call
/// outcomes in real time so field testers can screenshot/share it instead
/// of describing what happened.
class DevLogPage extends StatelessWidget {
  const DevLogPage({super.key});

  static final _timeFormat = DateFormat('HH:mm:ss');

  Color _colorFor(DevLogLevel level) {
    switch (level) {
      case DevLogLevel.success:
        return Colors.green;
      case DevLogLevel.error:
        return Colors.red;
      case DevLogLevel.info:
        return Colors.blueGrey;
    }
  }

  IconData _iconFor(DevLogLevel level) {
    switch (level) {
      case DevLogLevel.success:
        return Icons.check_circle;
      case DevLogLevel.error:
        return Icons.error;
      case DevLogLevel.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear log',
            onPressed: DevLog.instance.clear,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: DevLog.instance,
        builder: (context, _) {
          final entries = DevLog.instance.entries;

          if (entries.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada aktivitas.\nScan barcode atau panggil API untuk melihat log.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: entries.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return ListTile(
                dense: true,
                leading: Icon(
                  _iconFor(entry.level),
                  color: _colorFor(entry.level),
                  size: 20,
                ),
                title: Text(
                  entry.message,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                  ),
                ),
                subtitle: Text(
                  '${entry.tag.label} · ${_timeFormat.format(entry.timestamp)}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
