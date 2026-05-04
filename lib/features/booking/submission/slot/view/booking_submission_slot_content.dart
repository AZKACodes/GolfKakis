import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/submission/detail/view/widgets/add_on/booking_submission_add_on_selection.dart';
import 'package:golf_kakis/features/booking/submission/detail/view/widgets/booking_submission_detail_counter_control.dart';
import 'package:golf_kakis/features/booking/submission/slot/view/widgets/booking_slot_container.dart';
import 'package:golf_kakis/features/booking/submission/slot/view/widgets/booking_submission_calendar.dart';
import 'package:golf_kakis/features/booking/submission/slot/view/widgets/booking_submission_period_header.dart';
import 'package:golf_kakis/features/booking/submission/slot/view/widgets/booking_submission_slot_dot_label.dart';
import 'package:golf_kakis/features/booking/submission/slot/view/widgets/golf_club_picker_card.dart';
import 'package:golf_kakis/features/booking/submission/slot/viewmodel/booking_submission_slot_view_contract.dart';
import 'package:golf_kakis/features/booking/submission/slot/viewmodel/booking_submission_slot_view_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_slot_model.dart';
import 'package:golf_kakis/features/foundation/util/currency_util.dart';
import 'package:golf_kakis/features/foundation/widgets/app_date_picker_button.dart';
import 'package:golf_kakis/features/foundation/widgets/card_message.dart';

class BookingSubmissionSlotContent extends StatelessWidget {
  const BookingSubmissionSlotContent({
    required this.viewModel,
    required this.state,
    required this.isSubmittingHold,
    required this.onConfirmSlotPressed,
    super.key,
  });

  final BookingSubmissionSlotViewModel viewModel;
  final BookingSubmissionSlotDataLoaded state;
  final bool isSubmittingHold;
  final Future<void> Function(BookingSlotModel slot) onConfirmSlotPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);
    final selectedClub = state.selectedGolfClub;
    final hasSelectedClub = selectedClub != null;
    final hasAvailableGolfClubs = state.golfClubList.isNotEmpty;
    final canActivateCalendar = state.canActivateCalendar;

    return RefreshIndicator(
      onRefresh: () async {
        if (!state.canActivateCalendar || state.selectedClubSlug.isEmpty) {
          return;
        }

        await viewModel.onFetchAvailableSlots(
          clubSlug: state.selectedClubSlug,
          date: state.selectedDate,
        );
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Slot',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Pick a date, choose your club, then lock in a tee time.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Players',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 10),

                  _PlayerCountSection(
                    playerCount: state.playerCount,
                    onPlayerCountChanged: (value) {
                      viewModel.onUserIntent(OnPlayerCountChanged(value));
                    },
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Golf Club',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  GolfClubPickerCard(
                    selectedClub: selectedClub,
                    clubs: state.golfClubList,
                    isLoading: state.isLoading && state.golfClubList.isEmpty,
                    enabled: state.golfClubList.isNotEmpty,
                    onClubSelected: (club) {
                      viewModel.onUserIntent(OnSelectGolfClub(club.slug));
                    },
                  ),

                  const SizedBox(height: 20),

                  AnimatedOpacity(
                    opacity: canActivateCalendar ? 1 : 0.45,
                    duration: const Duration(milliseconds: 180),
                    child: IgnorePointer(
                      ignoring: !canActivateCalendar,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Calendar',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const Spacer(),

                              AppDatePickerButton(
                                initialDate: state.pickerInitialDate,
                                firstDate: DateUtils.dateOnly(DateTime.now()),
                                lastDate: DateUtils.dateOnly(
                                  DateTime.now().add(const Duration(days: 365)),
                                ),
                                onDatePicked: (picked) {
                                  viewModel.onUserIntent(OnSelectDate(picked));
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          Text(
                            localizations.formatFullDate(state.selectedDate),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 8),

                          BookingSubmissionCalendar(
                            selectedDate: state.selectedDate,
                            onDateSelected: (date) {
                              viewModel.onUserIntent(OnSelectDate(date));
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (!hasSelectedClub)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: _CalendarGateMessage(
                        hasAvailableGolfClubs: hasAvailableGolfClubs,
                      ),
                    ),

                  const SizedBox(height: 12),

                  if (state.errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        state.errorMessage,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  if (canActivateCalendar) ...[
                    Row(
                      children: [
                        Text(
                          'Available Time Slots',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const Spacer(),

                        BookingSubmissionSlotDotLabel(
                          color: theme.colorScheme.primary,
                          label: 'Selected',
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          if (canActivateCalendar)
            BookingSubmissionPeriodHeader(
              selectedPeriod: state.selectedPeriod,
              onPeriodChanged: (period) {
                viewModel.onUserIntent(OnSelectPeriod(period));
              },
            ),

          if (canActivateCalendar)
            if (state.isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Center(child: _SlotLoadingContainer()),
                ),
              )
            else if (state.visibleSlots.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Center(
                    child: Text(
                      'No slots available.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: BookingSlotContainer(
                    slots: state.visibleSlots,
                    selectedIndex: state.visibleSelectedIndex,
                    unavailableIndices: state.visibleUnavailableIndices,
                    onSlotTap: (visibleIndex) {
                      _showSlotDetailsSheet(
                        context,
                        slot: state.visibleSlots[visibleIndex],
                        date: state.selectedDate,
                        isSelected: state.visibleSelectedIndex == visibleIndex,
                      );
                    },
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Future<void> _showSlotDetailsSheet(
    BuildContext context, {
    required BookingSlotModel slot,
    required DateTime date,
    required bool isSelected,
  }) async {
    final localizations = MaterialLocalizations.of(context);
    final prices = _slotCategoryPrices(slot);
    var hasAgreedToTerms = false;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                                dateLabel: localizations.formatFullDate(date),
                                teeTimeSlot: slot.time,
                                holeCount: '${slot.noOfHoles}',
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Category Pricing',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...prices.map(
                                (price) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _CategoryPriceRow(
                                    label: price.label,
                                    description: price.description,
                                    priceLabel: CurrencyUtil.formatPrice(
                                      price.amount,
                                      slot.currency,
                                    ),
                                  ),
                                ),
                              ),
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
                              value: hasAgreedToTerms,
                              onChanged: (value) {
                                setSheetState(() {
                                  hasAgreedToTerms = value ?? false;
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
                          onPressed: isSubmittingHold || !hasAgreedToTerms
                              ? null
                              : () async {
                                  Navigator.of(context).pop();
                                  await onConfirmSlotPressed(slot);
                                },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF0D7A3A),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(52),
                          ),
                          child: isSubmittingHold
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
          },
        );
      },
    );
  }

  List<_SlotCategoryPrice> _slotCategoryPrices(BookingSlotModel slot) {
    return <_SlotCategoryPrice>[
      _SlotCategoryPrice(
        label: 'Normal',
        description: 'Standard adult green fee',
        amount: slot.price,
      ),
      _SlotCategoryPrice(
        label: 'Senior',
        description: 'Reduced rate for senior players',
        amount: slot.price * 0.88,
      ),
      _SlotCategoryPrice(
        label: 'Junior',
        description: 'Reduced rate for junior players',
        amount: slot.price * 0.72,
      ),
    ];
  }
}

class _SlotCategoryPrice {
  const _SlotCategoryPrice({
    required this.label,
    required this.description,
    required this.amount,
  });

  final String label;
  final String description;
  final double amount;
}

class _SlotImportantDetailsPanel extends StatelessWidget {
  const _SlotImportantDetailsPanel({
    required this.dateLabel,
    required this.teeTimeSlot,
    required this.holeCount,
  });

  final String dateLabel;
  final String teeTimeSlot;
  final String holeCount;

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
                child: _SlotHighlightStatCard(
                  label: 'Date',
                  value: dateLabel,
                  backgroundColor: const Color(0xFFE8F0FF),
                  foregroundColor: const Color(0xFF17397C),
                  icon: Icons.calendar_today_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SlotHighlightStatCard(
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
          _SlotSheetInfoRow(label: 'Holes', value: holeCount),
        ],
      ),
    );
  }
}

class _SlotHighlightStatCard extends StatelessWidget {
  const _SlotHighlightStatCard({
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

class _SlotLoadingContainer extends StatelessWidget {
  const _SlotLoadingContainer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 164,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x14000000)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.6,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Loading slots...',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF0A1F1A),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarGateMessage extends StatelessWidget {
  const _CalendarGateMessage({required this.hasAvailableGolfClubs});

  final bool hasAvailableGolfClubs;

  @override
  Widget build(BuildContext context) {
    return CardMessage(
      title: hasAvailableGolfClubs
          ? 'Please select a golf club'
          : 'No Golf Clubs Available',
      message: hasAvailableGolfClubs
          ? 'Select a golf club to continue with the calendar and available time slots.'
          : 'There are no golf clubs available right now.',
      icon: Icons.golf_course_rounded,
    );
  }
}

class _PlayerCountSection extends StatelessWidget {
  const _PlayerCountSection({
    required this.playerCount,
    required this.onPlayerCountChanged,
  });

  final int playerCount;
  final ValueChanged<int> onPlayerCountChanged;

  @override
  Widget build(BuildContext context) {
    return BookingSubmissionAddOnSelection(
      children: [
        _CounterPreferenceRow(
          label: 'Number of Players',
          value: playerCount,
          minValue: 2,
          helperText:
              'Player category will be selected on the next screen for each player.',
          onChanged: onPlayerCountChanged,
        ),
      ],
    );
  }
}

class _CounterPreferenceRow extends StatelessWidget {
  const _CounterPreferenceRow({
    required this.label,
    required this.value,
    required this.minValue,
    this.helperText,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int minValue;
  final String? helperText;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (helperText != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    helperText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          BookingSubmissionDetailCounterControl(
            value: value,
            minValue: minValue,
            onChanged: onChanged,
            buttonSize: 32,
            iconSize: 15,
            valueWidth: 28,
          ),
        ],
      ),
    );
  }
}
