import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/submission/confirmation/viewmodel/booking_submission_confirmation_view_contract.dart';
import 'package:golf_kakis/features/foundation/util/date_util.dart';

class BookingSubmissionConfirmationContent extends StatelessWidget {
  const BookingSubmissionConfirmationContent({required this.state, super.key});

  final BookingSubmissionConfirmationDataLoaded state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review Booking',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ImportantDetailsPanel(
                    golfClubName: state.golfClubName,
                    dateLabel: DateUtil.formatApiDate(state.selectedDate),
                    teeTimeSlot: state.teeTimeSlot,
                  ),
                ],
              ),
            ),
            if (state.errorMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                state.errorMessage,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 20),
            _SectionCard(
              title: 'Contact Information',
              children: [
                _InfoRow(label: 'Name', value: state.hostName),
                _InfoRow(label: 'Phone', value: state.hostPhoneNumber),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Round Setup',
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MetricTile(
                      icon: Icons.group_outlined,
                      label: 'Players',
                      value: '${state.playerCount}',
                    ),
                    const SizedBox(width: 10),
                    _MetricTile(
                      icon: Icons.golf_course_outlined,
                      label: 'Holes',
                      value: _resolveHoleCount(state.teeTimeSlot),
                    ),
                    const SizedBox(width: 10),
                    _MetricTile(
                      icon: Icons.person_outline,
                      label: 'Caddies',
                      value: '${state.caddieCount}',
                      pillLabel: _formatEnumLabel(state.caddiePreference),
                    ),
                    const SizedBox(width: 10),
                    _MetricTile(
                      icon: Icons.directions_car_outlined,
                      label: 'Buggy',
                      value: '${state.golfCartCount}',
                      pillLabel: _formatEnumLabel(state.buggySharingPreference),
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
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Player Details',
              children: [
                for (var index = 0; index < state.playerDetails.length; index++)
                  _PlayerInfoRow(
                    index: index + 1,
                    name: state.playerDetails[index].name,
                    phoneNumber: state.playerDetails[index].phoneNumber,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _resolveHoleCount(String teeTimeSlot) {
  const eighteenHoleSlots = <String>{
    '07:30 AM',
    '07:45 AM',
    '08:00 AM',
    '08:15 AM',
    '08:30 AM',
    '08:45 AM',
    '09:00 AM',
    '09:15 AM',
    '09:30 AM',
    '12:00 PM',
    '12:15 PM',
    '12:30 PM',
    '12:45 PM',
    '01:00 PM',
    '01:15 PM',
    '01:30 PM',
    '01:45 PM',
    '02:00 PM',
    '02:15 PM',
    '02:30 PM',
  };
  return eighteenHoleSlots.contains(teeTimeSlot) ? '18' : '9';
}

String _formatEnumLabel(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) {
    return '-';
  }

  return normalized
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _ImportantDetailsPanel extends StatelessWidget {
  const _ImportantDetailsPanel({
    required this.golfClubName,
    required this.dateLabel,
    required this.teeTimeSlot,
  });

  final String golfClubName;
  final String dateLabel;
  final String teeTimeSlot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8E4FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            golfClubName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF102A5C),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _HighlightStatCard(
                  label: 'Date',
                  value: dateLabel,
                  backgroundColor: const Color(0xFFE8F0FF),
                  foregroundColor: const Color(0xFF17397C),
                  icon: Icons.calendar_today_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HighlightStatCard(
                  label: 'Tee Time',
                  value: teeTimeSlot,
                  backgroundColor: const Color(0xFFEAF7EF),
                  foregroundColor: const Color(0xFF155B36),
                  icon: Icons.schedule_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _HighlightStatCard extends StatelessWidget {
  const _HighlightStatCard({
    required this.label,
    required this.value,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
  });

  final String label;
  final String value;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: foregroundColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

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
            width: 90,
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
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    this.pillLabel,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? pillLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedPill = pillLabel?.trim() ?? '';
    final hasPill = resolvedPill.isNotEmpty && resolvedPill != '-';

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: Colors.black87),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 28,
              child: Center(
                child: hasPill
                    ? _Pill(label: resolvedPill)
                    : Text(
                        value,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2A4EA0),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
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

class _PlayerInfoRow extends StatelessWidget {
  const _PlayerInfoRow({
    required this.index,
    required this.name,
    required this.phoneNumber,
  });

  final int index;
  final String name;
  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Player $index',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(name, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 2),
            Text(
              phoneNumber,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
