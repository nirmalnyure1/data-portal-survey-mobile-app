import 'package:data_portal_survey/common/http/http.dart';

class EngagementApiProvider {
  final ApiProvider apiProvider;

  EngagementApiProvider({required this.apiProvider});

  Future<dynamic> trackActivity({required Map<String, dynamic> body}) async {
    return apiProvider.post('engagement/activities/track', body);
  }

  Future<dynamic> markNotificationOpen({required String id}) async {
    return apiProvider.post('engagement/notifications/$id/open', {});
  }

  Future<dynamic> markNotificationClick({required String id}) async {
    return apiProvider.post('engagement/notifications/$id/click', {});
  }

  Future<dynamic> markNotificationDismiss({required String id}) async {
    return apiProvider.post('engagement/notifications/$id/dismiss', {});
  }

  Future<dynamic> markNotificationConvert({
    required String id,
    Map<String, dynamic>? body,
  }) async {
    return apiProvider.post('engagement/notifications/$id/convert', body ?? {});
  }
}
