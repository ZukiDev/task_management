import 'dart:convert';
import '../constants/api_constants.dart';

/// Mengubah email user menjadi nama collection yang aman dipakai sebagai
/// path segment URL (tidak boleh ada '@', '.', spasi, dsb).
///
/// Kenapa perlu: restful-api.dev (authenticated) menyimpan data dalam
/// "collection" yang sifatnya global per API key — bukan otomatis per user.
/// Supaya task milik user A tidak tercampur dengan user B, setiap user
/// mendapat nama collection unik hasil derivasi dari emailnya.
///
/// Contoh: "budi@gmail.com" -> "tasks_yndpqozaqgmymc"
class CollectionNameHelper {
  CollectionNameHelper._();

  static String fromEmail(String email) {
    final normalized = email.trim().toLowerCase();
    final bytes = utf8.encode(normalized);
    // base64url tanpa padding agar hasilnya aman untuk URL path.
    final encoded = base64Url.encode(bytes).replaceAll('=', '').toLowerCase();
    return '${ApiConstants.taskCollectionPrefix}$encoded';
  }
}
