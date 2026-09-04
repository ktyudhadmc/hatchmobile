import 'package:firebase_messaging/firebase_messaging.dart';

import '../firebase_module.dart';
import 'data/firebase_messaging_service.dart';
import 'firebase_messaging_background_handler.dart';

class FirebaseMessagingModule implements FirebaseModule {
  const FirebaseMessagingModule(this._service);

  final FirebaseMessagingService _service;

  @override
  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await _service.initialize();
  }
}
