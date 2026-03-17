import '../../../foundation/network/network.dart';
import '../../api/home_api_service.dart';

abstract class HomeRepository {
  Future<String> fetchWelcomeMessage();
}

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({ApiClient? apiClient, HomeApiService? apiService});

  @override
  Future<String> fetchWelcomeMessage() async {
    return 'Welcome to GolfKakis';
  }
}
