import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:data_portal_survey/common/http/api_provider.dart';
import 'package:data_portal_survey/common/logger/log.dart';
import 'package:data_portal_survey/common/utils/device_info_utils.dart';
import 'package:data_portal_survey/features/notification/resource/notification_api_provider.dart';
import 'package:data_portal_survey/features/notification/service/notification_session_sync.dart';

class PushTokenRepository {
  static const String _lastSyncedTokenKey = 'last_synced_fcm_token';
  static const String _deviceRegisteredKey = 'device_registered_on_server';

  final NotificationApiProvider _apiProvider;
  final DeviceInfoUtils _deviceInfoUtils = DeviceInfoUtils();

  PushTokenRepository({required ApiProvider apiProvider})
    : _apiProvider = NotificationApiProvider(apiProvider: apiProvider);

  Future<String?> getToken() async {
    if (Platform.isIOS) {
      await _waitForApnsToken();
    }
    return FirebaseMessaging.instance.getToken();
  }

  Future<void> _waitForApnsToken({
    Duration timeout = const Duration(seconds: 15),
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
      'APNs token not available after ${timeout.inSeconds}s when saving FCM token.',
    );
  }

  Future<void> saveTokenToServer() async {
    try {
      if (!NotificationSessionSync.isAuthenticated) return;

      final token = await getToken();
      Log.d('FCM Token: $token');
      if (token == null || token.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final lastSynced = prefs.getString(_lastSyncedTokenKey);
      final isRegistered = prefs.getBool(_deviceRegisteredKey) ?? false;

      if (isRegistered && lastSynced == token) return;

      await _apiProvider.registerDevice(await _buildDevicePayload(token));
      await prefs.setString(_lastSyncedTokenKey, token);
      await prefs.setBool(_deviceRegisteredKey, true);
    } catch (e, stack) {
      Log.e('Failed to save FCM token\n$e\n$stack');
    }
  }

  Future<void> deleteToken() async {
    try {
      await FirebaseMessaging.instance.deleteToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastSyncedTokenKey);
      await prefs.setBool(_deviceRegisteredKey, false);
    } catch (e, stack) {
      Log.e('Failed to delete local FCM token\n$e\n$stack');
    }
  }

  Future<void> refreshToken() async {
    try {
      if (!NotificationSessionSync.isAuthenticated) return;

      final token = await getToken();
      if (token == null || token.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final isRegistered = prefs.getBool(_deviceRegisteredKey) ?? false;
      final deviceId = await _deviceInfoUtils.getStableDeviceId();

      if (isRegistered) {
        await _apiProvider.patchDevice({
          'deviceId': deviceId,
          'fcmToken': token,
        });
      } else {
        await _apiProvider.registerDevice(await _buildDevicePayload(token));
        await prefs.setBool(_deviceRegisteredKey, true);
      }

      await prefs.setString(_lastSyncedTokenKey, token);
    } catch (e, stack) {
      Log.e('Failed to refresh FCM token\n$e\n$stack');
    }
  }

  Future<void> unregisterDevice() async {
    try {
      final deviceId = await _deviceInfoUtils.getStableDeviceId();
      if (deviceId.isEmpty) return;

      await _apiProvider.deleteDevice(deviceId: deviceId);

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastSyncedTokenKey);
      await prefs.setBool(_deviceRegisteredKey, false);
    } catch (e, stack) {
      Log.e('Failed to unregister device\n$e\n$stack');
    }
  }

  Future<Map<String, dynamic>> _buildDevicePayload(String token) async {
    final deviceId = await _deviceInfoUtils.getStableDeviceId();
    final appVersion = await _deviceInfoUtils.getAppVersion();

    return {
      'deviceId': deviceId,
      'fcmToken': token,
      'platform': Platform.isIOS ? 'ios' : 'android',
      'appVersion': appVersion,
    };
  }
}
