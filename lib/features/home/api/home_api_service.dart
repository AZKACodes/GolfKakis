import '../../foundation/network/network.dart';

class HomeApiService {
  HomeApiService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<dynamic> getHello() {
    return _apiClient.getJson('/hello');
  }

  Future<dynamic> getUpcoming() {
    return _apiClient.getJson('/upcoming');
  }

  Future<dynamic> getSmartRebook() {
    return _apiClient.getJson('/home/smart-rebook');
  }

  Future<dynamic> getHotDeals() {
    return _apiClient.getJson('/home/hot-deals');
  }
}
