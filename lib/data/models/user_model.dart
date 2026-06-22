/// Model User di sisi aplikasi.
///
/// [name] dan [localPhotoPath] bersifat LOKAL — restful-api.dev tidak
/// punya endpoint untuk update profile user (hanya /register dan /login
/// yang mengembalikan user dasar: id, email, name dari saat registrasi).
/// Perubahan nama/foto sesudah register hanya tersimpan di
/// shared_preferences device ini saja. Lihat README bagian "Known
/// Limitations" untuk detail & alasan keputusan ini.
class UserModel {
  final String id;
  final String email;
  final String name;
  final String? localPhotoPath;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.localPhotoPath,
  });

  factory UserModel.fromApiJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  UserModel copyWith({String? name, String? localPhotoPath}) {
    return UserModel(
      id: id,
      email: email,
      name: name ?? this.name,
      localPhotoPath: localPhotoPath ?? this.localPhotoPath,
    );
  }

  Map<String, dynamic> toLocalJson() => {
    'id': id,
    'email': email,
    'name': name,
    'localPhotoPath': localPhotoPath,
  };

  factory UserModel.fromLocalJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      localPhotoPath: json['localPhotoPath']?.toString(),
    );
  }
}
