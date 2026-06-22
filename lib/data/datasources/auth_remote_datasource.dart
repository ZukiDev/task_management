import '../../core/network/api_client.dart';
import '../models/auth_response_model.dart';

class AuthRemoteDatasource {
  final ApiClient _apiClient;

  AuthRemoteDatasource(this._apiClient);

  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final json = await _apiClient.post(
      '/register',
      body: {'name': name, 'email': email, 'password': password},
    );
    return AuthResponseModel.fromApiJson(json as Map<String, dynamic>);
  }

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final json = await _apiClient.post(
      '/login',
      body: {'email': email, 'password': password},
    );
    return AuthResponseModel.fromApiJson(json as Map<String, dynamic>);
  }
}
