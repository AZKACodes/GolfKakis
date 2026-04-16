import '../../../foundation/network/network.dart';
import '../../api/home_api_service.dart';
import 'home_overview_models.dart';

abstract class HomeRepository {
  Future<String> fetchWelcomeMessage();
  Future<List<HomeSmartRebookItem>> fetchSmartRebookItems();
  Future<List<HomeHotDealItem>> fetchHotDeals();
}

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({ApiClient? apiClient, HomeApiService? apiService})
    : _apiService = apiService ?? HomeApiService(apiClient: apiClient);

  final HomeApiService _apiService;

  @override
  Future<String> fetchWelcomeMessage() async {
    final response = await _apiService.getHello();

    if (response is String) {
      return response;
    }

    if (response is Map<String, dynamic>) {
      final dynamic message =
          response['message'] ?? response['hello'] ?? response['greeting'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    return '';
  }

  @override
  Future<List<HomeSmartRebookItem>> fetchSmartRebookItems() async {
    final response = await _apiService.getSmartRebook();
    return _parseSmartRebookItems(response);
  }

  @override
  Future<List<HomeHotDealItem>> fetchHotDeals() async {
    final response = await _apiService.getHotDeals();
    return _parseHotDealItems(response);
  }

  List<HomeSmartRebookItem> _parseSmartRebookItems(dynamic response) {
    final items = _extractList(response, const <String>['data', 'items']);

    return items
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => HomeSmartRebookItem(
            title:
                item['title']?.toString() ??
                item['golfClubName']?.toString() ??
                item['clubName']?.toString() ??
                '',
            subtitle:
                item['subtitle']?.toString() ??
                item['description']?.toString() ??
                item['lastPlayedLabel']?.toString() ??
                '',
            priceLabel:
                item['priceLabel']?.toString() ??
                item['price']?.toString() ??
                item['fromPriceLabel']?.toString() ??
                '',
          ),
        )
        .where((item) => item.title.trim().isNotEmpty)
        .toList();
  }

  List<HomeHotDealItem> _parseHotDealItems(dynamic response) {
    final items = _extractList(response, const <String>['data', 'items']);

    return items
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => HomeHotDealItem(
            title: item['title']?.toString() ?? '',
            subtitle:
                item['subtitle']?.toString() ??
                item['description']?.toString() ??
                '',
            priceLabel:
                item['priceLabel']?.toString() ??
                item['price']?.toString() ??
                '',
            badge: item['badge']?.toString() ?? '',
          ),
        )
        .where((item) => item.title.trim().isNotEmpty)
        .toList();
  }

  List<dynamic> _extractList(dynamic response, List<String> keys) {
    if (response is List) {
      return response;
    }

    if (response is Map<String, dynamic>) {
      for (final key in keys) {
        final value = response[key];
        if (value is List) {
          return value;
        }
      }
    }

    return const <dynamic>[];
  }
}
