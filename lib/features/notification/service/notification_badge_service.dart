import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:data_portal_survey/features/notification/service/notification_payload.dart';

class NotificationBadgeService {
  NotificationBadgeService._();

  static final NotificationBadgeService instance = NotificationBadgeService._();

  static const String _badgeCountKey = 'notification_badge_count';

  final ValueNotifier<int> badgeCountNotifier = ValueNotifier(0);

  Future<int> getBadgeCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_badgeCountKey) ?? 0;
  }

  Future<void> loadInitialCount() async {
    final count = await getBadgeCount();
    badgeCountNotifier.value = count;
  }

  Future<void> setBadgeCount(int count) async {
    final safeCount = count < 0 ? 0 : count;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_badgeCountKey, safeCount);
    badgeCountNotifier.value = safeCount;
    await _updateAppIconBadge(safeCount);
  }

  Future<int> incrementBadgeCount() async {
    final current = await getBadgeCount();
    final next = current + 1;
    await setBadgeCount(next);
    return next;
  }

  Future<void> resetBadgeCount() async {
    await setBadgeCount(0);
  }

  Future<void> applyFromPayload(NotificationPayload payload) async {
    if (payload.badge != null) {
      await setBadgeCount(payload.badge!);
    } else {
      await incrementBadgeCount();
    }
  }

  Future<void> _updateAppIconBadge(int count) async {
    final isSupported = await AppBadgePlus.isSupported();
    if (!isSupported) return;

    if (count <= 0) {
      await AppBadgePlus.updateBadge(0);
      return;
    }

    await AppBadgePlus.updateBadge(count);
  }
}
