import 'dart:convert';
import '../constants/api_constants.dart';

class CollectionNameHelper {
  CollectionNameHelper._();

  static String fromEmail(String email) {
    final normalized = email.trim().toLowerCase();
    final bytes = utf8.encode(normalized);
    final encoded = base64Url.encode(bytes).replaceAll('=', '').toLowerCase();
    return '${ApiConstants.taskCollectionPrefix}$encoded';
  }
}
