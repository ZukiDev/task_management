import '../../core/network/api_exception.dart';
import '../../domain/repositories/auth_repository.dart';

class LoginController {
  final AuthRepository _authRepository;

  LoginController(this._authRepository);

  bool isLoading = false;
  String? errorMessage;

  Future<bool> login({required String email, required String password}) async {
    isLoading = true;
    errorMessage = null;

    try {
      await _authRepository.login(email: email, password: password);
      isLoading = false;
      return true;
    } on ApiException catch (e) {
      isLoading = false;
      errorMessage = e.message;
      return false;
    } catch (e) {
      isLoading = false;
      errorMessage = 'Terjadi kesalahan tidak terduga. Coba lagi.';
      return false;
    }
  }
}
