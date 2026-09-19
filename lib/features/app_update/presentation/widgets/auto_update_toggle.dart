import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/auto_update_provider.dart';

/// Lets the user opt into installing a newer release automatically the
/// moment [appUpdateCheckProvider] finds one, instead of tapping Update
/// themselves — see the auto-install check in [AppUpdateBanner].
class AutoUpdateToggle extends ConsumerWidget {
  const AutoUpdateToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(autoUpdateEnabledProvider);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffF5F8FA)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Auto update',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 2),
                Text(
                  'Download and install new updates automatically, without '
                  'waiting for you to tap Update.',
                  style: TextStyle(color: Color(0xFF7B7B7B), fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            activeThumbColor: AppTheme.primaryColor,
            onChanged: (value) =>
                ref.read(autoUpdateEnabledProvider.notifier).setEnabled(value),
          ),
        ],
      ),
    );
  }
}
