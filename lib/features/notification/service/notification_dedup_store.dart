import 'package:shared_preferences/shared_preferences.dart';

class NotificationDedupStore {
  NotificationDedupStore._();

  static const String _recentMessageIdsKey = 'recent_fcm_message_ids';
  static const int _maxStoredMessageIds = 50;
  static final Set<String> _processedMessageIds = {};

  static Future<bool> isDuplicate(String key) async {
    if (key.isEmpty) return false;

    if (_processedMessageIds.contains(key)) return true;

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_recentMessageIdsKey) ?? <String>[];
    if (stored.contains(key)) {
      _processedMessageIds.add(key);
      return true;
    }

    _processedMessageIds.add(key);
    final updated = <String>[key, ...stored];
    if (updated.length > _maxStoredMessageIds) {
      updated.removeRange(_maxStoredMessageIds, updated.length);
    }
    await prefs.setStringList(_recentMessageIdsKey, updated);
    return false;
  }
}
