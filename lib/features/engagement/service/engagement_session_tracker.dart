class EngagementSessionTracker {
  EngagementSessionTracker._();

  static final EngagementSessionTracker instance = EngagementSessionTracker._();

  String? _lastTrackedAppOpenSessionKey;
  String? _activeNotificationLogId;

  bool shouldTrackAppOpen(String sessionKey) {
    if (sessionKey.isEmpty || _lastTrackedAppOpenSessionKey == sessionKey) {
      return false;
    }
    _lastTrackedAppOpenSessionKey = sessionKey;
    return true;
  }

  void resetSession() {
    _lastTrackedAppOpenSessionKey = null;
    _activeNotificationLogId = null;
  }

  void setActiveNotificationLogId(String? notificationLogId) {
    if (notificationLogId == null || notificationLogId.isEmpty) return;
    _activeNotificationLogId = notificationLogId;
  }

  String? get activeNotificationLogId => _activeNotificationLogId;

  void clearActiveNotificationLogId() {
    _activeNotificationLogId = null;
  }
}
