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
    required this.photoUrls,
    this.weather,
    this.weeklyForecast = const <CourseWeatherForecastItem>[],
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
  final List<String> photoUrls;
  final CourseWeatherSummary? weather;
  final List<CourseWeatherForecastItem> weeklyForecast;
  final String nextSlotLabel;
  final String bookingDateLabel;
}

class CourseHeaderDetailsData {
  const CourseHeaderDetailsData({
    required this.club,
    required this.distanceLabel,
    required this.openSlotsLabel,
    required this.greenFeeLabel,
    required this.peakLabel,
    required this.bestForLabel,
    this.nextSlotLabel = '',
    this.bookingDateLabel = '',
  });

  final GolfClubModel club;
  final String distanceLabel;
  final String openSlotsLabel;
  final String greenFeeLabel;
  final String peakLabel;
  final String bestForLabel;
  final String nextSlotLabel;
  final String bookingDateLabel;
}

class CourseExtraDetailsData {
  const CourseExtraDetailsData({
    required this.description,
    required this.facilityLabels,
    required this.photoUrls,
  });

  final String description;
  final List<String> facilityLabels;
  final List<String> photoUrls;
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

class CourseWeatherForecastItem {
  const CourseWeatherForecastItem({
    required this.dayLabel,
    required this.highCelsius,
    required this.lowCelsius,
    required this.weatherLabel,
    required this.weatherIcon,
  });

  final String dayLabel;
  final int highCelsius;
  final int lowCelsius;
  final String weatherLabel;
  final String weatherIcon;
}

class CourseWeatherDetailsData {
  const CourseWeatherDetailsData({
    required this.weather,
    required this.weeklyForecast,
  });

  final CourseWeatherSummary? weather;
  final List<CourseWeatherForecastItem> weeklyForecast;
}

class CourseDetailsResult {
  const CourseDetailsResult({required this.detail, required this.isFallback});

  final CourseDetailsData detail;
  final bool isFallback;
}

abstract class CourseDetailsRepository {
  Future<CourseHeaderDetailsData> onFetchCourseDetails({
    required String slug,
    GolfClubModel? initialClub,
  });

  Future<CourseExtraDetailsData> onFetchCourseExtraDetails({
    required String slug,
    required GolfClubModel club,
  });

  Future<CourseWeatherDetailsData> onFetchCourseWeather({
    required GolfClubModel club,
  });
}
