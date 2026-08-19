import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((
  ref,
) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(
    loginUsecase: LoginUsecase(repository),
    logoutUsecase: LogoutUsecase(repository),
    getCurrentUserUsecase: GetCurrentUserUsecase(repository),
  );
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
  }) : super(const AsyncValue.loading()) {
    restoreSession();
  }

  final LoginUsecase loginUsecase;
  final LogoutUsecase logoutUsecase;
  final GetCurrentUserUsecase getCurrentUserUsecase;

  Future<void> restoreSession() async {
    state = const AsyncValue.loading();
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
}
