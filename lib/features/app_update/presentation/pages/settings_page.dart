import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_update_provider.dart';
import '../widgets/app_update_banner.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentVersion = ref.watch(currentAppVersionProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const AppUpdateBanner(),
          if (currentVersion != null) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Installed version: v$currentVersion',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
