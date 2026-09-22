import 'package:flutter/material.dart';

// In-app APK updater is disabled — REQUEST_INSTALL_PACKAGES was dropped
// from the manifest to clear the undeclared-permission blocker in Play
// Console review, so the update banner/toggle/install-permission card
// (which relied on it) are no longer shown here.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Settings')));
  }
}
