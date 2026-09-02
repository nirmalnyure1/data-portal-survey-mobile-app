import 'package:data_portal_survey/common/http/http.dart';
import 'package:data_portal_survey/common/logger/log.dart';
import 'package:data_portal_survey/features/engagement/resource/engagement_api_provider.dart';
import 'package:data_portal_survey/features/engagement/service/engagement_session_tracker.dart';

class EngagementRepository {
  final ApiProvider apiProvider;

  late EngagementApiProvider engagementApiProvider;

  EngagementRepository({required this.apiProvider}) {
    engagementApiProvider = EngagementApiProvider(apiProvider: apiProvider);
  }

  Future<void> trackActivity({
    required String activityCode,
    Map<String, dynamic>? metadata,
    String? sessionId,
    String? franchiseId,
    String? foodItemId,
    String? orderId,
  }) async {
    try {
      final body = <String, dynamic>{'activityCode': activityCode};
      if (metadata != null && metadata.isNotEmpty) body['metadata'] = metadata;
      if (sessionId != null && sessionId.isNotEmpty)
        body['sessionId'] = sessionId;
      if (franchiseId != null && franchiseId.isNotEmpty) {
        body['franchiseId'] = franchiseId;
      }
      if (foodItemId != null && foodItemId.isNotEmpty) {
        body['foodItemId'] = foodItemId;
      }
      if (orderId != null && orderId.isNotEmpty) body['orderId'] = orderId;
      await engagementApiProvider.trackActivity(body: body);
    } catch (e, stack) {
      Log.e('Failed to track $activityCode engagement\n$e\n$stack');
    }
  }

  Future<void> trackAppOpenIfNeeded({required String sessionKey}) async {
    if (!EngagementSessionTracker.instance.shouldTrackAppOpen(sessionKey)) {
      return;
    }
    await trackActivity(activityCode: 'app_open', sessionId: sessionKey);
  }

  Future<void> trackAddToCart({
    required String foodItemId,
    int quantity = 1,
    String? sessionId,
    String? franchiseId,
  }) async {
    await trackActivity(
      activityCode: 'add_to_cart',
      foodItemId: foodItemId,
      sessionId: sessionId,
      franchiseId: franchiseId,
      metadata: {'quantity': quantity},
    );
  }

  Future<void> trackRemoveFromCart({
    required String foodItemId,
    String? sessionId,
    String? franchiseId,
  }) async {
    await trackActivity(
      activityCode: 'remove_from_cart',
      foodItemId: foodItemId,
      sessionId: sessionId,
      franchiseId: franchiseId,
    );
  }

  void resetTrackedSession() {
    EngagementSessionTracker.instance.resetSession();
  }

  Future<void> trackNotificationOpen(String? notificationLogId) async {
    if (notificationLogId == null || notificationLogId.isEmpty) return;
    try {
      await engagementApiProvider.markNotificationOpen(id: notificationLogId);
    } catch (e, stack) {
      Log.e('Failed to track notification open\n$e\n$stack');
    }
  }

  Future<void> trackNotificationClick(String? notificationLogId) async {
    if (notificationLogId == null || notificationLogId.isEmpty) return;
    try {
      await engagementApiProvider.markNotificationClick(id: notificationLogId);
    } catch (e, stack) {
      Log.e('Failed to track notification click\n$e\n$stack');
    }
  }

  Future<void> trackNotificationDismiss(String? notificationLogId) async {
    if (notificationLogId == null || notificationLogId.isEmpty) return;
    try {
      await engagementApiProvider.markNotificationDismiss(
        id: notificationLogId,
      );
    } catch (e, stack) {
      Log.e('Failed to track notification dismiss\n$e\n$stack');
    }
  }

  Future<void> trackNotificationConvert(
    String? notificationLogId, {
    String? orderId,
  }) async {
    if (notificationLogId == null || notificationLogId.isEmpty) return;
    try {
      final body = <String, dynamic>{};
      if (orderId != null && orderId.isNotEmpty) body['orderId'] = orderId;
      await engagementApiProvider.markNotificationConvert(
        id: notificationLogId,
        body: body,
      );
    } catch (e, stack) {
      Log.e('Failed to track notification conversion\n$e\n$stack');
    }
  }
}
