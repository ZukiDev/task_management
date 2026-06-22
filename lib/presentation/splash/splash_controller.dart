import '../../data/local/session_storage.dart';

enum SplashResult { authenticated, unauthenticated }

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
