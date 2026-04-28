import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/submission/success/viewmodel/booking_submission_success_view_contract.dart';
import 'package:golf_kakis/features/foundation/util/string_util.dart';

class BookingSubmissionSuccessContent extends StatelessWidget {
  const BookingSubmissionSuccessContent({required this.state, super.key});

  final BookingSubmissionSuccessDataLoaded state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
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
            if (state.isLoading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 16),
            ],
            _DetailCard(
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
                  const SizedBox(height: 16),
                  _ProminentSectionCard(
                    title: 'Booking Details',
                    children: [
                      _HighlightedInfoCard(
                        label: 'Golf Club',
                        value: state.golfClubName,
                        icon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 12),
                      _HighlightedInfoCard(
                        label: 'Booking Ref',
                        value: state.bookingRef,
                        icon: Icons.confirmation_number_outlined,
                      ),
                      const SizedBox(height: 12),
                      _HighlightedInfoCard(
                        label: 'Date',
                        value: _formatBookingDate(state.bookingDate),
                        icon: Icons.calendar_today_outlined,
                      ),
                      const SizedBox(height: 12),
                      _HighlightedInfoCard(
                        label: 'Tee Time',
                        value: state.teeTimeSlot,
                        icon: Icons.schedule_outlined,
                      ),
                      const SizedBox(height: 12),
                      _RoundDetailsSummary(
                        items: [
                          ('Players', '${state.playerCount}'),
                          ('Holes', _holeCountFromPlayType(state.playType)),
                          (
                            'Caddies',
                            _formatMetricValue(
                              count: state.caddieCount,
                              preference: state.caddiePreference,
                            ),
                          ),
                          (
                            'Buggy',
                            _formatMetricValue(
                              count: state.golfCartCount,
                              preference: state.buggySharingPreference,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ProminentSectionCard(
                    title: 'Payment Summary',
                    children: [
                      _HighlightedInfoCard(
                        label: 'Payment Method',
                        value: state.paymentMethodLabel,
                        icon: Icons.receipt_long_outlined,
                      ),
                      const SizedBox(height: 12),
                      _HighlightedInfoCard(
                        label: 'Price Per Pax',
                        value: state.pricePerPersonLabel,
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 12),
                      _HighlightedInfoCard(
                        label: 'Total',
                        value: state.totalCostLabel,
                        icon: Icons.point_of_sale_outlined,
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

String _formatBookingDate(String rawDate) {
  final parsed = DateTime.tryParse(rawDate);
  if (parsed == null) {
    return rawDate;
  }

  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final month = months[parsed.month - 1];
  return '${parsed.day} $month ${parsed.year}';
}

String _holeCountFromPlayType(String playType) {
  return playType == '18_holes' ? '18' : '9';
}

String _formatMetricValue({required int count, required String preference}) {
  final formattedPreference = _formatEnumLabel(preference);
  if (formattedPreference == 'None') {
    return 'None';
  }
  if (formattedPreference == '-') {
    return '$count';
  }
  return '$count • $formattedPreference';
}

String _formatEnumLabel(String value) {
  return StringUtil.formatEnumLabel(value, fallback: '-');
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: child,
    );
  }
}

class _ProminentSectionCard extends StatelessWidget {
  const _ProminentSectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFF7F9FF), Color(0xFFEEF3FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD7E1FF)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x140F2F73),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _HighlightedInfoCard extends StatelessWidget {
  const _HighlightedInfoCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8E0FF)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF2A4EA0)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
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

class _RoundDetailsSummary extends StatelessWidget {
  const _RoundDetailsSummary({required this.items});

  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8E0FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _SummaryText(item: items[0])),
              const SizedBox(width: 12),
              Expanded(child: _SummaryText(item: items[1])),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _SummaryText(item: items[2])),
              const SizedBox(width: 12),
              Expanded(child: _SummaryText(item: items[3])),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryText extends StatelessWidget {
  const _SummaryText({required this.item});

  final (String, String) item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black87),
        children: [
          TextSpan(
            text: '${item.$1}: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: item.$2,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
