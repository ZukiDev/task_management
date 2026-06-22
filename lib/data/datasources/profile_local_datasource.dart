import 'package:shared_preferences/shared_preferences.dart';

class ProfileLocalDatasource {
  static const _keyPassword = 'local_user_password';

  Future<void> savePassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPassword, password);
  }

  Future<String?> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPassword);
  }
}
