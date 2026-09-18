import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/native/silent_install_channel.dart';
import '../providers/install_permission_provider.dart';

/// Card that lets the user grant the OS permission in-app updates need to
/// actually install (Android 8+ blocks a sideloaded app from handing an
/// APK to the installer until the user allows it once, per app). Hidden
/// once granted — nothing left for the user to do.
class AllowInstallUpdatesCard extends ConsumerWidget {
  const AllowInstallUpdatesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canInstall = ref.watch(canInstallUpdatesProvider).valueOrNull;
    if (canInstall == null || canInstall) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.privacy_tip_outlined,
                color: Colors.orange,
                size: 22,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Allow app updates',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Turn this on so Hatchery can install the updates it '
                      'downloads for you.',
                      style: TextStyle(color: Color(0xFF7B7B7B), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => SilentInstallChannel.openInstallUpdatesSettings(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Turn on',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
