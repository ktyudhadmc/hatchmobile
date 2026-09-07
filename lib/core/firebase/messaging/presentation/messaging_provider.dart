import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/firebase_messaging_service.dart';
import '../domain/push_messaging_service.dart';

final pushMessagingServiceProvider = Provider<PushMessagingService>(
  (_) => FirebaseMessagingService(),
);
