import 'package:flutter/material.dart';

import '../../../data/course_details_repository.dart';

class CourseDetailsWeatherCard extends StatelessWidget {
  const CourseDetailsWeatherCard({required this.weather, super.key});

  final CourseWeatherSummary weather;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE7FF)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _resolveWeatherIcon(weather.weatherIcon),
              color: const Color(0xFF173B7A),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weather.weatherLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Now ${weather.temperatureCelsius} C • Wind ${weather.windSpeedKph} km/h',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'High ${weather.highCelsius} C • Low ${weather.lowCelsius} C',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

IconData _resolveWeatherIcon(String weatherIcon) {
  switch (weatherIcon) {
    case 'Clear':
      return Icons.wb_sunny_rounded;
    case 'Clouds':
      return Icons.cloud_rounded;
    case 'Mist':
      return Icons.cloud_queue_rounded;
    case 'Rain':
      return Icons.grain_rounded;
    case 'Storm':
      return Icons.thunderstorm_rounded;
    default:
      return Icons.golf_course_rounded;
  }
}
