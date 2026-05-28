import 'package:flutter/material.dart';

import '../../../data/course_details_repository.dart';
import '../item/course_details_section_card.dart';

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
      title: 'Weather',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (weather != null)
            _TodayWeatherCard(weather: weather!)
          else
            const _WeatherUnavailableCard(),
          if (weatherForecast.isNotEmpty) ...[
            const SizedBox(height: 18),
            SizedBox(
              height: 148,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: weatherForecast.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = weatherForecast[index];
                  return _ForecastCard(
                    item: item,
                    isToday: index == 0,
                    onTap: () => _showHourlyForecastBottomSheet(
                      context: context,
                      day: item,
                      isToday: index == 0,
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TodayWeatherCard extends StatelessWidget {
  const _TodayWeatherCard({required this.weather});

  final CourseWeatherSummary weather;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 22),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_weekdayLabel(now)}, ${_timeLabel(now)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${weather.temperatureCelsius}°',
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: Colors.black87,
                    fontSize: 74,
                    height: 0.92,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  weather.weatherLabel,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'H ${weather.highCelsius}°  L ${weather.lowCelsius}°  Wind ${weather.windSpeedKph} km/h',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Icon(
            _resolveWeatherIcon(weather.weatherIcon),
            size: 92,
            color: _resolveWeatherColor(weather.weatherIcon),
          ),
        ],
      ),
    );
  }
}

class _WeatherUnavailableCard extends StatelessWidget {
  const _WeatherUnavailableCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Weather is unavailable right now.',
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
  const _ForecastCard({
    required this.item,
    required this.isToday,
    required this.onTap,
  });

  final CourseWeatherForecastItem item;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.hourlyForecast.isEmpty ? null : onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          width: 104,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isToday ? const Color(0xFFE9F5FF) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isToday
                  ? const Color(0xFF139CEB)
                  : const Color(0xFFE8E8E8),
              width: isToday ? 1.4 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                isToday ? 'Today' : item.dayLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isToday ? const Color(0xFF0B78BB) : Colors.black54,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Icon(
                _resolveWeatherIcon(item.weatherIcon),
                size: 30,
                color: _resolveWeatherColor(item.weatherIcon),
              ),
              const SizedBox(height: 8),
              Text(
                '${item.highCelsius}°',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.black87,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'L ${item.lowCelsius}°',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showHourlyForecastBottomSheet({
  required BuildContext context,
  required CourseWeatherForecastItem day,
  required bool isToday,
}) {
  final now = DateTime.now();
  final hourlyItems = day.hourlyForecast.where((item) {
    if (!isToday) {
      return true;
    }
    return !item.time.isBefore(
      DateTime(now.year, now.month, now.day, now.hour),
    );
  }).toList();

  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _hourlySheetDateTitle(day, isToday: isToday),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            if (hourlyItems.isEmpty)
              const _HourlyUnavailableMessage()
            else ...[
              SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: hourlyItems.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = hourlyItems[index];
                    final isCurrentHour =
                        item.time.year == now.year &&
                        item.time.month == now.month &&
                        item.time.day == now.day &&
                        item.time.hour == now.hour;
                    return _HourlyForecastCard(
                      item: item,
                      isCurrentHour: isCurrentHour,
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              _WeatherIconLegend(
                weatherIcons: hourlyItems
                    .map((item) => item.weatherIcon)
                    .toSet()
                    .toList(),
              ),
            ],
          ],
        ),
      );
    },
  );
}

class _HourlyForecastCard extends StatelessWidget {
  const _HourlyForecastCard({required this.item, required this.isCurrentHour});

  final CourseWeatherHourlyForecastItem item;
  final bool isCurrentHour;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: isCurrentHour
            ? const Color(0xFF356D95)
            : const Color(0xFFF4F7FA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCurrentHour
              ? const Color(0xFF174F76)
              : const Color(0xFFE4EAF0),
        ),
      ),
      child: Column(
        children: [
          Text(
            isCurrentHour ? 'Now' : _hourLabel(item.time),
            style: theme.textTheme.titleSmall?.copyWith(
              color: isCurrentHour ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Icon(
            _resolveWeatherIcon(item.weatherIcon),
            color: isCurrentHour
                ? Colors.white
                : _resolveWeatherColor(item.weatherIcon),
            size: 34,
          ),
          const Spacer(),
          Text(
            '${item.temperatureCelsius}°',
            style: theme.textTheme.titleLarge?.copyWith(
              color: isCurrentHour ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${item.precipitationProbability}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isCurrentHour ? Colors.white70 : Colors.black54,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HourlyUnavailableMessage extends StatelessWidget {
  const _HourlyUnavailableMessage();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        'Hourly forecast is unavailable for this day.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.black54,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _WeatherIconLegend extends StatelessWidget {
  const _WeatherIconLegend({required this.weatherIcons});

  final List<String> weatherIcons;

  @override
  Widget build(BuildContext context) {
    final legendItems = weatherIcons.isEmpty
        ? const <String>['Clear', 'Clouds', 'Mist', 'Rain', 'Storm']
        : weatherIcons;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Icon guide',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final weatherIcon in legendItems)
              _WeatherLegendChip(weatherIcon: weatherIcon),
          ],
        ),
      ],
    );
  }
}

class _WeatherLegendChip extends StatelessWidget {
  const _WeatherLegendChip({required this.weatherIcon});

  final String weatherIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FA),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE4EAF0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _resolveWeatherIcon(weatherIcon),
            size: 18,
            color: _resolveWeatherColor(weatherIcon),
          ),
          const SizedBox(width: 7),
          Text(
            _weatherIconMeaning(weatherIcon),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

String _weekdayLabel(DateTime date) {
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
  return '';
}

String _timeLabel(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

String _hourLabel(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final suffix = date.hour >= 12 ? 'PM' : 'AM';
  return '$hour $suffix';
}

String _hourlySheetDateTitle(
  CourseWeatherForecastItem day, {
  required bool isToday,
}) {
  if (day.hourlyForecast.isEmpty) {
    return day.dayLabel;
  }
  final date = day.hourlyForecast.first.time;
  final label = isToday ? 'Today' : _fullWeekdayLabel(date);
  return '$label, ${_formatFullDate(date)}';
}

String _fullWeekdayLabel(DateTime date) {
  switch (date.weekday) {
    case DateTime.monday:
      return 'Monday';
    case DateTime.tuesday:
      return 'Tuesday';
    case DateTime.wednesday:
      return 'Wednesday';
    case DateTime.thursday:
      return 'Thursday';
    case DateTime.friday:
      return 'Friday';
    case DateTime.saturday:
      return 'Saturday';
    case DateTime.sunday:
      return 'Sunday';
  }
  return '';
}

String _formatFullDate(DateTime date) {
  const months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return '${date.day}${_ordinalSuffix(date.day)} ${months[date.month - 1]} ${date.year}';
}

String _ordinalSuffix(int day) {
  if (day >= 11 && day <= 13) {
    return 'th';
  }
  switch (day % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
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
      return Icons.cloud_queue_rounded;
  }
}

Color _resolveWeatherColor(String weatherIcon) {
  switch (weatherIcon) {
    case 'Clear':
      return const Color(0xFFFFC83D);
    case 'Rain':
      return const Color(0xFF6AA9E9);
    case 'Storm':
      return const Color(0xFF6B7280);
    default:
      return const Color(0xFFE9ECEF);
  }
}

String _weatherIconMeaning(String weatherIcon) {
  switch (weatherIcon) {
    case 'Clear':
      return 'Clear';
    case 'Clouds':
      return 'Cloudy';
    case 'Mist':
      return 'Misty';
    case 'Rain':
      return 'Rain';
    case 'Storm':
      return 'Storm';
    default:
      return 'Weather';
  }
}
