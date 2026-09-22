import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/refreshable_view.dart';
import '../providers/app_update_provider.dart';
import '../providers/install_permission_provider.dart';
import '../widgets/allow_install_updates_card.dart';
import '../widgets/app_update_banner.dart';
import '../widgets/auto_update_toggle.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The permission is granted from the system Settings screen, outside
    // the app — re-check once the user comes back to it.
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(canInstallUpdatesProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: RefreshableView(
        onRefresh: () async {
          if (isPlayDistribution) return;
          ref.invalidate(appUpdateCheckProvider);
          ref.invalidate(canInstallUpdatesProvider);
          await ref.read(appUpdateCheckProvider.future).catchError((_) => null);
        },
        slivers: [
          if (!isPlayDistribution)
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList.list(
                children: const [
                  AppUpdateBanner(),
                  AutoUpdateToggle(),
                  AllowInstallUpdatesCard(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
