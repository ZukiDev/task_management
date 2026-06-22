import '../../core/utils/collection_name_helper.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../local/session_storage.dart';
import '../models/user_model.dart';

/// Implementasi [AuthRepository].
///
/// Tugasnya mengorkestrasi dua hal: memanggil [AuthRemoteDatasource]
/// untuk dapat token dari server, lalu menyimpannya lewat
/// [SessionStorage] supaya user tidak perlu login ulang setiap buka app.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;
  final SessionStorage _sessionStorage;

  AuthRepositoryImpl(this._remoteDatasource, this._sessionStorage);

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _remoteDatasource.register(
      name: name,
      email: email,
      password: password,
    );
    await _persistSession(response.token, response.tokenType,
        response.expiresAt, response.user);
    return response.user;
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _remoteDatasource.login(
      email: email,
      password: password,
    );
    await _persistSession(response.token, response.tokenType,
        response.expiresAt, response.user);
    return response.user;
  }

  Future<void> _persistSession(
    String token,
    String tokenType,
    DateTime expiresAt,
    UserModel user,
  ) async {
    final collectionName = CollectionNameHelper.fromEmail(user.email);
    await _sessionStorage.saveSession(
      token: token,
      tokenType: tokenType,
      expiresAt: expiresAt,
      user: user,
      collectionName: collectionName,
    );
  }

  @override
  Future<void> logout() async {
    await _sessionStorage.clear();
  }

  @override
  Future<UserModel?> getCurrentSession() async {
    final hasValid = await _sessionStorage.hasValidSession();
    if (!hasValid) return null;
    return _sessionStorage.getUser();
  }
}