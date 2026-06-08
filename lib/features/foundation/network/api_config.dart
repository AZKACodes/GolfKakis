enum AppEnvironment {
  staging,
  production;

  static AppEnvironment fromName(String value) {
    switch (value.trim().toLowerCase()) {
      case 'prod':
      case 'production':
        return AppEnvironment.production;
      case 'dev':
      case 'staging':
      default:
        return AppEnvironment.staging;
    }
  }
}

class ApiConfig {
  ApiConfig._();

  static const String stagingBaseUrl = 'https://golfergo-api.onrender.com';
  static const String _appEnvironmentName = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'staging',
  );
  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const String _productionBaseUrl = String.fromEnvironment(
    'PRODUCTION_API_BASE_URL',
    defaultValue: '',
  );

  static AppEnvironment get environment =>
      AppEnvironment.fromName(_appEnvironmentName);

  static bool get isProduction => environment == AppEnvironment.production;

  /// Override with: --dart-define=API_BASE_URL=https://your-api.com
  static String get baseUrl {
    final override = _apiBaseUrlOverride.trim();
    if (override.isNotEmpty) {
      return _normalizeBaseUrl(override);
    }

    if (isProduction) {
      final productionBaseUrl = _productionBaseUrl.trim();
      if (productionBaseUrl.isNotEmpty) {
        return _normalizeBaseUrl(productionBaseUrl);
      }

      throw StateError(
        'Production API base URL is not configured. Build with '
        '--dart-define=API_BASE_URL=https://your-production-api.example.com',
      );
    }

    return stagingBaseUrl;
  }

  static String _normalizeBaseUrl(String value) {
    var normalized = value.trim();
    while (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }
}
