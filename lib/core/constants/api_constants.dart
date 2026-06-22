/// Konstanta terkait konfigurasi API.
///
/// PENTING: x-api-key TIDAK di-hardcode di sini. Nilainya diambil saat
/// runtime lewat `--dart-define=API_KEY=xxx` agar key tidak ikut masuk
/// ke version control (lihat README bagian "Cara Menjalankan Project").
///
/// Contoh menjalankan app:
/// flutter run --dart-define=API_KEY=isi_api_key_anda
class ApiConstants {
  ApiConstants._();

  /// Base URL resmi restful-api.dev (versi authenticated).
  static const String baseUrl = 'https://api.restful-api.dev';

  /// API key diambil dari environment saat build/run.
  /// Jika kosong, [ApiClient] akan melempar [ConfigurationException]
  /// supaya error-nya jelas sejak awal, bukan baru gagal saat call API.
  static const String apiKey = String.fromEnvironment('API_KEY');

  /// Default durasi token (detik) jika server tidak mengembalikan expiresIn.
  static const int defaultTokenExpirySeconds = 3600;

  /// Prefix nama collection per user. Nama lengkap collection akan
  /// dibentuk oleh `CollectionNameHelper` dari prefix ini + identifier user.
  static const String taskCollectionPrefix = 'tasks_';
}