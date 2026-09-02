import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:data_portal_survey/features/engagement/resource/engagement_repository.dart';
import 'package:data_portal_survey/features/engagement/service/engagement_session_tracker.dart';
import 'package:data_portal_survey/features/notification/model/inbox_notification_model.dart';
import 'package:data_portal_survey/features/notification/resource/notification_repository.dart';
import 'package:data_portal_survey/features/notification/service/notification_badge_sync.dart';
import 'package:data_portal_survey/features/notification/service/notification_payload.dart';
import 'package:data_portal_survey/navigation/app_navigator.dart';
import 'package:data_portal_survey/navigation/app_router.dart';

class NotificationNavigationHandler {
  NotificationNavigationHandler._();

  static final NotificationNavigationHandler instance =
      NotificationNavigationHandler._();

  NotificationRepository? _notificationRepository;
  EngagementRepository? _engagementRepository;
  NotificationPayload? _pendingPayload;
  bool _isNavigating = false;
  static const Duration _navigationCooldown = Duration(milliseconds: 600);

  void configure({
    NotificationRepository? notificationRepository,
    EngagementRepository? engagementRepository,
  }) {
    _notificationRepository = notificationRepository;
    _engagementRepository = engagementRepository;
    if (_pendingPayload != null) {
      _scheduleRetry();
    }
  }

  void setPendingPayload(NotificationPayload payload) {
    _pendingPayload = payload;
  }

  Future<void> handlePayload(
    NotificationPayload payload, {
    bool openInboxOnDefault = true,
  }) async {
    if (_isNavigating) return;

    if (!_isNavigatorReady()) {
      _pendingPayload = payload;
      _scheduleRetry();
      return;
    }

    _isNavigating = true;
    try {
      await _navigateFromPayload(
        payload,
        openInboxOnDefault: openInboxOnDefault,
      );
    } finally {
      Future<void>.delayed(_navigationCooldown, () {
        _isNavigating = false;
      });
    }

    unawaited(_trackOpenAndClick(payload));
    unawaited(_markReadIfNeeded(payload.inboxNotificationId));
  }

  Future<void> handleInboxNotification(
    InboxNotificationModel notification,
  ) async {
    final payload = NotificationPayload.fromDataMap(
      notification.data,
      title: notification.title,
      body: notification.body,
      inboxNotificationId: notification.id,
    ).copyWithType(notification.type);

    await handlePayload(payload, openInboxOnDefault: false);
  }

  Future<bool> _navigateFromPayload(
    NotificationPayload payload, {
    required bool openInboxOnDefault,
  }) async {
    if (openInboxOnDefault) {
      await AppNavigator.push(const NotificationInboxRoute());
      return true;
    }

    return false;
  }

  Future<void> _markReadIfNeeded(String? inboxId) async {
    if (inboxId == null || inboxId.isEmpty) return;
    final repository = _notificationRepository;
    if (repository == null) return;

    await repository.markNotificationRead(id: inboxId);
    await NotificationBadgeSync.instance.syncFromServer();
  }

  Future<void> _trackOpenAndClick(NotificationPayload payload) async {
    final logId = payload.notificationLogId;
    if (logId == null || logId.isEmpty) return;

    EngagementSessionTracker.instance.setActiveNotificationLogId(logId);
    final repository = _engagementRepository;
    if (repository == null) return;
    await repository.trackNotificationOpen(logId);
    await repository.trackNotificationClick(logId);
  }

  bool _isNavigatorReady() {
    return AppNavigator.navigationKey.currentState?.overlay?.context != null;
  }

  Future<void> flushPending() async {
    if (_pendingPayload == null) return;
    if (!_isNavigatorReady()) return;

    final payload = _pendingPayload!;
    _pendingPayload = null;
    await handlePayload(payload);
  }

  void _scheduleRetry() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await flushPending();
      if (_pendingPayload != null) {
        _scheduleRetry();
      }
    });
  }
}

extension _NotificationPayloadCopy on NotificationPayload {
  NotificationPayload copyWithType(String type) {
    return NotificationPayload(
      messageId: messageId,
      title: title,
      body: body,
      type: type,
      campaignId: campaignId,
      notificationLogId: notificationLogId,
      orderId: orderId,
      imageUrl: imageUrl,
      androidChannelId: androidChannelId,
      badge: badge,
      inboxNotificationId: inboxNotificationId,
      offerId: offerId,
      bookingId: bookingId,
      refundId: refundId,
      disputeId: disputeId,
      data: data,
    );
  }
}
