class HomeWeatherSummary {
  const HomeWeatherSummary({
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
