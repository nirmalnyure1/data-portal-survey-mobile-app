import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:data_portal_survey/common/http/http.dart';
import 'package:data_portal_survey/common/logger/logger.dart';
import 'package:data_portal_survey/common/storage/secure_storage.dart';
import 'package:data_portal_survey/common/utils/utils.dart';
import 'package:data_portal_survey/features/auth/model/user_model.dart';
import 'package:data_portal_survey/features/auth/resource/auth_api_provider.dart';
import 'package:data_portal_survey/features/engagement/service/engagement_session_tracker.dart';
import 'package:data_portal_survey/features/notification/service/notification_badge_service.dart';
import 'package:data_portal_survey/features/notification/service/notification_badge_sync.dart';
import 'package:data_portal_survey/features/notification/service/push_notification_service.dart';

class AuthRepository {
  final ApiProvider apiProvider;
  late AuthApiProvider authApiProvider;

  late DeviceInfoUtils deviceInfoUtils;
  final SecureStorage secureStorage;

  AuthRepository({required this.apiProvider, required this.secureStorage}) {
    authApiProvider = AuthApiProvider(apiProvider: apiProvider);

    deviceInfoUtils = DeviceInfoUtils();
  }

  String _accessToken = '';

  String _refreshToken = "";

  String get accessToken => _accessToken;

  String get refreshToken => _refreshToken;

  bool get isAuthenticated => _accessToken.isNotEmpty && _user.value != null;

  final ValueNotifier<bool> _isLoggedIn = ValueNotifier(false);

  ValueNotifier<bool> get isLoggedIn => _isLoggedIn;

  final ValueNotifier<UserModel?> _user = ValueNotifier(null);

  ValueNotifier<UserModel?> get user => _user;

  final ValueNotifier<String?> _role = ValueNotifier(null);

  ValueNotifier<String?> get role => _role;

  final ValueNotifier<String?> _rememberUserId = ValueNotifier(null);

  ValueNotifier<String?> get rememberUserId => _rememberUserId;

  final ValueNotifier<String?> _loyaltyBalance = ValueNotifier(null);

  ValueNotifier<String?> get loyaltyBalance => _loyaltyBalance;

  /// Updates the globally-shared loyalty balance so any listening widgets
  /// (profile header, loyalty offers screen, etc.) refresh automatically.
  void updateLoyaltyBalance(String? value) {
    _loyaltyBalance.value = value;
  }

  // Future saveCity(String city)async{

  // await AuthHive().setUserAddress(value);
  //   _address = ValueNotifier(value);
  // }

  // }

  // for otp verification
  String _tempToken = "";

  String _tempPhoneNumber = "";

  String get tempToken => _tempToken;

  String get tempPhoneNumber => _tempPhoneNumber;

  String get userId => _user.value?.id ?? "";

  Future initial() async {
    await _loadSessionFromStorage();
  }

  Future<void> _loadSessionFromStorage() async {
    final token = await secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      _accessToken = token;
      _isLoggedIn.value = true;
    } else {
      _accessToken = '';
      _isLoggedIn.value = false;
    }

    final cachedUser = await secureStorage.getUser();
    _user.value = cachedUser;
    if (cachedUser?.loyalty?.balancePoints != null) {
      _loyaltyBalance.value = cachedUser!.loyalty!.balancePoints.toString();
    } else if (!isAuthenticated) {
      _loyaltyBalance.value = null;
    }
  }

  /// Clears in-memory auth state without touching secure storage.
  void clearInMemorySession() {
    _accessToken = '';
    _refreshToken = '';
    _isLoggedIn.value = false;
    _user.value = null;
    _loyaltyBalance.value = null;
    _role.value = null;
    EngagementSessionTracker.instance.resetSession();
  }

  /// Clears auth from storage and memory (guest mode safe — prefs preserved).
  Future<void> clearAuthSession() async {
    await secureStorage.clearAuthSession();
    clearInMemorySession();
  }

  Future setAccessToken(String token) async {
    try {
      final previous = _accessToken;
      await secureStorage.saveAccessToken(token);
      _accessToken = token;
      _isLoggedIn.value = true;

      if (token.isNotEmpty && token != previous) {
        // Session refreshed; push token sync happens via notification bootstrap.
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future setRefreshToken(String refreshToken) async {
    try {
      await secureStorage.saveRefreshToken(refreshToken);
      // _isLoggedIn.value = true;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<String?> tryLoadAccessToken() async {
    try {
      final token = await secureStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        _accessToken = token;
        _isLoggedIn.value = true;
        return token;
      }
      _accessToken = '';
      _isLoggedIn.value = false;
      return null;
    } catch (e) {
      debugPrint(e.toString());
      _accessToken = '';
      _isLoggedIn.value = false;
      return null;
    }
  }

  Future<String> fetchAccessToken() async {
    final token = await tryLoadAccessToken();
    if (token == null) {
      throw Exception('Access Token Not found');
    }
    return token;
  }

  Future<String> fetchRefreshToken() async {
    try {
      final refreshToken = await secureStorage.getRefreshToken();
      if (refreshToken != null && refreshToken != "") {
        _refreshToken = refreshToken;
      } else {
        throw Exception('Refresh Token Not found');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return refreshToken;
  }

  void setUser(UserModel user) {
    _user.value = user;
  }

  Future<DataResponse<UserModel>> getMe() async {
    if (!isAuthenticated) {
      return DataResponse.error('User not authenticated');
    }

    try {
      final res = await authApiProvider.getMe();

      final rawUser = res['data']?['data'] ?? res['data'];
      if (rawUser is! Map) {
        return DataResponse.error('Invalid user payload in /auth/me response');
      }

      final fetched = UserModel.fromMap(Map<String, dynamic>.from(rawUser));
      final current = _user.value;
      final merged = current == null
          ? fetched.copyWith(accessToken: _accessToken)
          : fetched.copyWith(
              accessToken: current.accessToken.isNotEmpty
                  ? current.accessToken
                  : _accessToken,
              gender: fetched.gender.isEmpty ? current.gender : fetched.gender,
            );

      _user.value = merged;
      await secureStorage.setUser(user: merged);
      updateLoyaltyBalance(merged.loyalty?.balancePoints.toString());

      return DataResponse.success(merged);
    } on CustomException catch (e) {
      Log.e(e);
      return DataResponse.error(
        e.message?.toString() ?? e.toString(),
        e.statusCode,
      );
    } catch (e) {
      Log.e(e);
      return DataResponse.error(e.toString());
    }
  }

  // Future fetchAddress() async {
  //   _address = ValueNotifier(await AuthHive().getUserAddress());
  // }

  // Future<DataResponse<bool>> login({
  //   required String phoneNumber,
  //   required String password,
  //   required bool isRememberMe,
  // }) async {
  //   try {
  //     // final fcm = await getFirebaseMessagingToken();

  //     final deviceId = await deviceInfoUtils.getDeviceId();
  //     Map<String, String> body = {
  //       "phoneNumber": phoneNumber,
  //       "password": password,
  //       // "fcm": fcm,
  //       "deviceId": deviceId,
  //       "platform": Platform.isAndroid ? "android" : "ios",
  //     };

  //     final res = await authApiProvider.login(body: body);

  //     if (!res['data']?['data']?['admin']?["isOtpVerified"]) {
  //       _tempToken = res['data']?['data']?['admin']?["token"] ?? "";
  //       _tempPhoneNumber = res['data']?['data']?['admin']?['phoneNumber'] ?? "";

  //       return DataResponse.success(false);
  //     }

  //     _role.value = res['data']?['data']?['admin']?['role'] ?? "";

  //     _user.value = UserModel.fromMap(res['data']?['data']?['admin'] ?? {});

  //     _accessToken = res['data']?['data']?["tokens"]?['accessToken'] ?? "";

  //     // if (_user.value?.isKYCVerified ?? false) {
  //     //   await _getMe();
  //     // }

  //     await SecureStorage().setUser(user: _user.value!);

  //     await setAccessToken(_accessToken);

  //     _isLoggedIn.value = true;

  //     return DataResponse.success(true);
  //   } catch (e) {
  //     _accessToken = '';
  //     _refreshToken = '';
  //     _isLoggedIn.value = false;
  //     debugPrint(e.toString());
  //     return DataResponse.error(e.toString());
  //   }
  // }

  // Future _getMe() async {
  //   try {
  //     final res = await authApiProvider.getMe(_accessToken);

  //     Log.d(res);

  //     final temp = UserModel.fromMap(res['data']?['data'] ?? {});

  //     _user.value = _user.value!.copyWith(
  //       id: temp.id,
  //       phoneNumber: temp.phoneNumber,
  //       email: temp.email,
  //       farmerDetails: temp.farmerDetails,
  //       isKYCVerified: temp.isKYCVerified,
  //       details: temp.details,
  //     );

  //     // Log.d(userModel.toMap());
  //   } catch (e) {
  //     Log.e(e);
  //     rethrow;
  //   }
  // }

  // Future<DataResponse<bool>> getMe() async {
  //   try {
  //     final res = await authApiProvider.getMe(_accessToken);

  //     Log.d(res);

  //     final temp = UserModel.fromMap(res['data']?['data'] ?? {});

  //     _user.value = _user.value!.copyWith(
  //       id: temp.id,
  //       phoneNumber: temp.phoneNumber,
  //       email: temp.email,
  //       farmerDetails: temp.farmerDetails,
  //       isKYCVerified: temp.isKYCVerified,
  //       details: temp.details,
  //     );
  //     // TODO: CHECK NOTIFIYLISTNERS
  //     _user.notifyListeners();
  //     await SecureStorage().setUser(user: _user.value!);

  //     return DataResponse.success(true);
  //   } catch (e) {
  //     Log.e(e);
  //     return DataResponse.error(e.toString());
  //   }
  // }

  // Future<DataResponse<bool>> updatePassword({
  //   required String oldPassword,
  //   required String newPassword,
  // }) async {
  //   try {
  //     Map<String, String> body = {
  //       "oldPassword": oldPassword,
  //       "newPassword": newPassword,
  //     };

  //     await authApiProvider.updatePassword(body: body, token: _accessToken);

  //     return DataResponse.success(true);
  //   } catch (e) {
  //     debugPrint(e.toString());
  //     return DataResponse.error(e.toString());
  //   }
  // }

  Future<DataResponse> logout() async {
    try {
      await PushNotificationService.instance.unregisterDevice();
      await PushNotificationService.instance.deleteToken();
      await NotificationBadgeService.instance.resetBadgeCount();
      // final deviceId = await DeviceInfoUtils.getDeviceId();

      // Map<String, String> body = {
      //   "deviceId": deviceId,
      //   "platform": Platform.isAndroid ? "android" : "ios",
      // };
      // await authApiProvider.logout(body: body, token: _accessToken);
      await secureStorage.removeUser();
      await secureStorage.deleteAccessToken();
      // isAuthenticated reads _accessToken and _user.value, so both must be
      // cleared before isLoggedIn flips — its listeners fire synchronously
      // and would otherwise observe a still-"authenticated" state mid-logout.
      _accessToken = "";
      _user.value = null;
      _loyaltyBalance.value = null;
      _isLoggedIn.value = false;
      EngagementSessionTracker.instance.resetSession();

      return DataResponse.success(true);
    } catch (e) {
      await NotificationBadgeService.instance.resetBadgeCount();
      _accessToken = "";
      _user.value = null;
      _role.value = null;
      _loyaltyBalance.value = null;
      _isLoggedIn.value = false;
      EngagementSessionTracker.instance.resetSession();

      return DataResponse.success(true);
    }
  }

  // Future localLogout() async {
  //   try {
  //     await secureStorage.removeAccessToken();
  //     await secureStorage.removeRefreshToken();
  //     await secureStorage.removeUser();
  //     await secureStorage.removeUserRole();
  //     await fetchRememberMe();

  //     _isLoggedIn.value = false;
  //     _user.value = null;

  //     _role.value = null;

  //     _accessToken = "";
  //   } catch (e) {
  //     Log.e(e);
  //     await secureStorage.removeAccessToken();
  //     await secureStorage.removeRefreshToken();
  //     await secureStorage.removeUser();
  //     // await SecureStorage().removeFarmer();
  //     await secureStorage.removeUserRole();
  //     await fetchRememberMe();

  //     _isLoggedIn.value = false;
  //     _user.value = null;
  //     _role.value = null;

  //     _accessToken = "";

  //     return DataResponse.success(true);
  //   }
  // }

  Future<DataResponse<bool>> userRegister({
    required String phone,
    required String fullName,
    String? email,
    String? password,
    String? address,
    String? referralCode,
  }) async {
    try {
      final nameParts = fullName
          .trim()
          .split(RegExp(r'\s+'))
          .where((p) => p.isNotEmpty)
          .toList();
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : firstName;

      final body = <String, dynamic>{
        "firstName": firstName,
        "lastName": lastName,
        "phone": phone,
        "device": await _buildDevicePayload(),
      };

      if (email != null && email.trim().isNotEmpty) {
        body["email"] = email.trim();
      }
      if (password != null && password.trim().isNotEmpty) {
        body["password"] = password;
      }
      if (address != null && address.trim().isNotEmpty) {
        body["address"] = address.trim();
      }
      if (referralCode != null && referralCode.trim().isNotEmpty) {
        body["referralCode"] = referralCode.trim();
      }

      final res = await authApiProvider.userRegister(body);

      // _tempPhoneNumber = phoneNumber;

      _tempToken = res['data']?['data']['token'] ?? "";

      return DataResponse.success(true);
    } catch (e) {
      Log.e(e);

      return DataResponse.error(e.toString());
    }
  }

  Future<DataResponse<bool>> verifyLogin({
    required String emailOrPhone,
    String? otp,
    String? password,
  }) async {
    try {
      final body = <String, dynamic>{
        'emailOrPhone': emailOrPhone,
        'device': await _buildDevicePayload(),
      };

      if (otp != null && otp.trim().isNotEmpty) {
        body['otp'] = otp;
      }
      if (password != null && password.isNotEmpty) {
        body['password'] = password;
      }

      final res = await authApiProvider.verifyLogin(body: body);

      final data = res['data']?['data'];

      UserModel? user = UserModel.fromMap(data);

      if (user.accessToken.isEmpty) {
        return DataResponse.error(
          'Access token not found in verify-login response',
        );
      }
      await setAccessToken(user.accessToken);
      await secureStorage.setUser(user: user);
      _isLoggedIn.value = true;
      _user.value = user;

      await _registerPushTokenAfterLogin();

      return DataResponse.success(true);
    } on CustomException catch (e) {
      Log.e(e);
      return DataResponse.error(
        e.message?.toString() ?? e.toString(),
        e.statusCode,
        e.code,
      );
    } catch (e) {
      Log.e(e);
      return DataResponse.error(e.toString());
    }
  }

  Future<void> _registerPushTokenAfterLogin() async {
    await PushNotificationService.instance.saveTokenToServer();
    await NotificationBadgeSync.instance.syncFromServer();
  }

  Future<Map<String, dynamic>> _buildDevicePayload() async {
    final deviceId = await deviceInfoUtils.getStableDeviceId();
    final fcmToken = await PushNotificationService.instance.getToken();
    final appVersion = await deviceInfoUtils.getAppVersion();

    return {
      'deviceId': deviceId,
      'fcmToken': fcmToken ?? '',
      'platform': Platform.isIOS ? 'ios' : 'android',
      'appVersion': appVersion,
    };
  }

  Future<DataResponse<bool>> sendLoginOtp({
    required String emailOrPhone,
  }) async {
    try {
      final body = <String, dynamic>{'emailOrPhone': emailOrPhone};

      await authApiProvider.sendLoginOtp(body: body);
      return DataResponse.success(true);
    } catch (e) {
      Log.e(e);
      return DataResponse.error(e.toString());
    }
  }

  Future<DataResponse<bool>> forgotPassword({
    required String emailOrPhone,
  }) async {
    try {
      await authApiProvider.forgotPassword(
        body: {'emailOrPhone': emailOrPhone},
      );
      return DataResponse.success(true);
    } on CustomException catch (e) {
      Log.e(e);
      return DataResponse.error(
        e.message?.toString() ?? e.toString(),
        e.statusCode,
      );
    } catch (e) {
      Log.e(e);
      return DataResponse.error(e.toString());
    }
  }

  Future<DataResponse<bool>> verifyPasswordToken({
    required String emailOrPhone,
    required String token,
  }) async {
    try {
      await authApiProvider.verifyPasswordToken(
        body: {'emailOrPhone': emailOrPhone, 'token': token},
      );
      return DataResponse.success(true);
    } on CustomException catch (e) {
      Log.e(e);
      return DataResponse.error(
        e.message?.toString() ?? e.toString(),
        e.statusCode,
      );
    } catch (e) {
      Log.e(e);
      return DataResponse.error(e.toString());
    }
  }

  Future<DataResponse<bool>> resetPassword({
    required String emailOrPhone,
    required String token,
    required String password,
  }) async {
    try {
      await authApiProvider.resetPassword(
        body: {
          'emailOrPhone': emailOrPhone,
          'token': token,
          'password': password,
        },
      );
      return DataResponse.success(true);
    } on CustomException catch (e) {
      Log.e(e);
      return DataResponse.error(
        e.message?.toString() ?? e.toString(),
        e.statusCode,
      );
    } catch (e) {
      Log.e(e);
      return DataResponse.error(e.toString());
    }
  }

  Future<DataResponse<bool>> changePassword({
    String? currentPassword,
    required String newPassword,
  }) async {
    try {
      final body = <String, dynamic>{
        'newPassword': newPassword,
        if (currentPassword != null && currentPassword.isNotEmpty)
          'currentPassword': currentPassword,
      };
      final res = await authApiProvider.changePassword(body: body);

      final data = res['data']?['data'];
      if (data is Map) {
        final payload = Map<String, dynamic>.from(data);
        final accessToken = payload['accessToken']?.toString() ?? '';
        final refreshToken = payload['refreshToken']?.toString() ?? '';

        if (accessToken.isNotEmpty) {
          _accessToken = accessToken;
          await setAccessToken(accessToken);
        }

        if (refreshToken.isNotEmpty) {
          _refreshToken = refreshToken;
          await setRefreshToken(refreshToken);
        }

        final currentUser = _user.value;
        if (currentUser != null && accessToken.isNotEmpty) {
          final updatedUser = currentUser.copyWith(accessToken: accessToken);
          _user.value = updatedUser;
          await secureStorage.setUser(user: updatedUser);
        }
      }

      return DataResponse.success(true);
    } on CustomException catch (e) {
      Log.e(e);
      return DataResponse.error(
        e.message?.toString() ?? e.toString(),
        e.statusCode,
        e.code,
      );
    } catch (e) {
      Log.e(e);
      return DataResponse.error(e.toString());
    }
  }

  Future<DataResponse<bool>> addEmail({required String email}) async {
    try {
      await authApiProvider.addEmail(body: {'email': email.trim()});
      return DataResponse.success(true);
    } on CustomException catch (e) {
      Log.e(e);
      return DataResponse.error(
        e.message?.toString() ?? e.toString(),
        e.statusCode,
        e.code,
      );
    } catch (e) {
      Log.e(e);
      return DataResponse.error(e.toString());
    }
  }

  Future<DataResponse<bool>> addPhone({required String phone}) async {
    try {
      await authApiProvider.addPhone(body: {'phone': phone.trim()});
      return DataResponse.success(true);
    } on CustomException catch (e) {
      Log.e(e);
      return DataResponse.error(
        e.message?.toString() ?? e.toString(),
        e.statusCode,
        e.code,
      );
    } catch (e) {
      Log.e(e);
      return DataResponse.error(e.toString());
    }
  }

  Future<DataResponse<bool>> verifyEmail({required String token}) async {
    try {
      await authApiProvider.verifyEmail(body: {'token': token.trim()});
      await getMe();
      return DataResponse.success(true);
    } on CustomException catch (e) {
      Log.e(e);
      return DataResponse.error(
        e.message?.toString() ?? e.toString(),
        e.statusCode,
        e.code,
      );
    } catch (e) {
      Log.e(e);
      return DataResponse.error(e.toString());
    }
  }

  Future<DataResponse<bool>> verifyPhone({required String token}) async {
    try {
      await authApiProvider.verifyPhone(body: {'token': token.trim()});
      await getMe();
      return DataResponse.success(true);
    } on CustomException catch (e) {
      Log.e(e);
      return DataResponse.error(
        e.message?.toString() ?? e.toString(),
        e.statusCode,
        e.code,
      );
    } catch (e) {
      Log.e(e);
      return DataResponse.error(e.toString());
    }
  }

  Future<DataResponse<bool>> sendVerifyEmailOtp() async {
    try {
      await authApiProvider.sendVerifyEmailOtp();
      return DataResponse.success(true);
    } on CustomException catch (e) {
      Log.e(e);
      return DataResponse.error(
        e.message?.toString() ?? e.toString(),
        e.statusCode,
        e.code,
      );
    } catch (e) {
      Log.e(e);
      return DataResponse.error(e.toString());
    }
  }

  Future<DataResponse<bool>> sendVerifyPhoneOtp() async {
    try {
      await authApiProvider.sendVerifyPhoneOtp();
      return DataResponse.success(true);
    } on CustomException catch (e) {
      Log.e(e);
      return DataResponse.error(
        e.message?.toString() ?? e.toString(),
        e.statusCode,
        e.code,
      );
    } catch (e) {
      Log.e(e);
      return DataResponse.error(e.toString());
    }
  }

  // Future<String> getFirebaseMessagingToken() async {
  //   try {
  //     String firebaseAppToken = '';

  //     await PermissionHandlerUtils.notificationPermission();
  //     firebaseAppToken = await FirebaseMessaging.instance.getToken() ?? "";
  //     return firebaseAppToken;
  //   } catch (e) {
  //     throw Exception('Failed to get Firebase Messaging Token $e');
  //   }
  // }

  // Future<DataResponse<bool>> deleteUser({
  //   required String phoneNumber,
  //   required String password,
  //   required String reasonToDelete,
  // }) async {
  //   try {
  //     await authApiProvider.deleteUser(
  //       phoneNumber: phoneNumber,
  //       password: password,
  //       reasonToDelete: reasonToDelete,
  //       accessToken: accessToken,
  //       userId: _user.value?.id ?? "",
  //     );

  //     return DataResponse.success(true);
  //   } catch (e) {
  //     if (kDebugMode) {
  //       Log.e(e);
  //     }
  //     return DataResponse.error(e.toString());
  //   }
  // }

  // Future<DataResponse<bool>> verifyOtp({required String otp}) async {
  //   try {
  //     final otpTemp = int.parse(otp);
  //     final res = await authApiProvider.verifyOtp(
  //       otp: otpTemp,
  //       token: _tempToken,
  //       email: _tempPhoneNumber,
  //     );

  //     _role.value = res['data']?['data']?['admin']?['role'] ?? "";

  //     _user.value = UserModel.fromMap(res['data']?['data']?['admin'] ?? {});

  //     _accessToken = res['data']?['data']?["tokens"]?['accessToken'] ?? "";

  //     if (_user.value?.isKYCVerified ?? false) {
  //       await _getMe();
  //     }

  //     await SecureStorage().setUser(user: _user.value!);

  //     await SecureStorage().setUserRole(role: _role.value ?? "");

  //     await setAccessToken(_accessToken);

  //     _isLoggedIn.value = true;

  //     return DataResponse.success(true);
  //   } catch (e) {
  //     _accessToken = '';
  //     _refreshToken = '';
  //     _isLoggedIn.value = false;
  //     debugPrint(e.toString());
  //     return DataResponse.error(e.toString());
  //   }
  // }

  // Future<DataResponse<bool>> resendOtp() async {
  //   try {
  //     await authApiProvider.resendOtp(
  //       token: _tempToken,
  //       phoneNumber: _tempPhoneNumber,
  //     );

  //     return DataResponse.success(true);
  //   } catch (e) {
  //     _accessToken = '';
  //     _refreshToken = '';
  //     _isLoggedIn.value = false;
  //     debugPrint(e.toString());
  //     return DataResponse.error(e.toString());
  //   }
  // }

  // Future<DataResponse> forgetPasswordVerifyPhoneNumber({
  //   required String phoneNumber,
  // }) async {
  //   try {
  //     await authApiProvider.forgetPasswordVerifyPhoneNumber(
  //       phoneNumber: phoneNumber,
  //     );

  //     return DataResponse.success(true);
  //   } catch (e) {
  //     debugPrint(e.toString());
  //     return DataResponse.error(e.toString());
  //   }
  // }
}
