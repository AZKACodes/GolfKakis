import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';
import 'package:golf_kakis/features/foundation/util/string_util.dart';
import 'package:golf_kakis/features/foundation/widgets/error_banner.dart';
import 'package:golf_kakis/features/foundation/widgets/status_pill.dart';

import '../viewmodel/booking_detail_view_contract.dart';

class BookingDetailView extends StatelessWidget {
  const BookingDetailView({
    required this.state,
    required this.onRefresh,
    super.key,
  });

  final BookingDetailViewState state;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final booking = state.booking;
    final theme = Theme.of(context);

    if (state.isLoading) {
      return const _FullscreenLoadingState();
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.errorMessage != null) ...[
              ErrorBanner(message: state.errorMessage!),
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
                      StatusPill(
                        label: booking.statusLabel,
                        color: booking.statusColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ImportantDetailsPanel(
                    bookingReference: booking.bookingReference,
                    dateLabel: booking.dateLabel,
                    teeTimeSlot: booking.teeTimeSlot,
                    createdAt: _formatTimelineDateTime(booking.createdAt),
                    updatedAt: _formatTimelineDateTime(booking.updatedAt),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Round Configuration',
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MetricTile(
                      icon: Icons.group_outlined,
                      label: 'Players',
                      value: '${booking.playerCount}',
                    ),
                    const SizedBox(width: 10),
                    _MetricTile(
                      icon: Icons.golf_course_outlined,
                      label: 'Holes',
                      value: _resolveHoleCount(booking.playType),
                    ),
                    const SizedBox(width: 10),
                    _MetricTile(
                      icon: Icons.person_outline,
                      label: 'Caddies',
                      value: '${booking.caddieCount}',
                    ),
                    const SizedBox(width: 10),
                    _MetricTile(
                      icon: Icons.directions_car_outlined,
                      label: 'Buggy',
                      value: '${booking.golfCartCount}',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  label: 'Starting Course',
                  value: _formatSentenceLabel(booking.selectedNine),
                ),
                const SizedBox(height: 12),
                _RoundConfigurationTabs(booking: booking),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Scoreboard',
              trailing: const _InlineComingSoonPill(),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundConfigurationTabs extends StatelessWidget {
  const _RoundConfigurationTabs({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          final controller = DefaultTabController.of(context);

          return AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final selectedIndex = controller.index;
              final selectedBody = selectedIndex == 0
                  ? _PlayerDetailsTab(booking: booking)
                  : _PaymentSummaryTab(booking: booking);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: TabBar(
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: Color(0x12000000),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        labelStyle: Theme.of(context).textTheme.labelLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                        unselectedLabelStyle: Theme.of(
                          context,
                        ).textTheme.labelLarge,
                        labelColor: Colors.black87,
                        unselectedLabelColor: Colors.black54,
                        splashBorderRadius: BorderRadius.circular(8),
                        tabs: const <Tab>[
                          Tab(text: 'Player Details'),
                          Tab(text: 'Payment Summary'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: KeyedSubtree(
                      key: ValueKey<int>(selectedIndex),
                      child: selectedBody,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _PlayerDetailsTab extends StatelessWidget {
  const _PlayerDetailsTab({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < booking.playerDetails.length; i++) ...[
          _InfoRow(
            label: 'Player ${i + 1}',
            value: booking.playerDetails[i].name,
          ),
          _InfoRow(label: 'Phone', value: booking.playerDetails[i].phoneNumber),
          _InfoRow(
            label: 'Category',
            value: _formatSentenceLabel(booking.playerDetails[i].category),
          ),
          if (i != booking.playerDetails.length - 1) const Divider(height: 20),
        ],
      ],
    );
  }
}

class _PaymentSummaryTab extends StatelessWidget {
  const _PaymentSummaryTab({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HighlightedInfoCard(
          label: 'Payment',
          value: _formatPaymentMethod(booking.paymentMethod),
          icon: Icons.point_of_sale_outlined,
        ),
        const SizedBox(height: 12),
        _PriceRow(label: 'Grand Total', value: booking.feeLabel),
      ],
    );
  }
}

String _resolveHoleCount(String? playType) {
  switch (playType?.trim().toLowerCase()) {
    case '9_holes':
      return '9';
    case '18_holes':
      return '18';
    default:
      return '-';
  }
}

String _formatSentenceLabel(String? value) {
  return StringUtil.formatSentenceLabel(value, fallback: '-');
}

String _formatEnumLabel(String? value) {
  return StringUtil.formatEnumLabel(value, fallback: '-');
}

String _formatPaymentMethod(String? value) {
  switch (value?.trim().toLowerCase()) {
    case 'pay_counter':
      return 'Pay At Counter';
    default:
      return _formatEnumLabel(value);
  }
}

String _formatTimelineDateTime(String? value) {
  final normalized = value?.trim() ?? '';
  if (normalized.isEmpty) {
    return '-';
  }

  final parsed = DateTime.tryParse(normalized);
  if (parsed == null) {
    return normalized;
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

  final local = parsed.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final suffix = local.hour >= 12 ? 'PM' : 'AM';
  return '${local.day} ${months[local.month - 1]} ${local.year}, ${hour.toString()}:$minute$suffix';
}

class _FullscreenLoadingState extends StatelessWidget {
  const _FullscreenLoadingState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 14),
          Text(
            'Loading booking details...',
            style: theme.textTheme.titleSmall?.copyWith(
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
  const _SectionCard({
    required this.title,
    required this.children,
    this.trailing,
  });

  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Visibility(
                visible: trailing != null,
                child: trailing ?? const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InlineComingSoonPill extends StatelessWidget {
  const _InlineComingSoonPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD4DFFF)),
      ),
      child: Text(
        'Coming Soon',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: const Color(0xFF2A4EA0),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ImportantDetailsPanel extends StatelessWidget {
  const _ImportantDetailsPanel({
    required this.bookingReference,
    required this.dateLabel,
    required this.teeTimeSlot,
    required this.createdAt,
    required this.updatedAt,
  });

  final String bookingReference;
  final String dateLabel;
  final String teeTimeSlot;
  final String createdAt;
  final String updatedAt;

  @override
  Widget build(BuildContext context) {
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
          _InfoRow(label: 'Booking Ref', value: bookingReference),
          _InfoRow(label: 'Created At', value: createdAt),
          _InfoRow(label: 'Updated At', value: updatedAt),
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

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                child: Text(
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
                  color: foregroundColor.withValues(alpha: 0.9),
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

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8E0FF)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.black54,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF142B63),
            ),
          ),
        ],
      ),
    );
  }
}
