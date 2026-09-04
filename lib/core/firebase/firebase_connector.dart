import 'package:firebase_core/firebase_core.dart';

/// Owns the default Firebase app connection only. Product-specific setup
/// belongs to a [FirebaseModule], keeping services independent of each other.
class FirebaseConnector {
  const FirebaseConnector();

  Future<void> connect() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  }
}
