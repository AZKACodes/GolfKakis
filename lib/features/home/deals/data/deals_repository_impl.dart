import 'package:golf_kakis/features/foundation/model/home_hot_deal_item.dart';
import 'package:golf_kakis/features/foundation/network/network.dart';
import 'package:golf_kakis/features/home/api/home_api_service.dart';

import 'deals_repository.dart';

class DealsRepositoryImpl implements DealsRepository {
  DealsRepositoryImpl({ApiClient? apiClient, HomeApiService? apiService})
    : _apiService = apiService ?? HomeApiService(apiClient: apiClient);

  final HomeApiService _apiService;

  @override
  Future<List<HomeHotDealItem>> onFetchDealsList() async {
    final response = await _apiService.getDealsList();
    return _parseDeals(response);
  }

  List<HomeHotDealItem> _parseDeals(dynamic response) {
    final items = _extractList(response, const <String>['data', 'items']);

    return items
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => HomeHotDealItem(
            dealId:
                item['deal_id']?.toString() ?? item['dealId']?.toString() ?? '',
            slotId:
                item['slot_id']?.toString() ?? item['slotId']?.toString() ?? '',
            title: item['title']?.toString() ?? '',
            description:
                item['description']?.toString() ??
                item['subtitle']?.toString() ??
                '',
            price: _parseNum(item['price']) ?? 0,
            discountedPrice:
                _parseNum(item['discounted_price']) ??
                _parseNum(item['discountedPrice']) ??
                _parseNum(item['price']) ??
                0,
            currency:
                item['currency']?.toString() ??
                item['currency_code']?.toString() ??
                item['currencyCode']?.toString() ??
                'MYR',
            golfClubSlug:
                item['golf_club_slug']?.toString() ??
                item['golfClubSlug']?.toString() ??
                '',
            slotDate:
                item['slot_date']?.toString() ??
                item['slotDate']?.toString() ??
                '',
            slotTime:
                item['slot_time']?.toString() ??
                item['slotTime']?.toString() ??
                '',
            noOfHoles:
                _parseInt(item['no_of_holes']) ??
                _parseInt(item['noOfHoles']) ??
                18,
            imageUrl:
                item['image_url']?.toString() ?? item['imageUrl']?.toString(),
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

  int? _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  num? _parseNum(dynamic value) {
    if (value is num) {
      return value;
    }
    return num.tryParse(value?.toString() ?? '');
  }
}
