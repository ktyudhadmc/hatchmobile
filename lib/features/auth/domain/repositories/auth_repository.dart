import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({required String username, required String password});

  Future<void> logout();

  /// Returns the cached user if there's one stored locally, without
  /// hitting the network. Used to decide the initial route on app start.
  Future<User?> getCachedUser();

  Future<User> fetchCurrentUser();
}
