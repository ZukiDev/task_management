import '../../core/network/api_exception.dart';
import '../../domain/repositories/auth_repository.dart';

class RegisterController {
  final AuthRepository _authRepository;

  RegisterController(this._authRepository);

  bool isLoading = false;
  String? errorMessage;

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;

    try {
      await _authRepository.register(
        name: name,
        email: email,
        password: password,
      );
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
