import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_update_provider.dart';

/// Small, quiet pill showing the app's current version — deliberately low
/// contrast (unlike [AppUpdateBanner]) since it's just a reference stamp,
/// not something that needs attention.
class AppVersionTag extends ConsumerWidget {
  const AppVersionTag({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(currentAppVersionProvider).valueOrNull;
    if (version == null) return const SizedBox.shrink();

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xffF5F8FA),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          'v$version',
          style: const TextStyle(
            color: Color(0xff9AA0A6),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
