import '../entities/app_update_info.dart';
import '../repositories/app_update_repository.dart';

class CheckForUpdateUsecase {
  CheckForUpdateUsecase(this._repository);

  final AppUpdateRepository _repository;

  Future<AppUpdateInfo?> call(String currentVersion) =>
      _repository.checkForUpdate(currentVersion);
}
