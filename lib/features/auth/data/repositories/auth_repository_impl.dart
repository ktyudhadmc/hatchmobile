import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDatasourceProvider),
    ref.watch(authLocalDatasourceProvider),
  );
});

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._local);

  final AuthRemoteDatasource _remote;
  final AuthLocalDatasource _local;

  @override
  Future<User> login({
    required String username,
    required String password,
  }) async {
    try {
      final result = await _remote.login(
        username: username,
        password: password,
      );

      await _local.saveSession(token: result.token, user: result.user);
      return result.user;
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remote.logout();
    } on DioException {
      // Ignore network errors on logout: clear the local session regardless.
    } finally {
      await _local.clear();
    }
  }

  @override
  Future<void> clearSession() => _local.clear();

  @override
  Future<User?> getCachedUser() => _local.readCachedUser();

  @override
  Future<User> fetchCurrentUser() async {
    try {
      return await _remote.fetchProfile();
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  AppException _unwrap(DioException e) {
    return e.error is AppException
        ? e.error as AppException
        : const AppException('Terjadi kesalahan');
  }
}
