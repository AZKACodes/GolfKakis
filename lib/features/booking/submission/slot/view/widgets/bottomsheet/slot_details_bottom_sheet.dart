import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_slot_details_model.dart';
import 'package:golf_kakis/features/foundation/util/currency_util.dart';

class SlotDetailsBottomSheet extends StatefulWidget {
  const SlotDetailsBottomSheet({
    required this.details,
    required this.isSubmittingHold,
    required this.onConfirmSlot,
    super.key,
  });

  final BookingSlotDetailsModel details;
  final bool isSubmittingHold;
  final ValueChanged<BookingSlotDetailsModel> onConfirmSlot;

  static Future<void> show({
    required BuildContext context,
    required BookingSlotDetailsModel details,
    required bool isSubmittingHold,
    required ValueChanged<BookingSlotDetailsModel> onConfirmSlot,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => SlotDetailsBottomSheet(
        details: details,
        isSubmittingHold: isSubmittingHold,
        onConfirmSlot: onConfirmSlot,
      ),
    );
  }

  @override
  State<SlotDetailsBottomSheet> createState() => _SlotDetailsBottomSheetState();
}

class _SlotDetailsBottomSheetState extends State<SlotDetailsBottomSheet> {
  bool _hasAgreedToTerms = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final details = widget.details;
    final prices = details.categoryPricing;
    final pricingBreakdown = details.pricingBreakdown;

    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Slot Details',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Review the tee time and category pricing before confirming this slot.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SlotImportantDetailsPanel(
                        bookingDate: details.bookingDate,
                        teeTimeSlot: details.teeTimeSlot,
                        holeCount: '${details.noOfHoles}',
                        playerCount: '${details.playerCount}',
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Category Pricing',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (prices.isEmpty)
                        Text(
                          CurrencyUtil.formatPrice(
                            details.pricePerPerson,
                            details.currency,
                            suffix: '/ pax',
                          ),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF0D7A3A),
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      else
                        ...prices.map(
                          (price) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _CategoryPriceRow(
                              label: price.label,
                              description: price.description,
                              priceLabel: CurrencyUtil.formatPrice(
                                price.amount,
                                details.currency,
                              ),
                            ),
                          ),
                        ),
                      if (pricingBreakdown.hasAnySurcharge) ...[
                        const SizedBox(height: 8),
                        _SlotSurchargeCard(
                          pricingBreakdown: pricingBreakdown,
                          currency: details.currency,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x14000000)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _hasAgreedToTerms,
                      onChanged: (value) {
                        setState(() {
                          _hasAgreedToTerms = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 11),
                        child: Text(
                          'I have agreed to the terms and conditions for this booking.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: widget.isSubmittingHold || !_hasAgreedToTerms
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          widget.onConfirmSlot(widget.details);
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0D7A3A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: widget.isSubmittingHold
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Confirm Slot'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotImportantDetailsPanel extends StatelessWidget {
  const _SlotImportantDetailsPanel({
    required this.bookingDate,
    required this.teeTimeSlot,
    required this.holeCount,
    required this.playerCount,
  });

  final DateTime bookingDate;
  final String teeTimeSlot;
  final String holeCount;
  final String playerCount;

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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _weekdayLabel(bookingDate),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF17397C),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _dateLabel(bookingDate),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF17397C),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _timeLabel(teeTimeSlot),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF155B36),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 86,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x14000000)),
            ),
            child: Column(
              children: [
                _SlotSideStat(icon: Icons.flag_outlined, value: holeCount),
                const SizedBox(height: 10),
                _SlotSideStat(
                  icon: Icons.groups_2_outlined,
                  value: playerCount,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _weekdayLabel(DateTime date) {
    const weekdays = <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return weekdays[date.weekday - 1];
  }

  String _dateLabel(DateTime date) {
    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _timeLabel(String time) {
    return time.replaceFirst(RegExp('^0'), '').replaceAll(':', '.');
  }
}

class _SlotSideStat extends StatelessWidget {
  const _SlotSideStat({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF155B36)),
        const SizedBox(width: 8),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: const Color(0xFF155B36),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _SlotSurchargeCard extends StatelessWidget {
  const _SlotSurchargeCard({
    required this.pricingBreakdown,
    required this.currency,
  });

  final BookingSlotPricingBreakdownModel pricingBreakdown;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE3A3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.add_circle_outline_rounded,
                size: 18,
                color: Color(0xFF9A6700),
              ),
              const SizedBox(width: 8),
              Text(
                'Optional surcharges',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: const Color(0xFF6F4E00),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'These charges only apply if extra add-ons are requested, like adding another golf cart.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6F4E00),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          if (pricingBreakdown.golfCartSurcharge > 0)
            _SlotSheetInfoRow(
              label: 'Golf cart',
              value: CurrencyUtil.formatPrice(
                pricingBreakdown.golfCartSurcharge,
                currency,
              ),
            ),
          if (pricingBreakdown.caddySurcharge > 0)
            _SlotSheetInfoRow(
              label: 'Caddy',
              value: CurrencyUtil.formatPrice(
                pricingBreakdown.caddySurcharge,
                currency,
              ),
            ),
        ],
      ),
    );
  }
}

class _SlotSheetInfoRow extends StatelessWidget {
  const _SlotSheetInfoRow({required this.label, required this.value});

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
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPriceRow extends StatelessWidget {
  const _CategoryPriceRow({
    required this.label,
    required this.description,
    required this.priceLabel,
  });

  final String label;
  final String description;
  final String priceLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            priceLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              color: const Color(0xFF0D7A3A),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
