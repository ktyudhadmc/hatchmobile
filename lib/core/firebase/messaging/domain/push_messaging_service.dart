import 'notification_permission_status.dart';
import 'push_message.dart';

abstract interface class PushMessagingService {
  Future<NotificationPermissionStatus> requestPermission();
  Future<String?> getToken();
  Stream<String> get onTokenRefresh;
  Stream<PushMessage> get onForegroundMessage;
  Stream<PushMessage> get onMessageOpenedApp;
  Future<PushMessage?> getInitialMessage();
}
