import 'package:flutter/material.dart';
import 'package:xxx_demo_app/features/booking/submission/detail/view/widgets/booking_submission_detail_counter_control.dart';

class BookingSubmissionDetailPlayerSelection extends StatelessWidget {
  const BookingSubmissionDetailPlayerSelection({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.minValue = 0,
    super.key,
  });

  final String title;
  final String subtitle;
  final int value;
  final int minValue;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),
          
          BookingSubmissionDetailCounterControl(
            value: value,
            minValue: minValue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
