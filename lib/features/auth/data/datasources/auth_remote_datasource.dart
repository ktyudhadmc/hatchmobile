import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_service.dart';
import '../models/user_model.dart';

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(ref.watch(apiServiceProvider));
});

class AuthRemoteDatasource {
  AuthRemoteDatasource(this._apiService);

  final ApiService _apiService;

  Future<({String token, UserModel user})> login({
    required String username,
    required String password,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.login,
      data: {'username': username, 'password': password},
    );
    final data = response.data as Map<String, dynamic>;

    return (
      token: data['token'] as String,
      user: UserModel.fromJson(data['data'] as Map<String, dynamic>),
    );
  }

  Future<void> logout() async {
    await _apiService.post(ApiEndpoints.logout);
  }

  Future<UserModel> fetchProfile() async {
    final response = await _apiService.get(ApiEndpoints.profile);
    final data = response.data as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }
}
