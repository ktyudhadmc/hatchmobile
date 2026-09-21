import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';

/// GitLab is a separate host from the app backend, so it gets its own [Dio]
/// instance instead of reusing [dioProvider]. Used by the in-app update
/// feature to read/download from GitLab Releases when the
/// `app_update_source` Remote Config value (see
/// RemoteConfigKeys.appUpdateSource) resolves to [UpdateSource.gitlab].
///
/// No auth header: the project is public with Releases set to "Everyone
/// With Access", so the Releases API and its APK assets are readable
/// anonymously. If that ever changes, this is where a token would go back.
final gitlabDioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: AppConstants.gitlabApiBaseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
    ),
  );
});
