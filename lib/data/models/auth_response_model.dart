import 'user_model.dart';

/// Representasi response dari endpoint `/login` dan `/register`.
/// Bentuk response keduanya identik:
/// { token, tokenType, expiresIn, user: { id, email, name } }
class AuthResponseModel {
  final String token;
  final String tokenType;
  final int expiresIn;
  final UserModel user;

  const AuthResponseModel({
    required this.token,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponseModel.fromApiJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token']?.toString() ?? '',
      tokenType: json['tokenType']?.toString() ?? 'Bearer',
      expiresIn: json['expiresIn'] is int
          ? json['expiresIn'] as int
          : int.tryParse(json['expiresIn']?.toString() ?? '') ?? 3600,
      user: UserModel.fromApiJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }

  /// Waktu absolut kapan token akan expired, dihitung dari sekarang.
  DateTime get expiresAt => DateTime.now().add(Duration(seconds: expiresIn));
}
