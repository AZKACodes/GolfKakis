import 'package:flutter/material.dart';
import 'package:xxx_demo_app/features/booking/submission/success/viewmodel/booking_submission_success_view_contract.dart';
import 'package:xxx_demo_app/features/foundation/widgets/booking_submission_metric_column.dart';

class BookingSubmissionSuccessContent extends StatelessWidget {
  const BookingSubmissionSuccessContent({required this.state, super.key});

  final BookingSubmissionSuccessDataLoaded state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: Color(0xFF0D7A3A),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Booking Submitted',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your booking has been recorded successfully. Keep this receipt for reference.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Booking Receipt',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5EC),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Confirmed',
                          style: TextStyle(
                            color: Color(0xFF0D7A3A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _ReceiptRow(label: 'Booking ID', value: state.bookingId),
                  _ReceiptRow(label: 'Date', value: state.bookingDate),
                  _ReceiptRow(label: 'Golf Club', value: state.golfClubName),
                  _ReceiptRow(label: 'Tee Time', value: state.teeTimeSlot),
                  _ReceiptRow(
                    label: 'Price/Pax',
                    value: state.pricePerPersonLabel,
                  ),
                  _ReceiptRow(label: 'Total Cost', value: state.totalCostLabel),
                  _ReceiptRow(label: 'Host Name', value: state.hostName),
                  _ReceiptRow(
                    label: 'Host Phone',
                    value: state.hostPhoneNumber,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1),
                  ),
                  Row(
                    children: [
                      BookingSubmissionMetricColumn(
                        icon: Icons.group_outlined,
                        label: 'Players',
                        value: '${state.playerCount}',
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 12),
                      BookingSubmissionMetricColumn(
                        icon: Icons.golf_course_outlined,
                        label: 'Rounds',
                        value: '1',
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 12),
                      BookingSubmissionMetricColumn(
                        icon: Icons.support_agent_outlined,
                        label: 'Caddies',
                        value: '${state.caddieCount}',
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 12),
                      BookingSubmissionMetricColumn(
                        icon: Icons.directions_car_outlined,
                        label: 'Carts',
                        value: '${state.golfCartCount}',
                        color: Colors.black87,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 96,
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
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
