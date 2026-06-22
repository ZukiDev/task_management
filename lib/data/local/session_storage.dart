import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class SessionStorage {
  static const _keyToken = 'auth_token';
  static const _keyTokenType = 'auth_token_type';
  static const _keyExpiresAt = 'auth_expires_at';
  static const _keyUser = 'auth_user';
  static const _keyCollectionName = 'task_collection_name';

  Future<void> saveSession({
    required String token,
    required String tokenType,
    required DateTime expiresAt,
    required UserModel user,
    required String collectionName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyTokenType, tokenType);
    await prefs.setString(_keyExpiresAt, expiresAt.toIso8601String());
    await prefs.setString(_keyUser, jsonEncode(user.toLocalJson()));
    await prefs.setString(_keyCollectionName, collectionName);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  Future<String?> getCollectionName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCollectionName);
  }

  Future<DateTime?> getExpiresAt() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyExpiresAt);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  Future<bool> hasValidSession() async {
    final token = await getToken();
    final expiresAt = await getExpiresAt();
    if (token == null || token.isEmpty || expiresAt == null) return false;
    return DateTime.now().isBefore(expiresAt);
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUser);
    if (raw == null) return null;
    return UserModel.fromLocalJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> updateStoredUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user.toLocalJson()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyTokenType);
    await prefs.remove(_keyExpiresAt);
    await prefs.remove(_keyUser);
    await prefs.remove(_keyCollectionName);
  }
}
