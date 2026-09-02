import 'package:data_portal_survey/features/notification/resource/notification_repository.dart';
import 'package:data_portal_survey/features/notification/service/notification_badge_service.dart';
import 'package:data_portal_survey/features/notification/service/notification_session_sync.dart';

class NotificationBadgeSync {
  NotificationBadgeSync._();

  static final NotificationBadgeSync instance = NotificationBadgeSync._();

  NotificationRepository? _repository;

  void configure({required NotificationRepository repository}) {
    _repository = repository;
  }

  Future<void> syncFromServer() async {
    final repository = _repository;
    if (repository == null || !NotificationSessionSync.isAuthenticated) return;

    final response = await repository.getUnreadCount();
    if (response.data != null) {
      await NotificationBadgeService.instance.setBadgeCount(response.data!);
    }
  }
}
