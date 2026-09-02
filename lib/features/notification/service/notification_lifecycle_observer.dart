import 'package:flutter/widgets.dart';
import 'package:data_portal_survey/features/notification/service/notification_badge_sync.dart';

class NotificationLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      NotificationBadgeSync.instance.syncFromServer();
    }
  }
}
