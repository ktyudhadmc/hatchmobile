import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';

/// GitHub is a separate host from the app backend, so it gets its own [Dio]
/// instance instead of reusing [dioProvider]. Used by the in-app update
/// feature to read/download from GitHub Releases.
///
/// No auth header: the project is a public repository, so the Releases API
/// and its APK assets are readable anonymously. If that ever changes (e.g.
/// rate limiting), this is where a token would go.
final githubDioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: AppConstants.githubApiBaseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
    ),
  );
});
