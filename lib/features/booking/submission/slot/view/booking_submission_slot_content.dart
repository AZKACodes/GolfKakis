import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/submission/slot/view/widgets/booking_submission_calendar.dart';
import 'package:golf_kakis/features/booking/submission/slot/view/widgets/booking_submission_period_header.dart';
import 'package:golf_kakis/features/booking/submission/slot/view/widgets/booking_submission_slot_dot_label.dart';
import 'package:golf_kakis/features/booking/submission/slot/view/widgets/booking_submission_slot_grid.dart';
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
                    viewModel.onUserIntent(
                      OnFetchAvailableSlots(
                        clubSlug: club.slug,
                        date: state.selectedDate,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                AnimatedOpacity(
                  opacity: hasSelectedClub ? 1 : 0.45,
                  duration: const Duration(milliseconds: 180),
                  child: IgnorePointer(
                    ignoring: !hasSelectedClub,
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
                    child: const CardMessage(
                      title: 'Please select a golf club',
                      message:
                          'Select a golf club to continue with the calendar and available time slots.',
                      icon: Icons.golf_course_rounded,
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
                if (hasSelectedClub) ...[
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
                  if (state.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: LinearProgressIndicator(),
                    ),
                ],
              ],
            ),
          ),
        ),
        if (hasSelectedClub)
          BookingSubmissionPeriodHeader(
            selectedPeriod: state.selectedPeriod,
            onPeriodChanged: (period) {
              viewModel.onUserIntent(OnSelectPeriod(period));
            },
          ),
        if (hasSelectedClub)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: state.visibleSlots.isEmpty && !state.isLoading
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        'No slots available.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                    )
                  : BookingSubmissionSlotGrid(
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
