import '../firebase_module.dart';
import 'domain/analytics_service.dart';

/// Analytics has no startup configuration; this module exists so its lifecycle
/// stays explicit and can evolve independently.
class FirebaseAnalyticsModule implements FirebaseModule {
  const FirebaseAnalyticsModule(this.service);

  final AnalyticsService service;

  @override
  Future<void> initialize() async {}
}
