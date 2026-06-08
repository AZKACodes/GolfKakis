import 'package:flutter/material.dart';

class GolfKakisCalenderSelection extends StatelessWidget {
  const GolfKakisCalenderSelection({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final DateTime preferredBaseDate = DateUtils.dateOnly(
      selectedDate.subtract(const Duration(days: 3)),
    );

    final DateTime baseDate = preferredBaseDate.isBefore(today)
        ? today
        : preferredBaseDate;

    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final date = baseDate.add(Duration(days: index));
          final isSelected = DateUtils.isSameDay(date, selectedDate);
          final isWeekend =
              date.weekday == DateTime.saturday ||
              date.weekday == DateTime.sunday;
          final backgroundColor = isSelected
              ? theme.colorScheme.primary
              : isWeekend
              ? const Color(0xFFFFF7E8)
              : theme.colorScheme.surface;
          final borderColor = isSelected
              ? theme.colorScheme.primary
              : isWeekend
              ? const Color(0xFFFFD79A)
              : theme.colorScheme.outlineVariant;
          final labelColor = isSelected
              ? Colors.white70
              : isWeekend
              ? const Color(0xFF9A5A00)
              : Colors.black54;
          final dateColor = isSelected
              ? Colors.white
              : isWeekend
              ? const Color(0xFF6E3F00)
              : Colors.black87;

          return InkWell(
            onTap: () => onDateSelected(date),
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 72,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: borderColor,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ]
                    : null,
              ),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekdayLabel(date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: labelColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '${date.day}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: dateColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    localizations.formatMonthYear(date).split(' ').first,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: labelColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _weekdayLabel(DateTime date) {
    const weekdays = <String>['Mon', 'Tues', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return weekdays[date.weekday - 1];
  }
}
