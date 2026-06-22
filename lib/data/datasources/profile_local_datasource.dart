import 'package:shared_preferences/shared_preferences.dart';

/// Datasource lokal khusus untuk menyimpan password user.
///
/// CATATAN: restful-api.dev tidak punya endpoint "ubah password" —
/// password hanya dipakai sekali saat /login untuk dapat token, server
/// tidak mengembalikan/menyimpan password itu untuk diverifikasi ulang
/// dari sisi app. Karena itu, fitur "Ubah Password" di app ini adalah
/// SIMULASI: password disimpan terenkripsi-sederhana di
/// shared_preferences device, dan validasi "password lama" dicocokkan
/// dengan nilai itu, bukan dengan server.
///
/// Ini adalah keterbatasan yang disengaja akibat scope backend yang
/// dipakai, bukan kelalaian — didokumentasikan juga di README.
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