import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:data_portal_survey/common/http/api_provider.dart';
import 'package:data_portal_survey/common/http/data_response.dart';
import 'package:data_portal_survey/features/notification/model/inbox_notification_model.dart';
import 'package:data_portal_survey/features/notification/model/notification_model.dart';
import 'package:data_portal_survey/features/notification/model/notification_preferences_model.dart';
import 'package:data_portal_survey/features/notification/resource/all_notification_repository.dart';
import 'package:data_portal_survey/features/notification/resource/notification_api_provider.dart';

class NotificationRepository {
  late NotificationApiProvider notificationApiProvider;

  final AllNotificationRepository allNotificationRepository;

  final ApiProvider apiProvider;
  NotificationRepository({
    required this.apiProvider,
    required this.allNotificationRepository,
  }) {
    notificationApiProvider = NotificationApiProvider(apiProvider: apiProvider);
  }

  bool _appOpenedFromNotification = false;

  bool get appOpenNotification => _appOpenedFromNotification;

  setAppOpenNotification(value) {
    _appOpenedFromNotification = value;
  }

  bool _isFromCurrentWeek(DateTime fileDate) {
    final now = DateTime.now();

    // Get the start of current week (Sunday)
    final currentWeekStart = now.subtract(Duration(days: now.weekday % 7));
    final currentWeekStartDate = DateTime(
      currentWeekStart.year,
      currentWeekStart.month,
      currentWeekStart.day,
    );

    // Get the start of file's week (Sunday)
    final fileWeekStart = fileDate.subtract(
      Duration(days: fileDate.weekday % 7),
    );
    final fileWeekStartDate = DateTime(
      fileWeekStart.year,
      fileWeekStart.month,
      fileWeekStart.day,
    );

    return currentWeekStartDate.isAtSameMomentAs(fileWeekStartDate);
  }

  String _generateCacheKey(
    String location,
    List<String> crops,
    List<String> livestock,
  ) {
    final cropsStr = crops..sort();
    final livestockStr = livestock..sort();
    final combined =
        '$location-${cropsStr.join(',')}-${livestockStr.join(',')}';
    final bytes = utf8.encode(combined);
    final hash = md5.convert(bytes);
    return hash.toString();
  }

  // ignore: unused_element
  Future<String?> _getCachedAudioPath(
    String location,
    List<String> crops,
    List<String> livestock,
  ) async {
    try {
      final cacheKey = _generateCacheKey(location, crops, livestock);
      final directory = await getApplicationDocumentsDirectory();
      final cachePath = '${directory.path}/audio_cache/$cacheKey.mp3';

      final file = File(cachePath);
      if (await file.exists()) {
        final lastModified = await file.lastModified();

        if (!_isFromCurrentWeek(lastModified)) {
          await file.delete();
          debugPrint(
            '✓ Cache cleared - new week started (file from: ${lastModified.toString().substring(0, 10)})',
          );
          return null;
        }

        debugPrint('Using cached audio from current week');
        return cachePath;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting cached audio path: $e');
      return null;
    }
  }

  /// Download and save audio file to local storage
  // ignore: unused_element
  Future<String?> _downloadAndCacheAudio(
    String url,
    String location,
    List<String> crops,
    List<String> livestock,
  ) async {
    try {
      final cacheKey = _generateCacheKey(location, crops, livestock);
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/audio_cache');

      // Create cache directory if it doesn't exist
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      final filePath = '${cacheDir.path}/$cacheKey.mp3';

      // Download the audio file
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        debugPrint('✓ Audio cached successfully');
        return filePath;
      } else {
        debugPrint('Failed to download audio: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error downloading and caching audio: $e');
      return null;
    }
  }

  int _currentPage = 1;
  int _totalPage = 0;
  final List<String> _items = [];
  List<String> get getItems => _items;

  Future<DataResponse<List<String>>> getNotificaiton({
    bool isLoadMore = false,
  }) async {
    List<NotificationCardModel> temp = [];
    try {
      if (isLoadMore) {
        if (_currentPage == _totalPage) {
          return DataResponse.success(_items);
        }

        _currentPage++;
      }

      if (!isLoadMore) {
        _items.clear();
        _currentPage = 1;
        _totalPage = 0;
      }

      final res = await getMyNotifications(
        page: _currentPage,
      );

      if (res.data == null) {
        return DataResponse.error(res.message ?? 'Failed to load notifications');
      }

      temp = res.data!.items
          .map(
            (e) => NotificationCardModel(
              id: e.id,
              createdAt: e.createdAt,
              serviceName: e.category,
              title: e.title,
              body: e.body,
              viewType: e.type,
              isRead: !e.isUnread,
              publishedDate: e.createdAt,
            ),
          )
          .toList();

      _currentPage = res.data!.currentPage;
      _totalPage = res.data!.totalPages;

      for (var value in temp) {
        _items.add(value.id);
        allNotificationRepository.addAll({value.id: value});
      }
      return DataResponse.success(_items);
    } catch (e) {
      debugPrint(e.toString());

      if (isLoadMore) {
        _currentPage--;
      }

      return DataResponse.error(e.toString());
    }
  }

  Future<DataResponse<bool>> updateNotification({required String id}) async {
    try {
      await notificationApiProvider.markNotificationRead(id: id);
      allNotificationRepository.updated(id);

      return DataResponse.success(true);
    } catch (e) {
      debugPrint(e.toString());

      return DataResponse.error(e.toString());
    }
  }

  Future<DataResponse<InboxNotificationPage>> getMyNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    try {
      final res = await notificationApiProvider.getMyNotifications(
        page: page,
        limit: limit,
        unreadOnly: unreadOnly,
      );

      final payload = res['data']?['data'];
      final rawItems = payload is Map ? payload['data'] : null;
      final items = <InboxNotificationModel>[];
      if (rawItems is List) {
        for (final item in rawItems) {
          if (item is Map) {
            items.add(
              InboxNotificationModel.fromMap(
                Map<String, dynamic>.from(item),
              ),
            );
          }
        }
      }

      final pagination = payload is Map ? payload['pagination'] : null;
      return DataResponse.success(
        InboxNotificationPage(
          items: items,
          currentPage: pagination is Map
              ? (pagination['currentPage'] as num?)?.toInt() ?? page
              : page,
          totalPages: pagination is Map
              ? (pagination['totalPages'] as num?)?.toInt() ?? 1
              : 1,
          total: pagination is Map
              ? (pagination['total'] as num?)?.toInt() ?? items.length
              : items.length,
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
      return DataResponse.error(e.toString());
    }
  }

  Future<DataResponse<int>> getUnreadCount() async {
    try {
      final res = await notificationApiProvider.getUnreadCount();
      final count = res['data']?['data']?['count'];
      return DataResponse.success((count as num?)?.toInt() ?? 0);
    } catch (e) {
      debugPrint(e.toString());
      return DataResponse.error(e.toString());
    }
  }

  Future<DataResponse<bool>> markNotificationRead({required String id}) async {
    try {
      await notificationApiProvider.markNotificationRead(id: id);
      allNotificationRepository.updated(id);
      return DataResponse.success(true);
    } catch (e) {
      debugPrint(e.toString());
      return DataResponse.error(e.toString());
    }
  }

  Future<DataResponse<int>> markAllNotificationsRead() async {
    try {
      final res = await notificationApiProvider.markAllNotificationsRead();
      final updated = res['data']?['data']?['updated'];
      return DataResponse.success((updated as num?)?.toInt() ?? 0);
    } catch (e) {
      debugPrint(e.toString());
      return DataResponse.error(e.toString());
    }
  }

  Future<DataResponse<bool>> updateNotificationBadge() async {
    try {
      await markAllNotificationsRead();
      return DataResponse.success(true);
    } catch (e) {
      debugPrint(e.toString());

      return DataResponse.error(e.toString());
    }
  }

  Future<DataResponse<NotificationPreferencesModel>> getMyPreferences() async {
    try {
      final res = await notificationApiProvider.getMyNotificationPreferences();
      final data = res['data']?['data'];
      if (data is! Map) {
        return DataResponse.error('Invalid notification preferences response');
      }

      return DataResponse.success(
        NotificationPreferencesModel.fromMap(Map<String, dynamic>.from(data)),
      );
    } catch (e) {
      debugPrint(e.toString());
      return DataResponse.error(e.toString());
    }
  }

  Future<DataResponse<NotificationPreferencesModel>> updateMyPreferences(
    NotificationPreferencesModel preferences,
  ) async {
    try {
      final res = await notificationApiProvider.updateMyNotificationPreferences(
        preferences.toMap(),
      );
      final data = res['data']?['data'] ?? preferences.toMap();
      if (data is! Map) {
        return DataResponse.success(preferences);
      }

      return DataResponse.success(
        NotificationPreferencesModel.fromMap(Map<String, dynamic>.from(data)),
      );
    } catch (e) {
      debugPrint(e.toString());
      return DataResponse.error(e.toString());
    }
  }
}
