import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

import 'core/constants/app_constants.dart';
import 'core/firebase/firebase_bootstrapper.dart';
import 'core/navigation/app_navigator.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/device_info_helper.dart';
import 'features/app_update/data/update_apk_cleanup.dart';
import 'shared/widgets/connectivity_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await DeviceInfoHelper.instance.init();
  await FirebaseBootstrapper().initialize();

  // One-off reclaim of whatever old update APKs already piled up before
  // downloadAndInstall started cleaning up after itself — not awaited, so
  // it doesn't delay startup.
  unawaited(purgeStaleUpdateApks());

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return ToastificationWrapper(
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: router,
        builder: (context, child) => ConnectivityGate(
          navigatorKey: appNavigatorKey,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
