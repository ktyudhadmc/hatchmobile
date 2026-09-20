import '../../utils/device_info_helper.dart';
import '../firebase_module.dart';
import 'domain/analytics_service.dart';

/// Tags every event/session with which release channel produced it, via
/// the `build_channel` user property (`stable`/`alpha`/`beta`/`rc`/
/// `snapshot` — see [DeviceInfoHelper.buildChannel]), so canary traffic can
/// be filtered out of (or in for) production dashboards.
class FirebaseAnalyticsModule implements FirebaseModule {
  const FirebaseAnalyticsModule(this.service);

  final AnalyticsService service;

  @override
  Future<void> initialize() => service.setUserProperty(
    name: 'build_channel',
    value: DeviceInfoHelper.instance.buildChannel,
  );
}
