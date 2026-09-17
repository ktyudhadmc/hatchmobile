import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../data/repositories/app_update_repository_impl.dart';
import '../../domain/entities/app_update_info.dart';
import '../../domain/usecases/check_for_update_usecase.dart';

final currentAppVersionProvider = FutureProvider<String>((ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
});

/// Null means either there's no newer release, or the check failed — both
/// cases just mean "don't show the update button".
final appUpdateCheckProvider = FutureProvider<AppUpdateInfo?>((ref) async {
  final currentVersion = await ref.watch(currentAppVersionProvider.future);
  final usecase = CheckForUpdateUsecase(ref.watch(appUpdateRepositoryProvider));
  return usecase(currentVersion);
});
