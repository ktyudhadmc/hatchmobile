import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUsecase {
  GetCurrentUserUsecase(this._repository);

  final AuthRepository _repository;

  Future<User?> call() => _repository.getCachedUser();
}
