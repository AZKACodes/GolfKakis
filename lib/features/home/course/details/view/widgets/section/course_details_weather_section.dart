import 'package:flutter/material.dart';

import '../../../data/course_details_repository.dart';
import '../item/course_details_section_card.dart';
import '../item/course_details_weather_card.dart';

class CourseDetailsWeatherSection extends StatelessWidget {
  const CourseDetailsWeatherSection({
    required this.weather,
    required this.weatherForecast,
    super.key,
  });

  final CourseWeatherSummary? weather;
  final List<CourseWeatherForecastItem> weatherForecast;

  @override
  Widget build(BuildContext context) {
    return CourseDetailsSectionCard(
      title: 'Weekly Weather',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (weather != null)
            CourseDetailsWeatherCard(weather: weather!)
          else
            _WeatherUnavailableCard(),
          if (weatherForecast.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 116,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: weatherForecast.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final item = weatherForecast[index];
                  return _ForecastCard(item: item);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WeatherUnavailableCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
            child: const Icon(
              Icons.cloud_off_rounded,
              color: Color(0xFF173B7A),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Weekly weather is unavailable right now.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastCard extends StatelessWidget {
  const _ForecastCard({required this.item});

  final CourseWeatherForecastItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E7F4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.dayLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Icon(
            _resolveWeatherIcon(item.weatherIcon),
            color: const Color(0xFF173B7A),
          ),
          const Spacer(),
          Text(
            '${item.highCelsius} / ${item.lowCelsius} C',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0A1F1A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.weatherLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black54,
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
