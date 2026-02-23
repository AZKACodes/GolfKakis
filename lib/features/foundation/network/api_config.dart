class ApiConfig {
  ApiConfig._();

  static const String _defaultBaseUrl = 'https://golfergo-api.onrender.com';

  /// Override with: --dart-define=API_BASE_URL=https://your-api.com
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );
}
