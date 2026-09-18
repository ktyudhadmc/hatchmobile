import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../data/repositories/app_update_repository_impl.dart';
import '../../domain/entities/app_update_info.dart';
import '../../domain/usecases/check_for_update_usecase.dart';

final currentAppVersionProvider = FutureProvider<String>((ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
});

/// Null data means the check succeeded but there's no newer release. A
/// failed check surfaces as [AsyncError] instead, so the UI (see
/// AppUpdateBanner) can tell the two apart.
final appUpdateCheckProvider = FutureProvider<AppUpdateInfo?>((ref) async {
  final currentVersion = await ref.watch(currentAppVersionProvider.future);
  final usecase = CheckForUpdateUsecase(ref.watch(appUpdateRepositoryProvider));
  return usecase(currentVersion);
});
