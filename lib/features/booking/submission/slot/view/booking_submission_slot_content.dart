import 'package:flutter/material.dart';
import 'package:xxx_demo_app/features/booking/submission/slot/view/widgets/booking_submission_calendar.dart';
import 'package:xxx_demo_app/features/booking/submission/slot/view/widgets/booking_submission_period_header.dart';
import 'package:xxx_demo_app/features/booking/submission/slot/view/widgets/booking_submission_slot_dot_label.dart';
import 'package:xxx_demo_app/features/booking/submission/slot/view/widgets/booking_submission_slot_grid.dart';
import 'package:xxx_demo_app/features/booking/submission/slot/viewmodel/booking_submission_slot_view_contract.dart';
import 'package:xxx_demo_app/features/booking/submission/slot/viewmodel/booking_submission_slot_view_model.dart';
import 'package:xxx_demo_app/features/foundation/widgets/app_date_picker_button.dart';

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
    final selectedClub = state.golfClubList.contains(state.selectedClubSlug)
        ? state.selectedClubSlug
        : null;

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

                DropdownButtonFormField<String>(
                  key: ValueKey(selectedClub ?? 'empty-club'),
                  initialValue: selectedClub,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                  ),
                  items: state.golfClubList
                      .map(
                        (club) => DropdownMenuItem<String>(
                          value: club,
                          child: Text(club),
                        ),
                      )
                      .toList(),
                  onChanged: state.golfClubList.isEmpty
                      ? null
                      : (value) {
                          if (value == null) {
                            return;
                          }

                          viewModel.onUserIntent(OnSelectGolfClub(value));
                          viewModel.onUserIntent(
                            OnFetchAvailableSlots(
                              clubSlug: value,
                              date: state.selectedDate,
                            ),
                          );
                        },
                ),

                const SizedBox(height: 20),

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

                Row(
                  children: [
                    Text(
                      'Select Time Slot',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const Spacer(),

                    BookingSubmissionSlotDotLabel(
                      color: Colors.grey.shade300,
                      label: 'Booked',
                    ),

                    const SizedBox(width: 10),

                    const BookingSubmissionSlotDotLabel(
                      color: Colors.white,
                      label: 'Open',
                    ),

                    const SizedBox(width: 10),

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
            ),
          ),
        ),

        BookingSubmissionPeriodHeader(
          selectedPeriod: state.selectedPeriod,
          onPeriodChanged: (period) {
            viewModel.onUserIntent(OnSelectPeriod(period));
          },
        ),
        
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
