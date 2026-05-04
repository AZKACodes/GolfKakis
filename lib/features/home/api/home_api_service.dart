import '../../foundation/network/network.dart';
import 'weather_api_service.dart';

class HomeApiService {
  HomeApiService({ApiClient? apiClient, WeatherApiService? weatherApiService})
    : _apiClient = apiClient ?? ApiClient(),
      _weatherApiService = weatherApiService ?? WeatherApiService();

  final ApiClient _apiClient;
  final WeatherApiService _weatherApiService;

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

  Future<dynamic> getHomeUserDetails({required String accessToken}) {
    return _apiClient.getJson(
      '/home/overview/user-details',
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
    );
  }

  Future<dynamic> getAdvertisementList() {
    return _apiClient.getJson('/home/overview/advertisements');
  }

  Future<dynamic> getDealsList() {
    return _apiClient.getJson('/home/overview/deals');
  }

  Future<dynamic> getKinraraWeather() {
    return _weatherApiService.getKinraraWeather();
  }
}
