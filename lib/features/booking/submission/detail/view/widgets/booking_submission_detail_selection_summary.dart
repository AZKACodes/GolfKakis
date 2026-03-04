import 'package:flutter/material.dart';
import 'package:xxx_demo_app/features/booking/submission/detail/viewmodel/booking_submission_detail_view_contract.dart';

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
            value: state.golfClubSlug,
          ),

          const SizedBox(height: 6),

          BookingSubmissionDetailSelectionSummaryRow(
            label: 'Tee Time',
            value: state.teeTimeSlot,
          ),

          const SizedBox(height: 6),

          BookingSubmissionDetailSelectionSummaryRow(
            label: 'Guest ID',
            value: state.guestId?.isNotEmpty == true ? state.guestId! : 'N/A',
          ),
        ],
      ),
    );
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
