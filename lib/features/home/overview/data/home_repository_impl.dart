import '../../../foundation/model/home_announcement_item.dart';
import '../../../foundation/model/home_hot_deal_item.dart';
import '../../../foundation/model/home_smart_rebook_item.dart';
import '../../../foundation/model/home_user_details_item.dart';
import '../../../foundation/model/home_weather_summary.dart';
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
      final authUser = await _profileApiService.onFetchUserDetails(
        accessToken: accessToken,
      );
      if (authUser.name.trim().isNotEmpty) {
        return HomeUserDetailsItem(
          displayName: authUser.name,
          avatarIndex: 0,
          avatarUrl: authUser.avatarUrl,
        );
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  @override
  Future<List<HomeAnnouncementItem>> onFetchAnnouncementList() async {
    try {
      final response = await _apiService.getAnnouncementList();
      final parsedItems = _parseAnnouncementItems(response);
      if (parsedItems.isNotEmpty) {
        return parsedItems;
      }
    } catch (_) {
      // Fall back to seeded announcement content until backend wiring is ready.
    }
    return _fallbackAnnouncements;
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

  List<HomeAnnouncementItem> _parseAnnouncementItems(dynamic response) {
    final items = _extractList(response, const <String>[
      'data',
      'items',
      'announcements',
      'advertisements',
      'ads',
    ]);

    return items
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => HomeAnnouncementItem(
            announcementId:
                item['announcement_id']?.toString() ??
                item['announcementId']?.toString() ??
                '',
            announcementType:
                item['announcement_type']?.toString() ??
                item['announcementType']?.toString() ??
                item['tag']?.toString() ??
                item['label']?.toString() ??
                'Announcement',
            title: item['title']?.toString() ?? '',
            subtitle:
                item['subtitle']?.toString() ??
                item['description']?.toString() ??
                '',
            imageUrl:
                item['image_url']?.toString() ?? item['imageUrl']?.toString(),
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

const List<HomeAnnouncementItem> _fallbackAnnouncements = [
  HomeAnnouncementItem(
    announcementId: 'announcement-club-notice',
    announcementType: 'Club Notice',
    title: 'Weekend tee sheet opens earlier this Friday',
    subtitle:
        'Members can secure preferred morning slots from 6:00 PM onwards.',
  ),
  HomeAnnouncementItem(
    announcementId: 'announcement-course-update',
    announcementType: 'Course Update',
    title: 'Kinrara greens maintenance scheduled tomorrow',
    subtitle:
        'Expect smoother front-nine play with light maintenance on selected holes.',
  ),
  HomeAnnouncementItem(
    announcementId: 'announcement-promo',
    announcementType: 'Promo',
    title: 'Early-bird weekday rounds now from MYR 39',
    subtitle:
        'Book selected morning sessions and lock in lower rates before noon.',
  ),
];

const List<HomeHotDealItem> _fallbackHotDeals = [
  HomeHotDealItem(
    dealId: 'deal-kinrara-morning',
    slotId: 'slot-kinrara-0720',
    title: 'Kinrara Golf Club',
    description: 'Morning slots from 7:20 AM • Bandar Kinrara, Puchong',
    price: 61,
    discountedPrice: 39,
    currency: 'MYR',
    golfClubSlug: 'kinrara-golf-club',
    slotDate: '2026-05-06',
    slotTime: '07:20',
    noOfHoles: 18,
  ),
  HomeHotDealItem(
    dealId: 'deal-saujana-peak',
    slotId: 'slot-saujana-0800',
    title: 'Saujana Golf & Country Club',
    description: 'Peak play from 8:00 AM • Shah Alam, Selangor',
    price: 74,
    discountedPrice: 52,
    currency: 'MYR',
    golfClubSlug: 'saujana-golf-country-club',
    slotDate: '2026-05-06',
    slotTime: '08:00',
    noOfHoles: 18,
  ),
  HomeHotDealItem(
    dealId: 'deal-mines-early',
    slotId: 'slot-mines-0740',
    title: 'The Mines Resort & Golf Club',
    description: 'Early access from 7:40 AM • Serdang, Selangor',
    price: 82,
    discountedPrice: 58,
    currency: 'MYR',
    golfClubSlug: 'the-mines-resort-golf-club',
    slotDate: '2026-05-06',
    slotTime: '07:40',
    noOfHoles: 18,
  ),
];
