import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/firebase_analytics_service.dart';
import '../domain/analytics_service.dart';

final analyticsServiceProvider = Provider<AnalyticsService>(
  (_) => FirebaseAnalyticsService(),
);
