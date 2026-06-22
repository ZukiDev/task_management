class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.restful-api.dev';

  static const String apiKey = String.fromEnvironment('API_KEY');

  static const int defaultTokenExpirySeconds = 3600;

  static const String taskCollectionPrefix = 'tasks_';
}
