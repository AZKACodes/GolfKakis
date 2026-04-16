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
import 'package:golf_kakis/features/foundation/widgets/app_date_picker_button.dart';
import 'package:golf_kakis/features/foundation/widgets/card_message.dart';

class BookingSubmissionSlotContent extends StatelessWidget {
  const BookingSubmissionSlotContent({
    required this.viewModel,
    required this.state,
    super.key,
  });

  final BookingSubmissionSlotViewModel viewModel;
  final BookingSubmissionSlotDataLoaded state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);
    final selectedClub = state.selectedGolfClub;
    final hasSelectedClub = selectedClub != null;
    final hasAvailableGolfClubs = state.golfClubList.isNotEmpty;
    final canActivateCalendar = state.canActivateCalendar;

    return CustomScrollView(
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
                  normalPlayerCount: state.normalPlayerCount,
                  seniorPlayerCount: state.seniorPlayerCount,
                  onNormalPlayerCountChanged: (value) {
                    viewModel.onUserIntent(OnNormalPlayerCountChanged(value));
                  },
                  onSeniorPlayerCountChanged: (value) {
                    viewModel.onUserIntent(OnSeniorPlayerCountChanged(value));
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

                if (hasSelectedClub &&
                    state.availableSupportedNines.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Supported Nines',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _SupportedNinePickerCard(
                    value: state.selectedSupportedNine,
                    options: state.availableSupportedNines,
                    onChanged: (value) {
                      viewModel.onUserIntent(OnSelectSupportedNine(value));
                    },
                  ),
                ],

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

                if (!hasSelectedClub || !canActivateCalendar)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _CalendarGateMessage(
                      hasSelectedClub: hasSelectedClub,
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
                  onSelected: (visibleIndex) {
                    viewModel.onUserIntent(
                      OnSelectSlot(state.visibleSlots[visibleIndex]),
                    );
                  },
                ),
              ),
            ),
      ],
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
  const _CalendarGateMessage({
    required this.hasSelectedClub,
    required this.hasAvailableGolfClubs,
  });

  final bool hasSelectedClub;
  final bool hasAvailableGolfClubs;

  @override
  Widget build(BuildContext context) {
    return CardMessage(
      title: !hasSelectedClub
          ? hasAvailableGolfClubs
                ? 'Please select a golf club'
                : 'No Golf Clubs Available'
          : 'Select a supported nine first',
      message: !hasSelectedClub
          ? hasAvailableGolfClubs
                ? 'Select a golf club to continue with the calendar and available time slots.'
                : 'There are no golf clubs available right now.'
          : 'Choose a supported nine before the calendar becomes active.',
      icon: Icons.golf_course_rounded,
    );
  }
}

class _PlayerCountSection extends StatelessWidget {
  const _PlayerCountSection({
    required this.normalPlayerCount,
    required this.seniorPlayerCount,
    required this.onNormalPlayerCountChanged,
    required this.onSeniorPlayerCountChanged,
  });

  final int normalPlayerCount;
  final int seniorPlayerCount;
  final ValueChanged<int> onNormalPlayerCountChanged;
  final ValueChanged<int> onSeniorPlayerCountChanged;

  @override
  Widget build(BuildContext context) {
    return BookingSubmissionAddOnSelection(
      children: [
        _CounterPreferenceRow(
          label: 'Normal',
          value: normalPlayerCount,
          minValue: 0,
          onChanged: onNormalPlayerCountChanged,
        ),
        const Divider(height: 1),
        _CounterPreferenceRow(
          label: 'Senior Citizen',
          value: seniorPlayerCount,
          minValue: 0,
          onChanged: onSeniorPlayerCountChanged,
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
    required this.onChanged,
  });

  final String label;
  final int value;
  final int minValue;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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

class _SupportedNinePickerCard extends StatelessWidget {
  const _SupportedNinePickerCard({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: options.isEmpty ? null : () => _showPicker(context),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x1F000000)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value.isNotEmpty
                      ? _formatLabel(value)
                      : 'Select supported nine',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: value.isEmpty
                        ? Colors.black54
                        : const Color(0xFF0A1F1A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF0A1F1A),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPicker(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Supported Nine',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose the preferred nine for this booking.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: options.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = option == value;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          Navigator.of(context).pop();
                          onChanged(option);
                        },
                        child: Ink(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFF0F8F2)
                                : const Color(0xFFF8F8F6),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF0D7A3A)
                                  : const Color(0x14000000),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _formatLabel(option),
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF0D7A3A),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatLabel(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() + value.substring(1);
  }
}
