import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({required String username, required String password});

  Future<void> logout();

  /// Clears the local session only, without calling the logout endpoint —
  /// used when the server has already invalidated the session (401) so
  /// there's nothing to tell it.
  Future<void> clearSession();

  /// Returns the cached user if there's one stored locally, without
  /// hitting the network. Used to decide the initial route on app start.
  Future<User?> getCachedUser();

  Future<User> fetchCurrentUser();
}
