class ApiException implements Exception {
  ApiException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() {
    if (statusCode == null) {
      return 'ApiException(message: $message)';
    }
    return 'ApiException(statusCode: $statusCode, message: $message)';
  }
}
