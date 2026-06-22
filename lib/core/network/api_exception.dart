library;

abstract class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException([
    super.message = 'Tidak ada koneksi internet. Periksa jaringan Anda.',
  ]);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([
    super.message = 'Sesi Anda telah berakhir. Silakan login kembali.',
  ]);
}

class NotFoundException extends ApiException {
  const NotFoundException([super.message = 'Data tidak ditemukan.']);
}

class BadRequestException extends ApiException {
  const BadRequestException([super.message = 'Permintaan tidak valid.']);
}

class ServerException extends ApiException {
  const ServerException([
    super.message = 'Terjadi kesalahan pada server. Coba lagi nanti.',
  ]);
}

class UnknownApiException extends ApiException {
  final int? statusCode;
  const UnknownApiException(super.message, [this.statusCode]);
}

class ConfigurationException extends ApiException {
  const ConfigurationException([
    super.message =
        'API key belum diset. Jalankan app dengan --dart-define=API_KEY=...',
  ]);
}
