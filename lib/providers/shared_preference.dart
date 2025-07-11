import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static Future<void> saveUser({
    required String id,
    required String email,
    required String username,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', id);
    await prefs.setString('email', email);
    await prefs.setString('username', username);
  }

  static Future<Map<String, String>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId');
    final email = prefs.getString('email');
    final username = prefs.getString('username');

    if (id != null && email != null && username != null) {
      return {'id': id, 'email': email, 'username': username};
    }
    return null;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
