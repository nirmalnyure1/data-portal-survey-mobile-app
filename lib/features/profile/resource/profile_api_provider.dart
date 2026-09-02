import 'package:data_portal_survey/common/http/http.dart';

class ProfileApiProvider {
  final ApiProvider apiProvider;
  final String basePath = 'users';
  final String businessProfilePath = 'businessprofile';

  ProfileApiProvider({required this.apiProvider});

  Future<dynamic> updateProfile({
    required String userId,
    required Map<String, dynamic> body,
  }) async {
    return await apiProvider.patch('$basePath/$userId', body: body);
  }

  Future<dynamic> updateBusinessProfile({
    required Map<String, dynamic> body,
  }) async {
    return await apiProvider.patch(businessProfilePath, body: body);
  }
}
