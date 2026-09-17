import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/gitlab_endpoints.dart';
import '../../../../core/network/gitlab_dio_client.dart';
import '../models/app_update_model.dart';

final appUpdateRemoteDatasourceProvider = Provider<AppUpdateRemoteDatasource>(
  (ref) => AppUpdateRemoteDatasource(ref.watch(gitlabDioProvider)),
);

class AppUpdateRemoteDatasource {
  AppUpdateRemoteDatasource(this._dio);

  final Dio _dio;

  Future<AppUpdateModel?> fetchLatestRelease() async {
    final response = await _dio.get(GitlabEndpoints.latestRelease);
    return AppUpdateModel.fromGitlabRelease(
      response.data as Map<String, dynamic>,
    );
  }

  Future<void> downloadApk(
    String url,
    String savePath, {
    void Function(int received, int total)? onProgress,
  }) {
    return _dio.download(url, savePath, onReceiveProgress: onProgress);
  }
}
