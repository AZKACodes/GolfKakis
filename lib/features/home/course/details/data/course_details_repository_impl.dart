import 'package:golf_kakis/features/booking/api/booking_api_service.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';
import 'package:golf_kakis/features/foundation/util/string_util.dart';
import 'package:golf_kakis/features/home/api/weather_api_service.dart';

import 'course_details_repository.dart';
import 'local_course_display_content.dart';

class CourseDetailsRepositoryImpl implements CourseDetailsRepository {
  CourseDetailsRepositoryImpl({
    BookingApiService? bookingApiService,
    WeatherApiService? weatherApiService,
  }) : _bookingApiService = bookingApiService ?? BookingApiService(),
       _weatherApiService = weatherApiService ?? WeatherApiService();

  final BookingApiService _bookingApiService;
  final WeatherApiService _weatherApiService;

  @override
  Future<CourseHeaderDetailsData> onFetchCourseDetails({
    required String slug,
    GolfClubModel? initialClub,
  }) async {
    final detailResponse = await _bookingApiService.onFetchCourseDetails(
      slug: slug,
    );
    final club = _parseDetailedClub(detailResponse) ?? initialClub;
    if (club == null || club.slug.trim().isEmpty) {
      throw Exception('Missing golf club detail payload.');
    }

    final quickBookResponse = await _bookingApiService.onQuickBook(
      golfClubSlug: club.slug,
      maxResults: 3,
      searchDays: 7,
    );

    final recommendation = _extractRecommendation(quickBookResponse);
    return CourseHeaderDetailsData(
      club: club,
      distanceLabel: _distanceLabel(recommendation),
      openSlotsLabel: _availabilityLabel(recommendation),
      greenFeeLabel: _greenFeeLabel(recommendation),
      peakLabel: _peakLabel(recommendation),
      bestForLabel: _bestForLabel(quickBookResponse, recommendation),
      nextSlotLabel: _nextSlotLabel(recommendation),
      bookingDateLabel: _bookingDateLabel(recommendation),
    );
  }

  @override
  Future<CourseExtraDetailsData> onFetchCourseExtraDetails({
    required String slug,
    required GolfClubModel club,
  }) async {
    dynamic extraResponse;
    try {
      extraResponse = await _bookingApiService.onFetchCourseExtraDetails(
        slug: slug,
      );
    } catch (_) {
      extraResponse = null;
    }

    final kinraraContent = slug.trim().toLowerCase() == 'kinrara-golf-club'
        ? localCourseDisplayContent['kinrara-golf-club']
        : null;

    return CourseExtraDetailsData(
      description:
          kinraraContent?.summary ??
          _description(extraResponse, club, requestedSlug: slug),
      facilityLabels: kinraraContent?.facilities.isNotEmpty == true
          ? kinraraContent!.facilities
          : _facilityLabels(extraResponse, club, requestedSlug: slug),
      photoUrls: kinraraContent?.photoUrls.isNotEmpty == true
          ? kinraraContent!.photoUrls
          : _photoUrls(extraResponse),
    );
  }

  @override
  Future<CourseWeatherDetailsData> onFetchCourseWeather({
    required GolfClubModel club,
  }) async {
    final weather = await _fetchWeather(club);
    final weeklyForecast = await _fetchWeeklyForecast(club);
    return CourseWeatherDetailsData(
      weather: weather,
      weeklyForecast: weeklyForecast,
    );
  }

  GolfClubModel? _parseDetailedClub(dynamic response) {
    final map = _asMap(response);
    if (map == null) {
      return null;
    }

    final candidates = <dynamic>[
      map['data'],
      map['club'],
      map['item'],
      map['golfClub'],
      map,
    ];

    for (final candidate in candidates) {
      final nested = _asMap(candidate);
      if (nested == null) {
        continue;
      }

      final clubCandidate = _asMap(
        nested['club'] ?? nested['golfClub'] ?? nested['facility'],
      );

      if (clubCandidate != null) {
        final club = GolfClubModel.fromJson(clubCandidate);
        if (club.slug.isNotEmpty) {
          return club;
        }
      }

      final directClub = GolfClubModel.fromJson(nested);
      if (directClub.slug.isNotEmpty) {
        return directClub;
      }
    }

    return null;
  }

  Map<String, dynamic>? _extractRecommendation(dynamic response) {
    final map = _asMap(response);
    if (map == null) {
      return null;
    }

    return _asMap(map['recommendation']) ??
        _asMap(_asMap(map['data'])?['recommendation']);
  }

  Future<CourseWeatherSummary?> _fetchWeather(GolfClubModel club) async {
    if (club.latitude == null || club.longitude == null) {
      return null;
    }

    try {
      final response = await _weatherApiService.getWeather(
        latitude: club.latitude!,
        longitude: club.longitude!,
      );
      final current = _asMap(response['current']);
      final daily = _asMap(response['daily']);
      if (current == null || daily == null) {
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
      return CourseWeatherSummary(
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

  Future<List<CourseWeatherForecastItem>> _fetchWeeklyForecast(
    GolfClubModel club,
  ) async {
    if (club.latitude == null || club.longitude == null) {
      return const <CourseWeatherForecastItem>[];
    }

    try {
      final response = await _weatherApiService.getWeather(
        latitude: club.latitude!,
        longitude: club.longitude!,
      );
      final daily = _asMap(response['daily']);
      if (daily == null) {
        return const <CourseWeatherForecastItem>[];
      }

      final times = daily['time'];
      final weatherCodes = daily['weather_code'];
      final highs = daily['temperature_2m_max'];
      final lows = daily['temperature_2m_min'];

      if (times is! List || weatherCodes is! List || highs is! List || lows is! List) {
        return const <CourseWeatherForecastItem>[];
      }

      final count = <int>[
        times.length,
        weatherCodes.length,
        highs.length,
        lows.length,
      ].reduce((value, element) => value < element ? value : element);

      return List<CourseWeatherForecastItem>.generate(count, (index) {
        final weatherCode = _roundToInt(weatherCodes[index]) ?? 0;
        final descriptor = _weatherDescriptor(weatherCode);
        return CourseWeatherForecastItem(
          dayLabel: _dayLabel(times[index]?.toString() ?? ''),
          highCelsius: _roundToInt(highs[index]) ?? 0,
          lowCelsius: _roundToInt(lows[index]) ?? 0,
          weatherLabel: descriptor.label,
          weatherIcon: descriptor.icon,
        );
      });
    } catch (_) {
      return const <CourseWeatherForecastItem>[];
    }
  }

  String _distanceLabel(Map<String, dynamic>? recommendation) {
    final distance = _parseNullableDouble(recommendation?['distanceInKm']);
    if (distance == null) {
      return 'Nearby';
    }
    return '${distance.toStringAsFixed(distance >= 10 ? 0 : 2)} km';
  }

  String _availabilityLabel(Map<String, dynamic>? recommendation) {
    final nextSlot = _asMap(recommendation?['nextSlot']);
    final remainingCapacity = _parseNullableInt(
      nextSlot?['remainingPlayerCapacity'],
    );
    if (remainingCapacity == null) {
      return 'Check slots';
    }
    return '$remainingCapacity spots';
  }

  String _greenFeeLabel(Map<String, dynamic>? recommendation) {
    final nextSlot = _asMap(recommendation?['nextSlot']);
    final price = _parseNullableDouble(nextSlot?['fromPrice']);
    final currency = nextSlot?['currency']?.toString() ?? 'MYR';
    if (price == null) {
      return 'Check rates';
    }
    final normalized = price % 1 == 0
        ? price.toStringAsFixed(0)
        : price.toStringAsFixed(2);
    return 'From $currency $normalized';
  }

  String _peakLabel(Map<String, dynamic>? recommendation) {
    final nextSlot = _asMap(recommendation?['nextSlot']);
    final teeTime = nextSlot?['teeTimeSlot']?.toString() ?? '';
    if (teeTime.trim().isEmpty) {
      return 'Next available';
    }
    return teeTime.toUpperCase();
  }

  String _nextSlotLabel(Map<String, dynamic>? recommendation) {
    final nextSlot = _asMap(recommendation?['nextSlot']);
    final teeTime = nextSlot?['teeTimeSlot']?.toString() ?? '';
    if (teeTime.trim().isEmpty) {
      return '';
    }
    return teeTime.toUpperCase();
  }

  String _bookingDateLabel(Map<String, dynamic>? recommendation) {
    final nextSlot = _asMap(recommendation?['nextSlot']);
    final bookingDate = nextSlot?['bookingDate']?.toString() ?? '';
    if (bookingDate.trim().isEmpty) {
      return '';
    }
    return bookingDate;
  }

  String _bestForLabel(
    dynamic quickBookResponse,
    Map<String, dynamic>? recommendation,
  ) {
    final ranking = _asMap(_asMap(quickBookResponse)?['ranking']);
    final applied = ranking?['locationRankingApplied'];
    final strategy = ranking?['strategy']?.toString() ?? '';
    if (applied == true && strategy.isNotEmpty) {
      return 'Ranked by ${strategy.replaceAll('_', ' ')}';
    }

    final nextSlot = _asMap(recommendation?['nextSlot']);
    final playType = nextSlot?['playType']?.toString() ?? '';
    if (playType.isNotEmpty) {
      return 'Next ${playType.replaceAll('_', ' ')} option';
    }

    return '';
  }

  String _description(
    dynamic detailResponse,
    GolfClubModel club, {
    required String requestedSlug,
  }) {
    final kinraraContent = _kinraraDummyContent(
      club,
      requestedSlug: requestedSlug,
    );
    if (kinraraContent != null) {
      return kinraraContent.summary;
    }

    final map = _asMap(detailResponse);
    final candidates = <dynamic>[
      map?['description'],
      _asMap(map?['data'])?['description'],
      _asMap(map?['club'])?['description'],
      _asMap(map?['data'])?['club'] is Map<String, dynamic>
          ? (_asMap(_asMap(map?['data'])?['club'])?['description'])
          : null,
    ];

    for (final candidate in candidates) {
      final value = candidate?.toString() ?? '';
      if (value.trim().isNotEmpty) {
        return value;
      }
    }

    return '${club.name} is available for booking in the app. Open the next available slot and review the live booking recommendation before confirming your round.';
  }

  List<String> _facilityLabels(
    dynamic detailResponse,
    GolfClubModel club, {
    required String requestedSlug,
  }) {
    final kinraraContent = _kinraraDummyContent(
      club,
      requestedSlug: requestedSlug,
    );
    if (kinraraContent != null && kinraraContent.facilities.isNotEmpty) {
      return kinraraContent.facilities;
    }

    final map = _asMap(detailResponse);
    final facilityCandidates = <dynamic>[
      map?['facilities'],
      _asMap(map?['data'])?['facilities'],
      _asMap(map?['club'])?['facilities'],
    ];

    for (final candidate in facilityCandidates) {
      if (candidate is List) {
        final labels = candidate
            .map((item) {
              if (item is Map<String, dynamic>) {
                return item['label']?.toString() ??
                    item['name']?.toString() ??
                    '';
              }
              return item?.toString() ?? '';
            })
            .where((item) => item.trim().isNotEmpty)
            .toList();
        if (labels.isNotEmpty) {
          return labels;
        }
      }
    }

    final fallback = <String>[
      if (club.supportsNineHoles) '9-Hole Support',
      if (club.supportedNines.isNotEmpty)
        ...club.supportedNines.map(_formatSentenceLabel),
      if (club.buggyPolicy.trim().isNotEmpty)
        'Buggy ${_formatSentenceLabel(club.buggyPolicy)}',
      ...club.paymentMethods.map(_formatSentenceLabel),
    ].where((item) => item.trim().isNotEmpty).toList();

    return fallback.isEmpty ? const <String>['Golf Booking'] : fallback;
  }

  List<String> _photoUrls(dynamic detailResponse) {
    final map = _asMap(detailResponse);
    final candidates = <dynamic>[
      map?['photos'],
      map?['images'],
      map?['gallery'],
      map?['imageUrls'],
      _asMap(map?['data'])?['photos'],
      _asMap(map?['data'])?['images'],
      _asMap(map?['club'])?['photos'],
      _asMap(map?['club'])?['images'],
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        final urls = candidate.map((item) {
          if (item is Map<String, dynamic>) {
            return item['url']?.toString() ??
                item['imageUrl']?.toString() ??
                item['src']?.toString() ??
                '';
          }
          return item?.toString() ?? '';
        }).where((item) => item.trim().isNotEmpty).toList();

        if (urls.isNotEmpty) {
          return urls;
        }
      }
    }

    return const <String>[];
  }

  String _dayLabel(String rawDate) {
    final date = DateTime.tryParse(rawDate);
    if (date == null) {
      return rawDate;
    }

    switch (date.weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
    }
    return rawDate;
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
    return int.tryParse(value?.toString() ?? '');
  }

  int? _parseNullableInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  double? _parseNullableDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '');
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    return value is Map<String, dynamic> ? value : null;
  }

  LocalGolfClubDisplayContent? _kinraraDummyContent(
    GolfClubModel club, {
    required String requestedSlug,
  }) {
    final normalizedRequestedSlug = requestedSlug.trim().toLowerCase();
    final normalizedSlug = club.slug.trim().toLowerCase();
    final normalizedName = club.name.trim().toLowerCase();
    if (normalizedRequestedSlug == 'kinrara-golf-club' ||
        normalizedSlug == 'kinrara-golf-club' ||
        normalizedName == 'kinrara golf club' ||
        normalizedName.contains('kinrara')) {
      return localCourseDisplayContent['kinrara-golf-club'];
    }
    return null;
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

String _formatSentenceLabel(String value) {
  return StringUtil.formatSentenceLabel(value);
}
