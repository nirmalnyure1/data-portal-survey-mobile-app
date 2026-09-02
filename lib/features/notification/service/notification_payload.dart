import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationPayload {
  final String? messageId;
  final String title;
  final String body;
  final String? type;
  final String? campaignId;
  final String? notificationLogId;
  final String? orderId;
  final String? imageUrl;
  final String? androidChannelId;
  final int? badge;
  final String? inboxNotificationId;
  final String? offerId;
  final String? bookingId;
  final String? refundId;
  final String? disputeId;
  final Map<String, String> data;

  const NotificationPayload({
    this.messageId,
    required this.title,
    required this.body,
    this.type,
    this.campaignId,
    this.notificationLogId,
    this.orderId,
    this.imageUrl,
    this.androidChannelId,
    this.badge,
    this.inboxNotificationId,
    this.offerId,
    this.bookingId,
    this.refundId,
    this.disputeId,
    this.data = const {},
  });

  factory NotificationPayload.fromRemoteMessage(RemoteMessage message) {
    return NotificationPayload.fromDataMap(
      message.data,
      title: message.notification?.title,
      body: message.notification?.body,
      messageId: message.messageId,
    );
  }

  factory NotificationPayload.fromDataMap(
    Map<String, dynamic> data, {
    String? title,
    String? body,
    String? messageId,
    String? inboxNotificationId,
  }) {
    final normalizedData = <String, String>{};
    for (final entry in data.entries) {
      normalizedData[entry.key] = entry.value.toString();
    }

    return NotificationPayload(
      messageId: messageId,
      title: data['title']?.toString() ?? title ?? '',
      body: data['body']?.toString() ?? body ?? '',
      type: data['type']?.toString(),
      campaignId: data['campaignId']?.toString() ?? data['campaign_id']?.toString(),
      notificationLogId:
          data['notificationLogId']?.toString() ??
          data['notification_log_id']?.toString(),
      orderId: data['orderId']?.toString() ?? data['order_id']?.toString(),
      imageUrl: data['imageUrl']?.toString() ?? data['image_url']?.toString(),
      androidChannelId:
          data['androidChannelId']?.toString() ??
          data['android_channel_id']?.toString(),
      badge: int.tryParse((data['badge'] ?? '').toString()),
      inboxNotificationId:
          inboxNotificationId ??
          data['notificationId']?.toString() ??
          data['inboxNotificationId']?.toString(),
      offerId: data['offerId']?.toString(),
      bookingId: data['bookingId']?.toString(),
      refundId: data['refundId']?.toString(),
      disputeId: data['disputeId']?.toString(),
      data: normalizedData,
    );
  }

  factory NotificationPayload.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final parsedData = <String, String>{};
    if (rawData is Map) {
      for (final entry in rawData.entries) {
        parsedData[entry.key.toString()] = entry.value.toString();
      }
    }

    return NotificationPayload(
      messageId: json['messageId'] as String?,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: json['type'] as String?,
      campaignId: (json['campaignId'] ?? json['campaign_id']) as String?,
      notificationLogId:
          (json['notificationLogId'] ?? json['notification_log_id']) as String?,
      orderId: (json['orderId'] ?? json['order_id']) as String?,
      imageUrl: (json['imageUrl'] ?? json['image_url']) as String?,
      androidChannelId:
          (json['androidChannelId'] ?? json['android_channel_id']) as String?,
      badge: json['badge'] is int
          ? json['badge'] as int
          : int.tryParse((json['badge'] ?? '').toString()),
      inboxNotificationId:
          json['inboxNotificationId'] as String? ??
          json['notificationId'] as String?,
      offerId: json['offerId'] as String?,
      bookingId: json['bookingId'] as String?,
      refundId: json['refundId'] as String?,
      disputeId: json['disputeId'] as String?,
      data: parsedData,
    );
  }

  factory NotificationPayload.fromEncoded(String encoded) {
    if (encoded.isEmpty) {
      return const NotificationPayload(title: '', body: '');
    }
    return NotificationPayload.fromJson(
      jsonDecode(encoded) as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'messageId': messageId,
    'title': title,
    'body': body,
    'type': type,
    'campaignId': campaignId,
    'notificationLogId': notificationLogId,
    'order_id': orderId,
    'image_url': imageUrl,
    'androidChannelId': androidChannelId,
    'badge': badge,
    'inboxNotificationId': inboxNotificationId,
    'offerId': offerId,
    'bookingId': bookingId,
    'refundId': refundId,
    'disputeId': disputeId,
    'data': data,
  };

  String encode() => jsonEncode(toJson());

  String get deduplicationKey {
    if (messageId != null && messageId!.isNotEmpty) {
      return messageId!;
    }
    return '$title|$body|${type ?? ''}|${notificationLogId ?? orderId ?? ''}';
  }
}
