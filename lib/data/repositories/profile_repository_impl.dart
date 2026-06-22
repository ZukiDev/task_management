import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../local/session_storage.dart';
import '../models/user_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SessionStorage _sessionStorage;
  final ProfileLocalDatasource _localDatasource;

  ProfileRepositoryImpl(this._sessionStorage, this._localDatasource);

  @override
  Future<UserModel> getProfile() async {
    final user = await _sessionStorage.getUser();
    if (user == null) {
      throw StateError('Tidak ada user yang sedang login.');
    }
    return user;
  }

  @override
  Future<UserModel> updateName(String newName) async {
    final current = await getProfile();
    final updated = current.copyWith(name: newName);
    await _sessionStorage.updateStoredUser(updated);
    return updated;
  }

  @override
  Future<UserModel> updatePhoto(String localPhotoPath) async {
    final current = await getProfile();
    final updated = current.copyWith(localPhotoPath: localPhotoPath);
    await _sessionStorage.updateStoredUser(updated);
    return updated;
  }

  @override
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final storedPassword = await _localDatasource.getPassword();
    final isOldPasswordValid =
        storedPassword == null || storedPassword == oldPassword;

    if (!isOldPasswordValid) return false;

    await _localDatasource.savePassword(newPassword);
    return true;
  }
}
