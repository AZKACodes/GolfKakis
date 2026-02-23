import '../../../foundation/network/network.dart';

abstract class HomeRepository {
  Future<String> fetchWelcomeMessage();
}

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<String> fetchWelcomeMessage() async {
    try {
      final response = await _apiClient.getJson('/hello');

      if (response is Map<String, dynamic>) {
        final message = response['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
      }
    } catch (_) {
      // Keep a safe fallback so UI can still render if the endpoint is unavailable.
    }

    return 'Welcome to Home';
  }
}
