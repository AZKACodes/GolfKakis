import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/submission/detail/view/widgets/booking_submission_detail_counter_control.dart';

class BookingSubmissionAddOnSelectionItem extends StatelessWidget {
  const BookingSubmissionAddOnSelectionItem({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          BookingSubmissionDetailCounterControl(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
