import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'api_exception.dart';

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _buildHeaders({String? token, bool withBody = false}) {
    if (ApiConstants.apiKey.isEmpty) {
      throw const ConfigurationException();
    }
    final headers = <String, String>{'x-api-key': ApiConstants.apiKey};
    if (withBody) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    if (queryParams == null || queryParams.isEmpty) return uri;
    return uri.replace(
      queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  Future<dynamic> get(
    String path, {
    String? token,
    Map<String, dynamic>? queryParams,
  }) async {
    return _send(
      () => _client.get(
        _buildUri(path, queryParams),
        headers: _buildHeaders(token: token),
      ),
    );
  }

  Future<dynamic> post(
    String path, {
    String? token,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
  }) async {
    return _send(
      () => _client.post(
        _buildUri(path, queryParams),
        headers: _buildHeaders(token: token, withBody: true),
        body: jsonEncode(body ?? {}),
      ),
    );
  }

  Future<dynamic> put(
    String path, {
    String? token,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
  }) async {
    return _send(
      () => _client.put(
        _buildUri(path, queryParams),
        headers: _buildHeaders(token: token, withBody: true),
        body: jsonEncode(body ?? {}),
      ),
    );
  }

  Future<dynamic> patch(
    String path, {
    String? token,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
  }) async {
    return _send(
      () => _client.patch(
        _buildUri(path, queryParams),
        headers: _buildHeaders(token: token, withBody: true),
        body: jsonEncode(body ?? {}),
      ),
    );
  }

  Future<dynamic> delete(
    String path, {
    String? token,
    Map<String, dynamic>? queryParams,
  }) async {
    return _send(
      () => _client.delete(
        _buildUri(path, queryParams),
        headers: _buildHeaders(token: token),
      ),
    );
  }

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(const Duration(seconds: 20));
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    } on HttpException {
      throw const NetworkException();
    } on FormatException {
      throw const NetworkException('Format respons dari server tidak valid.');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : null;

    if (statusCode >= 200 && statusCode < 300) {
      return decoded;
    }

    final serverMessage = _extractMessage(decoded);

    switch (statusCode) {
      case 400:
      case 422:
        throw BadRequestException(serverMessage ?? 'Permintaan tidak valid.');
      case 401:
      case 403:
        throw UnauthorizedException(
          serverMessage ?? 'Sesi Anda telah berakhir. Silakan login kembali.',
        );
      case 404:
        throw NotFoundException(serverMessage ?? 'Data tidak ditemukan.');
      case >= 500:
        throw ServerException(
          serverMessage ?? 'Terjadi kesalahan pada server.',
        );
      default:
        throw UnknownApiException(
          serverMessage ?? 'Terjadi kesalahan tidak terduga.',
          statusCode,
        );
    }
  }

  String? _extractMessage(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final msg = decoded['message'] ?? decoded['error'];
      if (msg is String) return msg;
    }
    return null;
  }

  void dispose() {
    _client.close();
  }
}
