import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:data_portal_survey/features/notification/service/notification_badge_service.dart';
import 'package:data_portal_survey/features/notification/service/notification_payload.dart';

typedef NotificationTapCallback = void Function(NotificationPayload payload);

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  static const String highPriorityChannelId = 'dataportalsurvey_high_priority';
  static const String defaultChannelId = 'dataportalsurvey_default';
  static const String promotionsChannelId = 'dataportalsurvey_alerts';
  static const String backendDefaultChannelId = 'default';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  NotificationTapCallback? _onNotificationTap;
  int _notificationId = 0;

  Future<void> initialize({
    required NotificationTapCallback onNotificationTap,
  }) async {
    _onNotificationTap = onNotificationTap;

    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
        macOS: darwinInit,
      ),
      onDidReceiveNotificationResponse: _handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          notificationTapBackgroundHandler,
    );

    await _createAndroidChannels();
  }

  Future<void> _createAndroidChannels() async {
    if (!Platform.isAndroid) return;

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin == null) return;

    const backendDefault = AndroidNotificationChannel(
      backendDefaultChannelId,
      'Default',
      description: 'Default notification channel',
      importance: Importance.defaultImportance,
    );

    const highPriority = AndroidNotificationChannel(
      highPriorityChannelId,
      'High Priority',
      description: 'Important order and account alerts',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    const defaultChannel = AndroidNotificationChannel(
      defaultChannelId,
      'General',
      description: 'General app notifications',
      importance: Importance.defaultImportance,
    );

    const promotionsChannel = AndroidNotificationChannel(
      promotionsChannelId,
      'Promotions',
      description: 'Offers and promotional updates',
      importance: Importance.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    await androidPlugin.createNotificationChannel(backendDefault);
    await androidPlugin.createNotificationChannel(highPriority);
    await androidPlugin.createNotificationChannel(defaultChannel);
    await androidPlugin.createNotificationChannel(promotionsChannel);
  }

  Future<void> showFromPayload(NotificationPayload payload) async {
    final title = payload.title.trim();
    final body = payload.body.trim();
    if (title.isEmpty && body.isEmpty) return;

    final badgeCount = await NotificationBadgeService.instance.getBadgeCount();
    final channelId = _resolveChannelId(
      payload.type,
      androidChannelId: payload.androidChannelId,
    );
    final imagePath = await _downloadImage(payload.imageUrl);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _channelName(channelId),
      channelDescription: _channelDescription(channelId),
      importance: channelId == highPriorityChannelId
          ? Importance.max
          : Importance.high,
      priority: Priority.high,
      visibility: NotificationVisibility.public,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification_sound'),
      styleInformation: imagePath != null
          ? BigPictureStyleInformation(
              FilePathAndroidBitmap(imagePath),
              contentTitle: title,
              summaryText: body,
            )
          : null,
    );

    final darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: badgeCount,
      attachments: imagePath != null
          ? [DarwinNotificationAttachment(imagePath)]
          : null,
    );

    _notificationId = (_notificationId + 1) % 100000;
    await _plugin.show(
      id: _notificationId,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      ),
      payload: payload.encode(),
    );
  }

  String _resolveChannelId(
    String? type, {
    String? androidChannelId,
  }) {
    if (androidChannelId != null &&
        androidChannelId.isNotEmpty &&
        androidChannelId != 'default') {
      return androidChannelId;
    }

    switch (type) {
      case 'order':
      case 'order_ready':
      case 'order_created':
      case 'order_status_changed':
        return highPriorityChannelId;
      case 'offer':
      case 'promotion':
      case 'offers':
      case 'marketing':
      case 'loyalty_offer_active':
        return promotionsChannelId;
      default:
        return backendDefaultChannelId;
    }
  }

  String _channelName(String channelId) {
    switch (channelId) {
      case highPriorityChannelId:
        return 'High Priority';
      case promotionsChannelId:
        return 'Promotions';
      case backendDefaultChannelId:
        return 'Default';
      case defaultChannelId:
        return 'General';
      default:
        return 'Notifications';
    }
  }

  String _channelDescription(String channelId) {
    switch (channelId) {
      case highPriorityChannelId:
        return 'Important order and account alerts';
      case promotionsChannelId:
        return 'Offers and promotional updates';
      case backendDefaultChannelId:
        return 'Default notification channel';
      case defaultChannelId:
        return 'General app notifications';
      default:
        return 'App notifications';
    }
  }

  Future<String?> _downloadImage(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) return null;

    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) return null;

      final directory = await getTemporaryDirectory();
      final extension = imageUrl.contains('.png') ? 'png' : 'jpg';
      final file = File(
        '${directory.path}/notification_image_${DateTime.now().millisecondsSinceEpoch}.$extension',
      );
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  void _handleNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    _onNotificationTap?.call(NotificationPayload.fromEncoded(payload));
  }
}

@pragma('vm:entry-point')
void notificationTapBackgroundHandler(NotificationResponse response) {
  if (kDebugMode) {
    debugPrint('Background notification tap: ${response.payload}');
  }
}
