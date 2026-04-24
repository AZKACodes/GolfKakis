import 'package:golf_kakis/features/booking/api/booking_api_service.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';
import 'package:golf_kakis/features/home/api/weather_api_service.dart';

import 'golf_club_detail_repository.dart';
import 'local_golf_club_display_content.dart';

class GolfClubDetailRepositoryImpl implements GolfClubDetailRepository {
  GolfClubDetailRepositoryImpl({
    BookingApiService? bookingApiService,
    WeatherApiService? weatherApiService,
  }) : _bookingApiService = bookingApiService ?? BookingApiService(),
       _weatherApiService = weatherApiService ?? WeatherApiService();

  final BookingApiService _bookingApiService;
  final WeatherApiService _weatherApiService;

  @override
  Future<GolfClubDetailResult> onFetchGolfClubDetail({
    required String slug,
    GolfClubModel? initialClub,
  }) async {
    final detailResponse = await _bookingApiService.onFetchGolfClubDetail(
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
    final weather = await _fetchWeather(club);
    final kinraraContent = slug.trim().toLowerCase() == 'kinrara-golf-club'
        ? localGolfClubDisplayContent['kinrara-golf-club']
        : null;
    final resolvedDescription =
        kinraraContent?.summary ??
        _description(detailResponse, club, requestedSlug: slug);
    final resolvedFacilities = kinraraContent?.facilities.isNotEmpty == true
        ? kinraraContent!.facilities
        : _facilityLabels(detailResponse, club, requestedSlug: slug);

    return GolfClubDetailResult(
      detail: GolfClubDetailData(
        club: club,
        distanceLabel: _distanceLabel(recommendation),
        openSlotsLabel: _availabilityLabel(recommendation),
        greenFeeLabel: _greenFeeLabel(recommendation),
        peakLabel: _peakLabel(recommendation),
        description: resolvedDescription,
        bestForLabel: _bestForLabel(quickBookResponse, recommendation),
        facilityLabels: resolvedFacilities,
        weather: weather,
        nextSlotLabel: _nextSlotLabel(recommendation),
        bookingDateLabel: _bookingDateLabel(recommendation),
      ),
      isFallback: false,
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

  Future<GolfClubWeatherSummary?> _fetchWeather(GolfClubModel club) async {
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
      return GolfClubWeatherSummary(
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
      return localGolfClubDisplayContent['kinrara-golf-club'];
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
  final normalized = value.trim();
  if (normalized.isEmpty) {
    return '';
  }

  return normalized
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
