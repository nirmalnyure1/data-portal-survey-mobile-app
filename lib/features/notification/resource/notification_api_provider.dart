import 'package:data_portal_survey/common/http/api_provider.dart';

class NotificationApiProvider {
  final ApiProvider apiProvider;

  NotificationApiProvider({required this.apiProvider});

  Future<dynamic> getMyNotifications({
    required int page,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    return apiProvider.get(
      'notifications/me',
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
        // 'unreadOnly': unreadOnly.toString(),
      },
    );
  }

  Future<dynamic> getUnreadCount() async {
    return apiProvider.get('notifications/me/unread-count');
  }

  Future<dynamic> markNotificationRead({required String id}) async {
    return apiProvider.patch('notifications/me/$id/read');
  }

  Future<dynamic> markAllNotificationsRead() async {
    return apiProvider.patch('notifications/me/read-all');
  }

  Future<dynamic> registerDevice(Map<String, dynamic> body) async {
    return apiProvider.put('devices/me', body: body);
  }

  Future<dynamic> patchDevice(Map<String, dynamic> body) async {
    return apiProvider.patch('devices/me', body: body);
  }

  Future<dynamic> deleteDevice({required String deviceId}) async {
    return apiProvider.delete('devices/$deviceId');
  }

  Future<dynamic> getMyNotificationPreferences() async {
    return apiProvider.get('notification-preferences/me');
  }

  Future<dynamic> updateMyNotificationPreferences(
    Map<String, dynamic> body,
  ) async {
    return apiProvider.patch('notification-preferences/me', body: body);
  }
}
