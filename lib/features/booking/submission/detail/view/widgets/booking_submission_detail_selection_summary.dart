import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/submission/detail/viewmodel/booking_submission_detail_view_contract.dart';

class BookingSubmissionDetailSelectionSummary extends StatelessWidget {
  const BookingSubmissionDetailSelectionSummary({
    required this.state,
    super.key,
  });

  final BookingSubmissionDetailDataLoaded state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8F4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB9D6B9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Booking',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          BookingSubmissionDetailSelectionSummaryRow(
            label: 'Golf Club',
            value: state.golfClubName,
          ),

          const SizedBox(height: 6),

          BookingSubmissionDetailSelectionSummaryRow(
            label: 'Tee Time',
            value: state.teeTimeSlot,
          ),

          const SizedBox(height: 6),

          BookingSubmissionDetailSelectionSummaryRow(
            label: 'Buggy Type',
            value: _buggyTypeLabel(state.effectiveBuggyType),
          ),

          const SizedBox(height: 6),

          BookingSubmissionDetailSelectionSummaryRow(
            label: 'Price',
            value: '${state.pricePerPersonLabel} per person',
          ),

          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x260D7A3A)),
            ),
            child: Row(
              children: [
                Text(
                  'Estimated Total',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  state.totalCostLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF0D7A3A),
                    fontWeight: FontWeight.w800,
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

String _buggyTypeLabel(String value) {
  switch (value) {
    case 'jumbo':
      return 'Jumbo';
    case 'normal':
      return 'Normal';
    default:
      return value;
  }
}

class BookingSubmissionDetailSelectionSummaryRow extends StatelessWidget {
  const BookingSubmissionDetailSelectionSummaryRow({
    required this.label,
    required this.value,
    super.key,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        SizedBox(
          width: 84,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
