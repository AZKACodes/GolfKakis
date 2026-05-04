import '../../../booking/api/booking_api_service.dart';
import '../../../foundation/model/booking/golf_club_model.dart';
import '../../../foundation/model/home/home_hot_deal_item.dart';
import '../../../foundation/model/home/home_quick_book_item.dart';
import '../../../foundation/model/home/home_smart_rebook_item.dart';
import '../../../foundation/model/home/home_weather_summary.dart';
import '../../../foundation/network/network.dart';
import '../../api/home_api_service.dart';
import 'home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({
    ApiClient? apiClient,
    HomeApiService? apiService,
    BookingApiService? bookingApiService,
  }) : _apiService = apiService ?? HomeApiService(apiClient: apiClient),
       _bookingApiService =
           bookingApiService ?? BookingApiService(apiClient: apiClient);

  final HomeApiService _apiService;
  final BookingApiService _bookingApiService;

  @override
  Future<String> onFetchWelcomeMessage() async {
    final response = await _apiService.getHello();

    if (response is String) {
      return _sanitizeWelcomeMessage(response);
    }

    if (response is Map<String, dynamic>) {
      final dynamic message =
          response['message'] ?? response['hello'] ?? response['greeting'];
      if (message is String && message.trim().isNotEmpty) {
        return _sanitizeWelcomeMessage(message);
      }
    }

    return '';
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
  Future<List<HomeQuickBookItem>> onFetchQuickBookItems() async {
    try {
      final clubListResponse = await _bookingApiService.onFetchGolfClubList();
      final clubs = _parseGolfClubList(clubListResponse);
      if (clubs.isEmpty) {
        return const <HomeQuickBookItem>[];
      }

      final seedClub = clubs.first;
      final quickBookResponse = await _bookingApiService.onQuickBook(
        golfClubSlug: seedClub.slug,
        maxResults: 3,
        searchDays: 7,
      );

      return _parseQuickBookItems(quickBookResponse);
    } catch (_) {
      return const <HomeQuickBookItem>[];
    }
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

  List<HomeQuickBookItem> _parseQuickBookItems(dynamic response) {
    if (response is! Map<String, dynamic>) {
      return const <HomeQuickBookItem>[];
    }

    final recommendation = _asMap(response['recommendation']);
    final alternatives = response['alternatives'];
    final items = <HomeQuickBookItem>[];

    final recommendationItem = _toQuickBookItem(
      recommendation,
      badge: 'Recommended',
    );
    if (recommendationItem != null) {
      items.add(recommendationItem);
    }

    if (alternatives is List) {
      for (final alternative in alternatives) {
        final item = _toQuickBookItem(
          _asMap(alternative),
          badge: 'Alternative',
        );
        if (item != null) {
          items.add(item);
        }
      }
    }

    return items;
  }

  HomeQuickBookItem? _toQuickBookItem(
    Map<String, dynamic>? payload, {
    required String badge,
  }) {
    if (payload == null) {
      return null;
    }

    final club = _asMap(payload['club']);
    final nextSlot = _asMap(payload['nextSlot']);
    if (club == null || nextSlot == null) {
      return null;
    }

    final slug = club['slug']?.toString() ?? '';
    final clubName = club['name']?.toString() ?? '';
    final bookingDate = nextSlot['bookingDate']?.toString() ?? '';
    final teeTime = nextSlot['teeTimeSlot']?.toString().toUpperCase() ?? '';
    final remainingCapacity = _parseInt(nextSlot['remainingPlayerCapacity']);
    final fromPrice = nextSlot['fromPrice'];
    final currency = nextSlot['currency']?.toString() ?? 'MYR';

    if (slug.trim().isEmpty || clubName.trim().isEmpty) {
      return null;
    }

    final subtitleParts = <String>[
      if (bookingDate.trim().isNotEmpty) bookingDate,
      if (teeTime.trim().isNotEmpty) teeTime,
      if (remainingCapacity != null) '$remainingCapacity spots',
    ];

    return HomeQuickBookItem(
      clubSlug: slug,
      title: clubName,
      subtitle: subtitleParts.join(' • '),
      priceLabel: fromPrice == null
          ? 'Check rates'
          : 'From $currency ${fromPrice.toString()}',
      badge: badge,
    );
  }

  List<GolfClubModel> _parseGolfClubList(dynamic rawResponse) {
    if (rawResponse is List) {
      return rawResponse
          .whereType<Map<String, dynamic>>()
          .map(GolfClubModel.fromJson)
          .where((club) => club.slug.isNotEmpty)
          .toList();
    }

    if (rawResponse is Map<String, dynamic>) {
      final dynamic nestedList =
          rawResponse['data'] ??
          rawResponse['items'] ??
          rawResponse['clubs'] ??
          rawResponse['golfClubs'];
      return _parseGolfClubList(nestedList);
    }

    return const <GolfClubModel>[];
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

  String _sanitizeWelcomeMessage(String value) {
    final cleaned = value
        .replaceAll(RegExp('hello world', caseSensitive: false), '')
        .trim();
    return cleaned;
  }
}

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
