/// Kumpulan exception khusus untuk error yang berasal dari network/API.
///
/// Tujuannya: layer presentation tidak perlu tahu soal status code HTTP
/// atau detail teknis http package. Mereka cukup tangkap salah satu
/// exception ini dan tampilkan pesan yang sesuai.
library;

/// Base class untuk semua error terkait API.
abstract class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

/// Tidak ada koneksi internet / request timeout / DNS gagal.
class NetworkException extends ApiException {
  const NetworkException([
    super.message = 'Tidak ada koneksi internet. Periksa jaringan Anda.',
  ]);
}

/// Token tidak ada, invalid, atau sudah expired (401).
class UnauthorizedException extends ApiException {
  const UnauthorizedException([
    super.message = 'Sesi Anda telah berakhir. Silakan login kembali.',
  ]);
}

/// Resource yang diminta tidak ditemukan (404).
class NotFoundException extends ApiException {
  const NotFoundException([super.message = 'Data tidak ditemukan.']);
}

/// Request tidak valid, biasanya body salah format (400/422).
class BadRequestException extends ApiException {
  const BadRequestException([super.message = 'Permintaan tidak valid.']);
}

/// Error dari sisi server (500+).
class ServerException extends ApiException {
  const ServerException([
    super.message = 'Terjadi kesalahan pada server. Coba lagi nanti.',
  ]);
}

/// Status code tidak terduga / kategori lain yang tidak ter-cover di atas.
class UnknownApiException extends ApiException {
  final int? statusCode;
  const UnknownApiException(super.message, [this.statusCode]);
}

/// API key kosong / belum diset lewat --dart-define.
class ConfigurationException extends ApiException {
  const ConfigurationException([
    super.message =
        'API key belum diset. Jalankan app dengan --dart-define=API_KEY=...',
  ]);
}
