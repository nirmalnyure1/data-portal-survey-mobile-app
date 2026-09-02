import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:data_portal_survey/common/logger/log.dart';
import 'package:data_portal_survey/common/utils/permission_handler.dart';
import 'package:data_portal_survey/features/engagement/resource/engagement_repository.dart';
import 'package:data_portal_survey/features/notification/resource/notification_repository.dart';
import 'package:data_portal_survey/features/notification/service/local_notification_service.dart';
import 'package:data_portal_survey/features/notification/service/notification_badge_service.dart';
import 'package:data_portal_survey/features/notification/service/notification_badge_sync.dart';
import 'package:data_portal_survey/features/notification/service/notification_dedup_store.dart';
import 'package:data_portal_survey/features/notification/service/notification_navigation_handler.dart';
import 'package:data_portal_survey/features/notification/service/notification_payload.dart';
import 'package:data_portal_survey/features/notification/service/notification_session_sync.dart';
import 'package:data_portal_survey/features/notification/service/push_token_repository.dart';
import 'package:data_portal_survey/firebase_options.dart';

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  PushTokenRepository? _tokenRepository;
  bool _initialized = false;

  void configure({
    PushTokenRepository? tokenRepository,
    NotificationRepository? notificationRepository,
    EngagementRepository? engagementRepository,
  }) {
    _tokenRepository = tokenRepository;
    NotificationNavigationHandler.instance.configure(
      notificationRepository: notificationRepository,
      engagementRepository: engagementRepository,
    );
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await LocalNotificationService.instance.initialize(
      onNotificationTap: _onLocalNotificationTap,
    );

    await _requestPermissions();

    if (Platform.isIOS) {
      await _ensureIosLocalNotificationPermissions();
      await _waitForApnsToken();
    }
    await _logPushTokens();

    if (Platform.isIOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: false,
            badge: false,
            sound: false,
          );
    }

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      final payload = NotificationPayload.fromRemoteMessage(initialMessage);
      await NotificationBadgeService.instance.applyFromPayload(payload);
      NotificationNavigationHandler.instance.setPendingPayload(payload);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      Log.d('FCM token refreshed: $token');
      debugPrint('[PushNotification] FCM token refreshed: $token');
      if (!NotificationSessionSync.isAuthenticated) return;
      _tokenRepository?.refreshToken();
    });
  }

  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    WidgetsFlutterBinding.ensureInitialized();
    await DefaultFirebaseOptions.loadEnv();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint(
      '[PushNotification] background message: '
      'id=${message.messageId} title=${message.notification?.title}',
    );

    final payload = NotificationPayload.fromRemoteMessage(message);
    if (await NotificationDedupStore.isDuplicate(payload.deduplicationKey)) {
      debugPrint('[PushNotification] background message skipped (duplicate)');
      return;
    }

    await NotificationBadgeService.instance.applyFromPayload(payload);

    if (Platform.isAndroid && message.notification != null) {
      return;
    }

    await LocalNotificationService.instance.initialize(
      onNotificationTap: (_) {},
    );
    await LocalNotificationService.instance.showFromPayload(payload);
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    debugPrint(
      '[PushNotification] foreground message: '
      'id=${message.messageId} title=${message.notification?.title} '
      'body=${message.notification?.body}',
    );

    final payload = NotificationPayload.fromRemoteMessage(message);
    if (await NotificationDedupStore.isDuplicate(payload.deduplicationKey)) {
      debugPrint('[PushNotification] foreground message skipped (duplicate)');
      return;
    }

    await NotificationBadgeService.instance.applyFromPayload(payload);
    if (NotificationSessionSync.isAuthenticated) {
      await NotificationBadgeSync.instance.syncFromServer();
    }

    // iOS shows notification payloads natively when the app is in foreground.
    if (Platform.isIOS && message.notification != null) {
      return;
    }

    await LocalNotificationService.instance.showFromPayload(payload);
  }

  Future<void> _onMessageOpenedApp(RemoteMessage message) async {
    debugPrint(
      '[PushNotification] opened from notification: '
      'id=${message.messageId} title=${message.notification?.title}',
    );

    final payload = NotificationPayload.fromRemoteMessage(message);
    await NotificationBadgeService.instance.applyFromPayload(payload);
    if (NotificationSessionSync.isAuthenticated) {
      await NotificationBadgeSync.instance.syncFromServer();
    }
    await NotificationNavigationHandler.instance.handlePayload(payload);
  }

  void _onLocalNotificationTap(NotificationPayload payload) {
    NotificationNavigationHandler.instance.handlePayload(payload);
  }

  Future<void> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        criticalAlert: false,
        announcement: false,
        carPlay: false,
      );
      Log.d('Push authorization status: ${settings.authorizationStatus}');
      debugPrint(
        '[PushNotification] authorization: ${settings.authorizationStatus}',
      );
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        Log.w(
          'Push notifications denied. Enable in Settings → Syanko → Notifications.',
        );
      }
    } else {
      await PermissionHandler.requestNotificationPermission();
    }
  }

  Future<void> _ensureIosLocalNotificationPermissions() async {
    if (!Platform.isIOS) return;

    final iosPlugin = FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// iOS FCM tokens are unavailable until APNs registration completes.
  Future<void> _waitForApnsToken({
    Duration timeout = const Duration(seconds: 30),
    Duration pollInterval = const Duration(milliseconds: 500),
  }) async {
    if (!Platform.isIOS) return;

    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken != null && apnsToken.isNotEmpty) {
        return;
      }
      await Future<void>.delayed(pollInterval);
    }

    Log.w(
      'APNs token not available after ${timeout.inSeconds}s. '
      'FCM token may be null on iOS until APNs registration succeeds.',
    );
  }

  Future<void> _logPushTokens() async {
    final apnsToken = Platform.isIOS
        ? await FirebaseMessaging.instance.getAPNSToken()
        : null;
    final fcmToken = await FirebaseMessaging.instance.getToken();

    Log.d('Push tokens — APNS: $apnsToken | FCM: $fcmToken');
    debugPrint(
      '[PushNotification] APNS: $apnsToken | FCM: $fcmToken '
      '(paste FCM into Firebase Console test message)',
    );

    if (Platform.isIOS && (apnsToken == null || apnsToken.isEmpty)) {
      Log.w(
        'APNS token is missing. Check Apple Push capability, provisioning profile, '
        'and Firebase APNs p8 key (Team ID K473L5F2HG, bundle com.syankorolls.syankoapp).',
      );
    }
    if (fcmToken == null || fcmToken.isEmpty) {
      Log.w('FCM token is missing. Push delivery will not work until this is set.');
    }
  }

  Future<void> requestPermissionsAndSaveToken() async {
    await _requestPermissions();
    if (Platform.isIOS) {
      await _waitForApnsToken();
    }
    if (!NotificationSessionSync.isAuthenticated) return;
    await _tokenRepository?.saveTokenToServer();
  }

  Future<String?> getToken() async {
    if (Platform.isIOS) {
      await _waitForApnsToken();
    }
    return FirebaseMessaging.instance.getToken();
  }

  Future<void> saveTokenToServer() =>
      _tokenRepository?.saveTokenToServer() ?? Future.value();

  Future<void> deleteToken() =>
      _tokenRepository?.deleteToken() ?? Future.value();

  Future<void> unregisterDevice() =>
      _tokenRepository?.unregisterDevice() ?? Future.value();

  Future<void> refreshToken() =>
      _tokenRepository?.refreshToken() ?? Future.value();
}
