import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUsecase {
  LoginUsecase(this._repository);

  final AuthRepository _repository;

  Future<User> call({required String username, required String password}) {
    return _repository.login(username: username, password: password);
  }
}
