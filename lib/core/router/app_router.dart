import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/transfer/domain/entities/transfer_basket.dart';
import '../../features/transfer/presentation/pages/transfer_confirm_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Watching authProvider recreates the router (and re-runs redirect) on
  // every login/logout/session-restore, so navigation always reflects the
  // latest auth state.
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final isAuthenticated = authState.valueOrNull != null;
      final isSplash = state.matchedLocation == '/splash';
      final isLoggingIn = state.matchedLocation == '/login';

      if (isLoading) return isSplash ? null : '/splash';
      if (!isAuthenticated) return isLoggingIn ? null : '/login';
      if (isLoggingIn || isSplash) return '/home';
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
        path: '/home',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: HomePage()),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: ProfilePage()),
      ),
      GoRoute(
        path: '/transfer/confirm',
        // Only reachable right after a scan, which always passes the
        // scanned basket via `extra` — this guard is scoped to just this
        // route so it doesn't run on every navigation.
        redirect: (context, state) =>
            state.extra is! TransferBasket ? '/home' : null,
        builder: (context, state) =>
            TransferConfirmPage(basket: state.extra as TransferBasket),
      ),
    ],
  );
});
