import 'package:data_portal_survey/features/notification/service/notification_badge_service.dart';

class BadgeUtils {
  static Future<void> clearBadge() =>
      NotificationBadgeService.instance.resetBadgeCount();
}
