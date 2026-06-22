import '../../data/models/user_model.dart';

/// Kontrak operasi terkait profil user.
///
/// CATATAN: semua operasi di sini bersifat LOKAL (tersimpan di
/// shared_preferences device), karena restful-api.dev tidak menyediakan
/// endpoint untuk update profile/password user setelah registrasi.
/// Lihat catatan limitasi di [UserModel] dan README.
abstract class ProfileRepository {
  Future<UserModel> getProfile();

  Future<UserModel> updateName(String newName);

  Future<UserModel> updatePhoto(String localPhotoPath);

  /// Mengganti password secara lokal (simulasi). Mengembalikan true jika
  /// [oldPassword] sesuai dengan yang tersimpan, false jika tidak.
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}
