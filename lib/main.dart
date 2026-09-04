import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

import 'core/constants/app_constants.dart';
import 'core/firebase/firebase_bootstrapper.dart';
import 'core/navigation/app_navigator.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/device_info_helper.dart';
import 'shared/widgets/connectivity_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DeviceInfoHelper.instance.init();
  await FirebaseBootstrapper().initialize();

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
