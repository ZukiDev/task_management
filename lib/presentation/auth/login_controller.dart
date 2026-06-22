import '../../core/network/api_exception.dart';
import '../../domain/repositories/auth_repository.dart';

/// Controller untuk Login Page.
///
/// Pola yang konsisten dipakai di semua controller pada app ini:
/// - field `is...Loading` / `errorMessage` adalah STATE.
/// - method `Future<bool> login(...)` MENGUBAH state lalu return
///   true/false sebagai sinyal sukses/gagal ke widget.
/// - Widget (StatefulWidget) memanggil method ini lalu `setState(() {})`
///   supaya UI ikut re-render sesuai state terbaru di controller.
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
