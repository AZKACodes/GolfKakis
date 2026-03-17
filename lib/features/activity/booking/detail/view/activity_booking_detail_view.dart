import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/widgets/booking_submission_metric_column.dart';

import '../viewmodel/activity_booking_detail_view_contract.dart';

class ActivityBookingDetailView extends StatelessWidget {
  const ActivityBookingDetailView({
    required this.state,
    required this.onRefresh,
    required this.onDeleteClick,
    required this.onEditDetailsClick,
    super.key,
  });

  final ActivityBookingDetailViewState state;
  final Future<void> Function() onRefresh;
  final VoidCallback onDeleteClick;
  final VoidCallback onEditDetailsClick;

  @override
  Widget build(BuildContext context) {
    final booking = state.booking;
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.isUsingFallback) ...[
              const _InfoBanner(
                message:
                    'Showing fallback booking detail until the detail endpoint is ready.',
              ),
              const SizedBox(height: 12),
            ],
            if (state.errorMessage != null) ...[
              _ErrorBanner(message: state.errorMessage!),
              const SizedBox(height: 12),
            ],
            if (state.isLoading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
            ],
            _DetailCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          booking.courseName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      _StatusChip(
                        label: booking.statusLabel,
                        color: booking.statusColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaChip(
                        icon: Icons.confirmation_number_outlined,
                        text: booking.bookingId,
                      ),
                      _MetaChip(
                        icon: Icons.calendar_today_outlined,
                        text: booking.dateLabel,
                      ),
                      _MetaChip(
                        icon: Icons.schedule_outlined,
                        text: booking.teeTimeSlot,
                      ),
                      _MetaChip(
                        icon: Icons.account_balance_wallet_outlined,
                        text: booking.feeLabel,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Host Information',
              children: [
                _InfoRow(label: 'Host Name', value: booking.hostName),
                _InfoRow(label: 'Phone Number', value: booking.hostPhoneNumber),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Round Configuration',
              children: [
                Row(
                  children: [
                    BookingSubmissionMetricColumn(
                      icon: Icons.group_outlined,
                      label: 'Players',
                      value: '${booking.playerCount}',
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 12),
                    const BookingSubmissionMetricColumn(
                      icon: Icons.golf_course_outlined,
                      label: 'Rounds',
                      value: '1',
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 12),
                    BookingSubmissionMetricColumn(
                      icon: Icons.support_agent_outlined,
                      label: 'Caddies',
                      value: '${booking.caddieCount}',
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 12),
                    BookingSubmissionMetricColumn(
                      icon: Icons.directions_car_outlined,
                      label: 'Carts',
                      value: '${booking.golfCartCount}',
                      color: Colors.black87,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Player Details',
              children: [
                for (var i = 0; i < booking.playerDetails.length; i++) ...[
                  _InfoRow(
                    label: 'Player ${i + 1}',
                    value: booking.playerDetails[i].name,
                  ),
                  _InfoRow(
                    label: 'Phone',
                    value: booking.playerDetails[i].phoneNumber,
                  ),
                  if (i != booking.playerDetails.length - 1)
                    const Divider(height: 20),
                ],
              ],
            ),
            if (!booking.isCompleted) ...[
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Actions',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: state.isDeleting ? null : onDeleteClick,
                          icon: const Icon(Icons.delete_outline),
                          label: Text(
                            state.isDeleting ? 'Deleting...' : 'Delete',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: state.isDeleting
                              ? null
                              : onEditDetailsClick,
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit Details'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Check In',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.play_circle_outline),
                          label: const Text('Check In'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const _ComingSoonBanner(message: 'Check In Coming Soon'),
                ],
              ),
            ],
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Scoreboard',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.emoji_events_outlined),
                        label: const Text('Scoreboard'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const _ComingSoonBanner(message: 'Scoreboard Coming Soon'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF3D6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9C46A)),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF7A5B00),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7A1A1)),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF8A3D3D),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ComingSoonBanner extends StatelessWidget {
  const _ComingSoonBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD4DFFF)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.campaign_outlined,
            size: 16,
            color: Color(0xFF2A4EA0),
          ),
          const SizedBox(width: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: const Color(0xFF2A4EA0),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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

    return _DetailCard(
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black54),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
