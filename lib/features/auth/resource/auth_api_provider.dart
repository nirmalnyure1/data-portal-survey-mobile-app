import '../../../common/http/http.dart';

class AuthApiProvider {
  final ApiProvider apiProvider;

  final String basePath = "auth";

  AuthApiProvider({required this.apiProvider});

  // Future<dynamic> login({required Map<String, String> body}) async {
  //   final uri = "$basePath/";

  //   return await apiProvider.post(uri, body);
  // }

  // Future<dynamic> updatePassword({
  //   required Map<String, String> body,
  //   required String token,
  // }) async {
  //   final uri = "$baseUrl/auth/update-password";

  //   return await apiProvider.patch(uri, body, token: token);
  // }

  Future<dynamic> userRegister(Map<String, dynamic> body) async {
    final uri = "$basePath/register";
    return await apiProvider.post(uri, body);
  }

  Future<dynamic> verifyLogin({required Map<String, dynamic> body}) async {
    final uri = "$basePath/verify-login";
    return await apiProvider.post(uri, body);
  }

  Future<dynamic> sendLoginOtp({required Map<String, dynamic> body}) async {
    final uri = "$basePath/send-login-otp";
    return await apiProvider.post(uri, body);
  }

  Future<dynamic> getMe() async {
    return apiProvider.get('$basePath/me');
  }

  Future<dynamic> forgotPassword({required Map<String, dynamic> body}) async {
    return apiProvider.post('$basePath/forgot-password', body);
  }

  Future<dynamic> verifyPasswordToken({
    required Map<String, dynamic> body,
  }) async {
    return apiProvider.post('$basePath/verify-password-token', body);
  }

  Future<dynamic> resetPassword({required Map<String, dynamic> body}) async {
    return apiProvider.post('$basePath/reset-password', body);
  }

  Future<dynamic> changePassword({required Map<String, dynamic> body}) async {
    return apiProvider.post('$basePath/me/change-password', body);
  }

  Future<dynamic> addEmail({required Map<String, dynamic> body}) async {
    return apiProvider.post('$basePath/me/add-email', body);
  }

  Future<dynamic> addPhone({required Map<String, dynamic> body}) async {
    return apiProvider.post('$basePath/me/add-phone', body);
  }

  Future<dynamic> verifyEmail({required Map<String, dynamic> body}) async {
    return apiProvider.patch('$basePath/verify-email', body: body);
  }

  Future<dynamic> verifyPhone({required Map<String, dynamic> body}) async {
    return apiProvider.patch('$basePath/verify-phone', body: body);
  }

  Future<dynamic> sendVerifyEmailOtp() async {
    return apiProvider.post('$basePath/send-verify-email-otp', {});
  }

  Future<dynamic> sendVerifyPhoneOtp() async {
    return apiProvider.post('$basePath/send-verify-phone-otp', {});
  }

  // Future<dynamic> logout({required Map<String, dynamic> body}) async {
  //   final uri = "$baseUrl/auth/farmer-logout";
  //   return await apiProvider.post(uri, body);
  // }

  // Future<dynamic> getUserDetails(String token) async {
  //   final uri = "$baseUrl/analytics/farmer-analytics";

  //   return await apiProvider.get(uri, token: token);
  // }

  // Future<dynamic> getMe(String token) async {
  //   final  uri = "$baseUrl/auth/my-info";

  //   return await apiProvider.get(uri, token: token);
  // }

  // Future<dynamic> deleteUser({
  //   required String phoneNumber,
  //   required String password,
  //   required String reasonToDelete,
  //   required String accessToken,
  //   required String userId,
  // }) async {
  //   Map<String, dynamic> param = {
  //     "phoneNumber": phoneNumber,
  //     "password": password,
  //     "reasonToDelete": reasonToDelete,
  //   };
  //   String uri = "$baseUrl/auth/delete-account/$userId";

  //   // uri = uri.replace(queryParameters: param);

  //   return await apiProvider.delete(
  //     uri,
  //     token: accessToken,
  //     updatedQueryParams: param,
  //   );
  // }

  // Future<dynamic> getMunicipality(String? search) async {
  //   Map<String, dynamic> param = {
  //     "search": search ?? "",
  //   };

  //   Uri uri = Uri.parse("$baseUrl/municipality-list");

  //   uri = uri.replace(queryParameters: param);

  //   return await apiProvider.get(
  //     uri,
  //   );
  // }

  // Future verifyOtp({
  //   required int otp,
  //   required String token,
  //   required String email,
  // }) async {
  //   Map<String, dynamic> body = {"otp": otp, "token": token, "phone": email};
  //   final uri = "$baseUrl/auth/verify-otp";

  //   return await apiProvider.post(uri, body);
  // }

  // Future resendOtp({required String token, required String phoneNumber}) async {
  //   Map<String, dynamic> body = {
  //     // "token": token,
  //     "phone": phoneNumber,
  //   };

  //   final uri = "$baseUrl/auth/resend-otp";

  //   return await apiProvider.post(uri, body);
  // }

  // Future forgetPasswordVerifyPhoneNumber({required String phoneNumber}) async {
  //   Map<String, dynamic> body = {"phoneNumber": phoneNumber};

  //   final uri = "$baseUrl/auth/reset/password-reset-email";

  //   return await apiProvider.post(uri, body);
  // }
}
