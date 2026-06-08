import 'package:golf_kakis/features/foundation/model/stay_play_item.dart';
import 'package:golf_kakis/features/foundation/network/network.dart';
import 'package:golf_kakis/features/home/api/home_api_service.dart';

import 'stay_play_repository.dart';

class StayPlayRepositoryImpl implements StayPlayRepository {
  StayPlayRepositoryImpl({ApiClient? apiClient, HomeApiService? apiService})
    : _apiService = apiService ?? HomeApiService(apiClient: apiClient);

  final HomeApiService _apiService;

  @override
  Future<List<StayPlayItem>> onFetchStayPlay() async {
    final response = await _apiService.getStayPlay();
    return _parseStayPlay(response);
  }

  List<StayPlayItem> _parseStayPlay(dynamic response) {
    final items = _extractList(response, const <String>[
      'data',
      'items',
      'stayPlay',
      'stay_play',
      'packages',
    ]);

    return items
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => StayPlayItem(
            id:
                item['id']?.toString() ??
                item['stay_play_id']?.toString() ??
                item['stayPlayId']?.toString() ??
                '',
            title:
                item['title']?.toString() ??
                item['name']?.toString() ??
                item['package_name']?.toString() ??
                '',
            description:
                item['description']?.toString() ??
                item['subtitle']?.toString() ??
                '',
            price:
                _parseNum(item['price']) ??
                _parseNum(item['amount']) ??
                _parseNum(item['starting_price']) ??
                0,
            currency:
                item['currency']?.toString() ??
                item['currency_code']?.toString() ??
                item['currencyCode']?.toString() ??
                'MYR',
            location:
                item['location']?.toString() ??
                item['address']?.toString() ??
                item['venue']?.toString(),
            imageUrl:
                item['image_url']?.toString() ??
                item['imageUrl']?.toString() ??
                item['cover_photo_url']?.toString() ??
                item['coverPhotoUrl']?.toString(),
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

  num? _parseNum(dynamic value) {
    if (value is num) {
      return value;
    }
    return num.tryParse(value?.toString() ?? '');
  }
}
