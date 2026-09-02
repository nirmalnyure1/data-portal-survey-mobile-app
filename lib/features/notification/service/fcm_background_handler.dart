import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:data_portal_survey/features/notification/service/push_notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await PushNotificationService.handleBackgroundMessage(message);
}
