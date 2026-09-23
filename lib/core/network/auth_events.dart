import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Broadcasts a signal whenever the backend responds 401 to an
/// already-authenticated request, so the auth feature can react (clear the
/// session, bounce the router to /login) without this core layer importing
/// anything from features/auth.
final unauthorizedEventProvider = Provider<StreamController<void>>((ref) {
  final controller = StreamController<void>.broadcast();
  ref.onDispose(controller.close);
  return controller;
});
