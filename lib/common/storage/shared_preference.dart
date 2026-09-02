import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorage {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clear();
}



class LocalStorageImpl implements LocalStorage {
  final SharedPreferences prefs;

  LocalStorageImpl(this.prefs);

  static const _tokenKey = 'token';

  @override
  Future<void> saveToken(String token) async {
    await prefs.setString(_tokenKey, token);
  }

  @override
  Future<String?> getToken() async {
    return prefs.getString(_tokenKey);
  }

  @override
  Future<void> clear() async {
    await prefs.clear();
  }
}