import '../../data/models/user_model.dart';

/// Kontrak operasi autentikasi & session.
abstract class AuthRepository {
  /// Mendaftarkan user baru. Mengembalikan user yang berhasil dibuat
  /// sekaligus otomatis menyimpan session (token) secara lokal.
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  });

  /// Login dengan email & password. Mengembalikan user dan menyimpan
  /// session secara lokal.
  Future<UserModel> login({required String email, required String password});

  /// Menghapus session yang tersimpan (token, user) dari device.
  Future<void> logout();

  /// Mengecek apakah ada session tersimpan yang masih valid (token belum
  /// expired). Dipakai oleh Splash Screen untuk menentukan halaman awal.
  Future<UserModel?> getCurrentSession();
}
