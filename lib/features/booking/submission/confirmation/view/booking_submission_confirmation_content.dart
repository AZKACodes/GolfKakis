import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/submission/confirmation/viewmodel/booking_submission_confirmation_view_contract.dart';
import 'package:golf_kakis/features/booking/submission/confirmation/viewmodel/booking_submission_confirmation_view_model.dart';
import 'package:golf_kakis/features/foundation/util/date_util.dart';

class BookingSubmissionConfirmationContent extends StatelessWidget {
  const BookingSubmissionConfirmationContent({
    required this.state,
    required this.viewModel,
    super.key,
  });

  final BookingSubmissionConfirmationDataLoaded state;
  final BookingSubmissionConfirmationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.errorMessage.isNotEmpty) ...[
              _ErrorBanner(message: state.errorMessage),
              const SizedBox(height: 12),
            ],
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: state.isHoldExpired
                    ? const Color(0xFFFDECEC)
                    : const Color(0xFFFFF6E8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: state.isHoldExpired
                      ? const Color(0xFFE7A1A1)
                      : const Color(0xFFFFD58A),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    state.isHoldExpired
                        ? Icons.timer_off_outlined
                        : Icons.timer_outlined,
                    color: state.isHoldExpired
                        ? const Color(0xFF8A3D3D)
                        : const Color(0xFF7A5200),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.isHoldExpired
                          ? 'Booking session expired'
                          : 'Complete your booking within ${state.holdCountdownLabel}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: state.isHoldExpired
                            ? const Color(0xFF8A3D3D)
                            : const Color(0xFF7A5200),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _DetailCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          state.golfClubName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ImportantDetailsPanel(
                    dateLabel: DateUtil.formatApiDate(state.selectedDate),
                    teeTimeSlot: state.teeTimeSlot,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Round Configuration',
              children: state.isPreviewPending
                  ? const [_RoundConfigurationLoading()]
                  : [
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
                            value: '18',
                          ),
                          const SizedBox(width: 10),
                          _MetricTile(
                            icon: Icons.person_outline,
                            label: 'Caddies',
                            value: '${state.caddieCount}',
                          ),
                          const SizedBox(width: 10),
                          _MetricTile(
                            icon: Icons.directions_car_outlined,
                            label: 'Buggy',
                            value: '${state.golfCartCount}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _RoundConfigurationTabs(state: state),
                    ],
            ),
            const SizedBox(height: 16),
            _VoucherSection(
              state: state,
              onApplyVoucher: () => _showVoucherBottomSheet(context),
              onRemoveVoucher: () =>
                  viewModel.performAction(const OnVoucherRemoved()),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showVoucherBottomSheet(BuildContext context) async {
    final voucherCode = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VoucherCodeBottomSheet(initialValue: state.voucherCode),
    );

    if (voucherCode == null || voucherCode.trim().isEmpty) {
      return;
    }
    viewModel.performAction(OnVoucherCodeApplied(voucherCode));
  }
}

class _VoucherCodeBottomSheet extends StatefulWidget {
  const _VoucherCodeBottomSheet({required this.initialValue});

  final String initialValue;

  @override
  State<_VoucherCodeBottomSheet> createState() =>
      _VoucherCodeBottomSheetState();
}

class _VoucherCodeBottomSheetState extends State<_VoucherCodeBottomSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Text(
                      'Apply Voucher',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Voucher Code',
                hintText: 'Enter voucher code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final value = _controller.text.trim();
                  if (value.isEmpty) {
                    return;
                  }
                  Navigator.of(context).pop(value);
                },
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundConfigurationLoading extends StatelessWidget {
  const _RoundConfigurationLoading();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Preparing booking details...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundConfigurationTabs extends StatelessWidget {
  const _RoundConfigurationTabs({required this.state});

  final BookingSubmissionConfirmationDataLoaded state;

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
                  ? _PlayerDetailsTab(state: state)
                  : _PaymentSummaryTab(state: state);

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

class _VoucherSection extends StatelessWidget {
  const _VoucherSection({
    required this.state,
    required this.onApplyVoucher,
    required this.onRemoveVoucher,
  });

  final BookingSubmissionConfirmationDataLoaded state;
  final VoidCallback onApplyVoucher;
  final VoidCallback onRemoveVoucher;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!state.hasVoucher) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onApplyVoucher,
          icon: const Icon(Icons.confirmation_number_outlined),
          label: const Text('Apply Voucher'),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD98A)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              color: Color(0xFF9A6500),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.voucherCode,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF7A5200),
                  ),
                ),
                if (state.voucherName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    state.voucherName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove voucher',
            onPressed: onRemoveVoucher,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

class _PlayerDetailsTab extends StatelessWidget {
  const _PlayerDetailsTab({required this.state});

  final BookingSubmissionConfirmationDataLoaded state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < state.playerDetails.length; i++) ...[
          _InfoRow(
            label: 'Player ${i + 1}',
            value: state.playerDetails[i].name,
          ),
          _InfoRow(
            label: 'Category',
            value: _playerCategoryLabel(state.playerDetails[i].category),
          ),
          _InfoRow(label: 'Phone', value: state.playerDetails[i].phoneNumber),
          if (i != state.playerDetails.length - 1) const Divider(height: 20),
        ],
      ],
    );
  }
}

class _PaymentSummaryTab extends StatelessWidget {
  const _PaymentSummaryTab({required this.state});

  final BookingSubmissionConfirmationDataLoaded state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (state.isPreviewLoading) ...[
          const LinearProgressIndicator(minHeight: 2),
          const SizedBox(height: 12),
        ],
        _HighlightedInfoCard(
          label: 'Payment',
          value: state.paymentMethodLabel,
          icon: Icons.point_of_sale_outlined,
        ),
        if (state.hasPreviewPricing) ...[
          const SizedBox(height: 12),
          _PriceRow(
            label: 'Green Fee',
            value: _formatPrice(state.greenFeeTotal, state.currency),
          ),
          if (state.buggyEstimatedTotal > 0)
            _PriceRow(
              label: 'Buggy',
              value: _formatPrice(state.buggyEstimatedTotal, state.currency),
            ),
          if (state.caddieTotal > 0)
            _PriceRow(
              label: 'Caddie',
              value: _formatPrice(state.caddieTotal, state.currency),
            ),
          if (state.insuranceTotal > 0)
            _PriceRow(
              label: 'Insurance',
              value: _formatPrice(state.insuranceTotal, state.currency),
            ),
          if (state.sstTotal > 0)
            _PriceRow(
              label: 'SST',
              value: _formatPrice(state.sstTotal, state.currency),
            ),
          if (state.hasVoucher && state.discountAmount > 0)
            _PriceRow(
              label: 'Voucher Applied - ${state.voucherCode}',
              value: '- ${state.discountAmountLabel}',
              valueColor: const Color(0xFF0D7A3A),
            ),
        ],
        const SizedBox(height: 12),
        _PriceRow(label: 'Grand Total', value: state.totalCostLabel),
      ],
    );
  }
}

String _formatPrice(double amount, String currency) {
  return '$currency ${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';
}

String _playerCategoryLabel(String value) {
  switch (value.trim().toLowerCase()) {
    case 'senior':
    case 'senior_citizen':
      return 'Senior Citizen';
    case 'junior':
      return 'Junior';
    case 'normal':
    default:
      return 'Normal';
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
        color: const Color(0xFFFFF4F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD4D4)),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: const Color(0xFFB42318),
          fontWeight: FontWeight.w700,
        ),
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

class _ImportantDetailsPanel extends StatelessWidget {
  const _ImportantDetailsPanel({
    required this.dateLabel,
    required this.teeTimeSlot,
  });

  final String dateLabel;
  final String teeTimeSlot;

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
          _InfoRow(label: 'Booking Status', value: 'Pending Confirmation'),
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
  const _PriceRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: valueColor ?? const Color(0xFF17397C),
            ),
          ),
        ],
      ),
    );
  }
}
