import '../../../foundation/network/network.dart';
import '../../api/home_api_service.dart';

abstract class HomeRepository {
  Future<String> fetchWelcomeMessage();
}

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({ApiClient? apiClient, HomeApiService? apiService})
    : _apiService =
          apiService ?? HomeApiService(apiClient: apiClient ?? ApiClient());

  final HomeApiService _apiService;

  @override
  Future<String> fetchWelcomeMessage() async {
    try {
      final response = await _apiService.getHello();

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
