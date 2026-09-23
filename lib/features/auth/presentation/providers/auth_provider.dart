import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/auth_events.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((
  ref,
) {
  final repository = ref.watch(authRepositoryProvider);
  final notifier = AuthNotifier(
    loginUsecase: LoginUsecase(repository),
    logoutUsecase: LogoutUsecase(repository),
    getCurrentUserUsecase: GetCurrentUserUsecase(repository),
    clearSession: repository.clearSession,
  );

  // The dio_client's 401 interceptor broadcasts here instead of reaching
  // into this provider directly (core/network can't depend on
  // features/auth) — forward it into a forced logout.
  final subscription = ref
      .watch(unauthorizedEventProvider)
      .stream
      .listen((_) => notifier.forceLogout());
  ref.onDispose(subscription.cancel);

  return notifier;
});

/// Derived flag the router watches to decide whether to redirect to /login.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).valueOrNull != null;
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier({
    required this.loginUsecase,
    required this.logoutUsecase,
    required this.getCurrentUserUsecase,
    required this.clearSession,
  }) : super(const AsyncValue.loading()) {
    restoreSession();
  }

  final LoginUsecase loginUsecase;
  final LogoutUsecase logoutUsecase;
  final GetCurrentUserUsecase getCurrentUserUsecase;
  final Future<void> Function() clearSession;

  Future<void> restoreSession() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => getCurrentUserUsecase());
  }

  /// Re-fetches the current user without clearing state to loading first —
  /// used for pull-to-refresh. [restoreSession] would work too, but its
  /// bare loading state makes `routerProvider`'s redirect (which bounces
  /// anything loading to /splash) fire mid-refresh, landing back on /scan
  /// once it resolves.
  Future<void> refreshCurrentUser() async {
    state = await AsyncValue.guard(() => getCurrentUserUsecase());
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => loginUsecase(username: username, password: password),
    );
  }

  Future<void> logout() async {
    await logoutUsecase();
    state = const AsyncValue.data(null);
  }

  /// Called when the server has already invalidated the session (401) — no
  /// point calling the logout endpoint, just drop the local session so the
  /// router's isAuthenticatedProvider check bounces to /login.
  Future<void> forceLogout() async {
    if (state.valueOrNull == null) return;
    await clearSession();
    state = const AsyncValue.data(null);
  }
}
