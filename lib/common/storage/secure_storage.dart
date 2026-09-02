import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:data_portal_survey/features/auth/model/user_model.dart';

class SecureStorage {
  // Singleton
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;
  SecureStorage._internal();

  static final FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: Platform.isAndroid
        ? const AndroidOptions()
        : AndroidOptions.defaultOptions,
  );

  static const String _keyAccessToken = 'access_token';
  // ignore: unused_field
  static const String _keyRefreshToken = 'refresh_token';
  // ignore: unused_field
  static const String _keyUserId = 'user_id';
  static const String userData = "userData";
  static const String _keyLocationPermissionGranted =
      'location_permission_granted';
  static const String _keyNotificationPermissionGranted =
      'notification_permission_granted';
  static const String _keyLocationPermissionSkipped =
      'location_permission_skipped';
  static const String _keyNotificationPermissionSkipped =
      'notification_permission_skipped';
  static const String _keyLocationPermissionPrompted =
      'location_permission_prompted';
  static const String _keyNotificationPermissionPrompted =
      'notification_permission_prompted';

  static const String _keyDeviceLatitude = 'device_latitude';
  static const String _keyDeviceLongitude = 'device_longitude';
  static const String _keyDeviceCountryCode = 'device_country_code';
  static const String _keyDeviceCountryId = 'device_country_id';
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyStableDeviceId = 'stable_device_id';
  static const String _keyRememberedPhone = 'remembered_phone';
  static const String _keyRememberedDialCode = 'remembered_dial_code';

  // Access Token
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: _keyAccessToken);
  }

  // Refresh Token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _keyRefreshToken);
  }

  // Clear all
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Clears only auth-related keys; preserves country, location, permissions, onboarding.
  Future<void> clearAuthSession() async {
    await deleteAccessToken();
    await deleteRefreshToken();
    await removeUser();
  }

  Future<void> setUser({required UserModel user}) async {
    await _storage.write(key: userData, value: jsonEncode(user.toMap()));
  }

  Future<UserModel?> getUser() async {
    try {
      final data = await _storage.read(key: userData);
      //await box.close();
      if (data == null || data.isEmpty) {
        return null;
      }
      UserModel user = UserModel.fromMap(jsonDecode(data));
      return user;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<void> removeUser() async {
    await _storage.delete(key: userData);
  }

  Future<void> saveLocationPermissionGranted(bool granted) async {
    await _storage.write(
      key: _keyLocationPermissionGranted,
      value: granted.toString(),
    );
  }

  Future<bool> getLocationPermissionGranted() async {
    final value = await _storage.read(key: _keyLocationPermissionGranted);
    return value == 'true';
  }

  Future<void> saveLocationPermissionSkipped(bool skipped) async {
    await _storage.write(
      key: _keyLocationPermissionSkipped,
      value: skipped.toString(),
    );
  }

  Future<bool> getLocationPermissionSkipped() async {
    final value = await _storage.read(key: _keyLocationPermissionSkipped);
    return value == 'true';
  }

  Future<void> saveNotificationPermissionGranted(bool granted) async {
    await _storage.write(
      key: _keyNotificationPermissionGranted,
      value: granted.toString(),
    );
  }

  Future<bool> getNotificationPermissionGranted() async {
    final value = await _storage.read(key: _keyNotificationPermissionGranted);
    return value == 'true';
  }

  Future<void> saveNotificationPermissionSkipped(bool skipped) async {
    await _storage.write(
      key: _keyNotificationPermissionSkipped,
      value: skipped.toString(),
    );
  }

  Future<bool> getNotificationPermissionSkipped() async {
    final value = await _storage.read(key: _keyNotificationPermissionSkipped);
    return value == 'true';
  }

  Future<void> saveLocationPermissionPrompted(bool prompted) async {
    await _storage.write(
      key: _keyLocationPermissionPrompted,
      value: prompted.toString(),
    );
  }

  Future<bool> getLocationPermissionPrompted() async {
    final value = await _storage.read(key: _keyLocationPermissionPrompted);
    return value == 'true';
  }

  Future<void> saveNotificationPermissionPrompted(bool prompted) async {
    await _storage.write(
      key: _keyNotificationPermissionPrompted,
      value: prompted.toString(),
    );
  }

  Future<bool> getNotificationPermissionPrompted() async {
    final value = await _storage.read(key: _keyNotificationPermissionPrompted);
    return value == 'true';
  }

  /// Whether the one-time in-app location permission screen may still be shown.
  /// Callers should also check the live OS permission status.
  Future<bool> shouldShowLocationPermissionPrompt() async {
    if (await getLocationPermissionSkipped()) return false;
    if (await getLocationPermissionPrompted()) return false;
    return true;
  }

  /// Whether the one-time in-app notification permission screen may still be shown.
  /// Callers should also check the live OS permission status.
  Future<bool> shouldShowNotificationPermissionPrompt() async {
    if (await getNotificationPermissionSkipped()) return false;
    if (await getNotificationPermissionPrompted()) return false;
    return true;
  }

  Future<void> saveDeviceLocation({
    required double latitude,
    required double longitude,
  }) async {
    await _storage.write(key: _keyDeviceLatitude, value: latitude.toString());
    await _storage.write(key: _keyDeviceLongitude, value: longitude.toString());
  }

  Future<double?> getDeviceLatitude() async {
    final value = await _storage.read(key: _keyDeviceLatitude);
    if (value == null || value.isEmpty) return null;
    return double.tryParse(value);
  }

  Future<double?> getDeviceLongitude() async {
    final value = await _storage.read(key: _keyDeviceLongitude);
    if (value == null || value.isEmpty) return null;
    return double.tryParse(value);
  }

  Future<void> saveDeviceCountryCode(String code) async {
    await _storage.write(key: _keyDeviceCountryCode, value: code);
  }

  Future<String?> getDeviceCountryCode() async {
    final value = await _storage.read(key: _keyDeviceCountryCode);
    if (value == null || value.isEmpty) return null;
    return value;
  }

  Future<void> saveDeviceCountryId(String countryId) async {
    await _storage.write(key: _keyDeviceCountryId, value: countryId);
  }

  Future<String?> getDeviceCountryId() async {
    final value = await _storage.read(key: _keyDeviceCountryId);
    if (value == null || value.isEmpty) return null;
    return value;
  }

  Future<void> saveOnboardingCompleted(bool completed) async {
    await _storage.write(
      key: _keyOnboardingCompleted,
      value: completed.toString(),
    );
  }

  Future<bool> getOnboardingCompleted() async {
    final value = await _storage.read(key: _keyOnboardingCompleted);
    return value == 'true';
  }

  Future<String?> getStableDeviceId() async {
    final value = await _storage.read(key: _keyStableDeviceId);
    if (value == null || value.isEmpty) return null;
    return value;
  }

  Future<void> saveStableDeviceId(String deviceId) async {
    await _storage.write(key: _keyStableDeviceId, value: deviceId);
  }

  Future<void> saveRememberedPhone({
    required String phone,
    required String dialCode,
  }) async {
    await _storage.write(key: _keyRememberedPhone, value: phone);
    await _storage.write(key: _keyRememberedDialCode, value: dialCode);
  }

  Future<String?> getRememberedPhone() async {
    final value = await _storage.read(key: _keyRememberedPhone);
    if (value == null || value.isEmpty) return null;
    return value;
  }

  Future<String?> getRememberedDialCode() async {
    final value = await _storage.read(key: _keyRememberedDialCode);
    if (value == null || value.isEmpty) return null;
    return value;
  }

  Future<void> clearRememberedPhone() async {
    await _storage.delete(key: _keyRememberedPhone);
    await _storage.delete(key: _keyRememberedDialCode);
  }
}
