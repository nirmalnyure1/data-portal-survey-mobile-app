class NotificationPreferencesModel {
  final bool pushEnabled;
  final bool marketingEnabled;
  final bool orderEnabled;
  final Map<String, bool> topics;

  const NotificationPreferencesModel({
    required this.pushEnabled,
    required this.marketingEnabled,
    required this.orderEnabled,
    required this.topics,
  });

  factory NotificationPreferencesModel.fromMap(Map<String, dynamic> map) {
    final rawTopics = map['topics'];
    final topicMap = <String, bool>{};
    if (rawTopics is Map) {
      for (final entry in rawTopics.entries) {
        topicMap[entry.key.toString()] = entry.value == true;
      }
    }

    return NotificationPreferencesModel(
      pushEnabled: map['pushEnabled'] == true,
      marketingEnabled: map['marketingEnabled'] == true,
      orderEnabled: map['orderEnabled'] == true,
      topics: topicMap,
    );
  }

  Map<String, dynamic> toMap() => {
    'pushEnabled': pushEnabled,
    'marketingEnabled': marketingEnabled,
    'orderEnabled': orderEnabled,
    'topics': topics,
  };

  NotificationPreferencesModel copyWith({
    bool? pushEnabled,
    bool? marketingEnabled,
    bool? orderEnabled,
    Map<String, bool>? topics,
  }) {
    return NotificationPreferencesModel(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      marketingEnabled: marketingEnabled ?? this.marketingEnabled,
      orderEnabled: orderEnabled ?? this.orderEnabled,
      topics: topics ?? this.topics,
    );
  }
}
