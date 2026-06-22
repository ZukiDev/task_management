import '../../data/models/user_model.dart';

abstract class ProfileRepository {
  Future<UserModel> getProfile();

  Future<UserModel> updateName(String newName);

  Future<UserModel> updatePhoto(String localPhotoPath);

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}
