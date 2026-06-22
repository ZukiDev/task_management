import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/profile_repository.dart';

/// Controller untuk Profile Page utama (bukan untuk sub-halaman edit
/// nama/foto/password — masing-masing punya controller sederhana
/// sendiri agar tetap fokus single-responsibility).
class ProfileController {
  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;

  ProfileController(this._profileRepository, this._authRepository);

  bool isLoading = false;
  String? errorMessage;
  UserModel? user;

  Future<void> loadProfile() async {
    isLoading = true;
    errorMessage = null;
    try {
      user = await _profileRepository.getProfile();
      isLoading = false;
    } catch (e) {
      isLoading = false;
      errorMessage = 'Gagal memuat profil.';
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
  }
}
