import '../../data/local/session_storage.dart';

/// Hasil pengecekan session, dipakai SplashPage untuk menentukan
/// halaman tujuan.
enum SplashResult { authenticated, unauthenticated }

/// Controller untuk Splash Screen.
///
/// Plain Dart class (bukan widget) — tugasnya cuma satu: cek apakah ada
/// session tersimpan yang masih valid. SplashPage yang StatefulWidget
/// akan memanggil [checkSession] lalu memutuskan mau navigasi kemana.
class SplashController {
  final SessionStorage _sessionStorage;

  SplashController(this._sessionStorage);

  Future<SplashResult> checkSession() async {
    final hasValidSession = await _sessionStorage.hasValidSession();
    return hasValidSession
        ? SplashResult.authenticated
        : SplashResult.unauthenticated;
  }
}
