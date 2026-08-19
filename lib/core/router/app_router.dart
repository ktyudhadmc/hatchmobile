import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/transfer/domain/entities/transfer_basket.dart';
import '../../features/transfer/presentation/pages/scan_page.dart';
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
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
      GoRoute(path: '/scan', builder: (context, state) => const ScanPage()),
      GoRoute(
        path: '/transfer/confirm',
        builder: (context, state) => TransferConfirmPage(basket: state.extra as TransferBasket),
      ),
    ],
  );
});
