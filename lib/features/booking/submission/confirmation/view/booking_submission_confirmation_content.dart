import 'package:flutter/material.dart';
import 'package:xxx_demo_app/features/booking/submission/confirmation/viewmodel/booking_submission_confirmation_view_contract.dart';
import 'package:xxx_demo_app/features/foundation/util/date_util.dart';
import 'package:xxx_demo_app/features/foundation/widgets/booking_submission_metric_column.dart';

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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F8F4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD1E4D1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review Booking',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'One final pass before you submit this proof-of-concept booking.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _InfoChip(
                        icon: Icons.pin_drop_outlined,
                        label: state.golfClubName,
                      ),
                      _InfoChip(
                        icon: Icons.schedule_outlined,
                        label:
                            '${DateUtil.formatApiDate(state.selectedDate)} • ${state.teeTimeSlot}',
                      ),
                      _InfoChip(
                        icon: Icons.payments_outlined,
                        label: '${state.pricePerPersonLabel} / pax',
                      ),
                      _InfoChip(
                        icon: Icons.perm_identity_outlined,
                        label: state.guestId?.isNotEmpty == true
                            ? state.guestId!
                            : 'Guest ID N/A',
                      ),
                    ],
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
              title: 'Host Contact',
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
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                _InfoRow(label: 'Price/Pax', value: state.pricePerPersonLabel),
                _InfoRow(label: 'Total Cost', value: state.totalCostLabel),
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF0D7A3A)),
          const SizedBox(width: 8),
          Text(label),
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
