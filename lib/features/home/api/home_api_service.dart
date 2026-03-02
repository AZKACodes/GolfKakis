import '../../foundation/network/network.dart';

class HomeApiService {
  HomeApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<dynamic> getHello() {
    return _apiClient.getJson('/hello');
  }

  Future<dynamic> getUpcoming() {
    return _apiClient.getJson('/upcoming');
  }
}
