import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/home/presentation/pages/history_page.dart';
import '../../features/transfer/presentation/pages/scan_page.dart';
import '../navigation/app_navigator.dart';

/// Notifies go_router whenever [authProvider] changes, so it re-runs
/// `redirect` on whatever page the user is currently on. Deliberately not
/// `ref.watch`-ing authProvider directly inside routerProvider itself —
/// that would rebuild this whole provider (and therefore construct a brand
/// new GoRouter) on every auth change, which resets navigation back to
/// `initialLocation` regardless of where the user actually was.
class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(Ref ref) {
    ref.listen<AsyncValue<Object?>>(authProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authRefreshListenable = _AuthRefreshListenable(ref);

  return GoRouter(
    navigatorKey: appNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: authRefreshListenable,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoading = authState.isLoading;
      final isAuthenticated = authState.valueOrNull != null;
      final isSplash = state.matchedLocation == '/splash';
      final isLoggingIn = state.matchedLocation == '/login';

      if (isLoading) return isSplash ? null : '/splash';
      if (!isAuthenticated) return isLoggingIn ? null : '/login';
      if (isLoggingIn || isSplash) return '/scan';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SplashPage()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: LoginPage()),
      ),
      GoRoute(
        path: '/scan',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: ScanPage()),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: HistoryPage()),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: ProfilePage()),
      ),
    ],
  );
});
