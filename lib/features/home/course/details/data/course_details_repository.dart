import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';

class CourseDetailsData {
  const CourseDetailsData({
    required this.club,
    required this.distanceLabel,
    required this.openSlotsLabel,
    required this.greenFeeLabel,
    required this.peakLabel,
    required this.description,
    required this.bestForLabel,
    required this.facilityLabels,
    this.weather,
    this.nextSlotLabel = '',
    this.bookingDateLabel = '',
  });

  final GolfClubModel club;
  final String distanceLabel;
  final String openSlotsLabel;
  final String greenFeeLabel;
  final String peakLabel;
  final String description;
  final String bestForLabel;
  final List<String> facilityLabels;
  final CourseWeatherSummary? weather;
  final String nextSlotLabel;
  final String bookingDateLabel;
}

class CourseWeatherSummary {
  const CourseWeatherSummary({
    required this.temperatureCelsius,
    required this.highCelsius,
    required this.lowCelsius,
    required this.windSpeedKph,
    required this.weatherLabel,
    required this.weatherIcon,
  });

  final int temperatureCelsius;
  final int highCelsius;
  final int lowCelsius;
  final int windSpeedKph;
  final String weatherLabel;
  final String weatherIcon;
}

class CourseDetailsResult {
  const CourseDetailsResult({required this.detail, required this.isFallback});

  final CourseDetailsData detail;
  final bool isFallback;
}

abstract class CourseDetailsRepository {
  Future<CourseDetailsResult> onFetchCourseDetails({
    required String slug,
    GolfClubModel? initialClub,
  });
}
