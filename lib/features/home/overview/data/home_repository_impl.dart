import '../../../foundation/model/home/home_advertisement_item.dart';
import '../../../foundation/model/home/home_hot_deal_item.dart';
import '../../../foundation/model/home/home_smart_rebook_item.dart';
import '../../../foundation/model/home/home_user_details_item.dart';
import '../../../foundation/model/home/home_weather_summary.dart';
import '../../../foundation/network/network.dart';
import '../../api/home_api_service.dart';
import '../../../profile/api/profile_api_service.dart';
import 'home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({
    ApiClient? apiClient,
    HomeApiService? apiService,
    ProfileApiService? profileApiService,
  }) : _apiService = apiService ?? HomeApiService(apiClient: apiClient),
       _profileApiService =
           profileApiService ?? ProfileApiService(apiClient: apiClient);

  final HomeApiService _apiService;
  final ProfileApiService _profileApiService;

  @override
  Future<HomeUserDetailsItem?> onFetchUserDetails({
    required String accessToken,
  }) async {
    try {
      final response = await _apiService.getHomeUserDetails(
        accessToken: accessToken,
      );
      final parsed = _parseUserDetailsResponse(response);
      if (parsed != null) {
        return parsed;
      }
    } catch (_) {
      // Temporary fallback while the dedicated home overview endpoint is pending.
    }

    try {
      final authUser = await _profileApiService.onFetchUserDetails(
        accessToken: accessToken,
      );
      if (authUser.name.trim().isEmpty) {
        return null;
      }
      return HomeUserDetailsItem(displayName: authUser.name, avatarIndex: 0);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<HomeAdvertisementItem>> onFetchAdvertisementList() async {
    try {
      final response = await _apiService.getAdvertisementList();
      final parsedItems = _parseAdvertisementItems(response);
      if (parsedItems.isNotEmpty) {
        return parsedItems;
      }
    } catch (_) {
      // Fall back to seeded advertisement content until backend wiring is ready.
    }
    return _fallbackAdvertisements;
  }

  @override
  Future<List<HomeHotDealItem>> onFetchDealsList() async {
    try {
      final response = await _apiService.getDealsList();
      final parsedItems = _parseHotDealItems(response);
      if (parsedItems.isNotEmpty) {
        return parsedItems;
      }
    } catch (_) {
      // Fall back to seeded deals until backend wiring is ready.
    }
    return _fallbackHotDeals;
  }

  @override
  Future<List<HomeSmartRebookItem>> onFetchSmartRebookItems() async {
    final response = await _apiService.getSmartRebook();
    return _parseSmartRebookItems(response);
  }

  @override
  Future<List<HomeHotDealItem>> onFetchHotDeals() async {
    try {
      final response = await _apiService.getHotDeals();
      final parsedItems = _parseHotDealItems(response);
      if (parsedItems.isNotEmpty) {
        return parsedItems;
      }
    } catch (_) {
      // Fall back to seeded club deals for demo-friendly home content.
    }
    return _fallbackHotDeals;
  }

  @override
  Future<HomeWeatherSummary?> onFetchCurrentWeather() async {
    try {
      final response = await _apiService.getKinraraWeather();
      if (response is! Map<String, dynamic>) {
        return null;
      }

      final current = response['current'];
      final daily = response['daily'];
      if (current is! Map<String, dynamic> || daily is! Map<String, dynamic>) {
        return null;
      }

      final currentTemperature = _roundToInt(current['temperature_2m']);
      final windSpeed = _roundToInt(current['wind_speed_10m']);
      final weatherCode = _roundToInt(current['weather_code']);
      final highTemperature = _extractFirstRoundedValue(
        daily['temperature_2m_max'],
      );
      final lowTemperature = _extractFirstRoundedValue(
        daily['temperature_2m_min'],
      );

      if (currentTemperature == null ||
          windSpeed == null ||
          weatherCode == null ||
          highTemperature == null ||
          lowTemperature == null) {
        return null;
      }

      final descriptor = _weatherDescriptor(weatherCode);
      return HomeWeatherSummary(
        temperatureCelsius: currentTemperature,
        highCelsius: highTemperature,
        lowCelsius: lowTemperature,
        windSpeedKph: windSpeed,
        weatherLabel: descriptor.label,
        weatherIcon: descriptor.icon,
      );
    } catch (_) {
      return null;
    }
  }

  List<HomeAdvertisementItem> _parseAdvertisementItems(dynamic response) {
    final items = _extractList(response, const <String>[
      'data',
      'items',
      'advertisements',
      'ads',
    ]);

    return items
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => HomeAdvertisementItem(
            tag: item['tag']?.toString() ?? item['label']?.toString() ?? 'Ad',
            title: item['title']?.toString() ?? '',
            subtitle:
                item['subtitle']?.toString() ??
                item['description']?.toString() ??
                '',
          ),
        )
        .where((item) => item.title.trim().isNotEmpty)
        .toList();
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

  HomeUserDetailsItem? _parseUserDetailsResponse(dynamic response) {
    if (response is! Map<String, dynamic>) {
      return null;
    }

    final payload =
        _asMap(response['data']) ??
        _asMap(response['user']) ??
        response;

    final displayName =
        payload['displayName']?.toString() ??
        payload['name']?.toString() ??
        payload['fullName']?.toString() ??
        '';
    if (displayName.trim().isEmpty) {
      return null;
    }

    return HomeUserDetailsItem(
      displayName: displayName,
      avatarIndex: _parseInt(payload['avatarIndex']) ?? 0,
    );
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

  int? _extractFirstRoundedValue(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return _roundToInt(value.first);
    }
    return null;
  }

  int? _roundToInt(dynamic value) {
    if (value is num) {
      return value.round();
    }
    return null;
  }

  int? _parseInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    return value is Map<String, dynamic> ? value : null;
  }

  ({String label, String icon}) _weatherDescriptor(int code) {
    switch (code) {
      case 0:
        return (label: 'Clear sky', icon: 'Clear');
      case 1:
      case 2:
      case 3:
        return (label: 'Partly cloudy', icon: 'Clouds');
      case 45:
      case 48:
        return (label: 'Misty', icon: 'Mist');
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
      case 61:
      case 63:
      case 65:
      case 80:
      case 81:
      case 82:
        return (label: 'Rain moving through', icon: 'Rain');
      case 66:
      case 67:
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return (label: 'Cold and wet', icon: 'Storm');
      case 95:
      case 96:
      case 99:
        return (label: 'Storm watch', icon: 'Storm');
      default:
        return (label: 'Course conditions pending', icon: 'Weather');
    }
  }
}

const List<HomeAdvertisementItem> _fallbackAdvertisements = [
  HomeAdvertisementItem(
    tag: 'Club Notice',
    title: 'Weekend tee sheet opens earlier this Friday',
    subtitle: 'Members can secure preferred morning slots from 6:00 PM onwards.',
  ),
  HomeAdvertisementItem(
    tag: 'Course Update',
    title: 'Kinrara greens maintenance scheduled tomorrow',
    subtitle: 'Expect smoother front-nine play with light maintenance on selected holes.',
  ),
  HomeAdvertisementItem(
    tag: 'Promo',
    title: 'Early-bird weekday rounds now from MYR 39',
    subtitle: 'Book selected morning sessions and lock in lower rates before noon.',
  ),
];

const List<HomeHotDealItem> _fallbackHotDeals = [
  HomeHotDealItem(
    title: 'Kinrara Golf Club',
    subtitle: 'Morning slots from 7:20 AM • Bandar Kinrara, Puchong',
    priceLabel: 'From MYR 39',
    badge: 'Best Value',
  ),
  HomeHotDealItem(
    title: 'Saujana Golf & Country Club',
    subtitle: 'Peak play from 8:00 AM • Shah Alam, Selangor',
    priceLabel: 'From MYR 52',
    badge: 'Popular',
  ),
  HomeHotDealItem(
    title: 'The Mines Resort & Golf Club',
    subtitle: 'Early access from 7:40 AM • Serdang, Selangor',
    priceLabel: 'From MYR 58',
    badge: 'Premium',
  ),
];
