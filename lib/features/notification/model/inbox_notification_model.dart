class InboxNotificationModel {
  final String id;
  final String? userId;
  final String title;
  final String body;
  final String type;
  final String category;
  final Map<String, String> data;
  final String? readAt;
  final String createdAt;
  final String? updatedAt;

  const InboxNotificationModel({
    required this.id,
    this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.category,
    this.data = const {},
    this.readAt,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isUnread => readAt == null;

  InboxNotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    String? type,
    String? category,
    Map<String, String>? data,
    String? readAt,
    String? createdAt,
    String? updatedAt,
  }) {
    return InboxNotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      category: category ?? this.category,
      data: data ?? this.data,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory InboxNotificationModel.fromMap(Map<String, dynamic> map) {
    final rawData = map['data'];
    final parsedData = <String, String>{};
    if (rawData is Map) {
      for (final entry in rawData.entries) {
        parsedData[entry.key.toString()] = entry.value?.toString() ?? '';
      }
    }

    return InboxNotificationModel(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString(),
      title: map['title']?.toString() ?? '',
      body: map['body']?.toString() ?? '',
      type: map['type']?.toString() ?? parsedData['type'] ?? '',
      category: map['category']?.toString() ?? '',
      data: parsedData,
      readAt: map['readAt']?.toString(),
      createdAt: map['createdAt']?.toString() ?? '',
      updatedAt: map['updatedAt']?.toString(),
    );
  }
}

class InboxNotificationPage {
  final List<InboxNotificationModel> items;
  final int currentPage;
  final int totalPages;
  final int total;

  const InboxNotificationPage({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.total,
  });
}
