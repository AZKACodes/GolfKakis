import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/submission/slot/view/widgets/booking_slot_container.dart';
import 'package:golf_kakis/features/booking/submission/slot/view/widgets/bottomsheet/golf_club_selection_bottom_sheet.dart';
import 'package:golf_kakis/features/booking/submission/slot/viewmodel/booking_submission_slot_view_contract.dart';
import 'package:golf_kakis/features/booking/submission/slot/viewmodel/booking_submission_slot_view_model.dart';
import 'package:golf_kakis/features/foundation/model/golf_club_model.dart';
import 'package:golf_kakis/features/foundation/widgets/app_date_picker_button.dart';
import 'package:golf_kakis/features/foundation/widgets/app_nav_bar.dart';
import 'package:golf_kakis/features/foundation/widgets/calendar/golf_kakis_calender_selection.dart';
import 'package:golf_kakis/features/foundation/widgets/calendar/golf_kakis_period_header.dart';
import 'package:golf_kakis/features/foundation/widgets/card/golf_kakis_count_selection_card.dart';
import 'package:golf_kakis/features/foundation/widgets/container/golf_kakis_required_message_container.dart';
import 'package:golf_kakis/features/foundation/widgets/container/golf_kakis_loading_container.dart';

class BookingSubmissionSlotView extends StatelessWidget {
  const BookingSubmissionSlotView({required this.viewModel, super.key});

  final BookingSubmissionSlotViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final state = viewModel.viewState;

        return switch (state) {
          BookingSubmissionSlotDataLoaded() => Scaffold(
            appBar: AppNavBar(
              title: 'Booking Slot',
              centerTitle: true,
              onBackPressed: () => viewModel.performAction(const OnBackClick()),
            ),
            body: _buildContent(context, state),
          ),
        };
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    BookingSubmissionSlotDataLoaded state,
  ) {
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);
    final selectedClub = state.selectedGolfClub;
    final hasSelectedClub = selectedClub != null;
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
                  _SlotBookingSearchCard(
                    state: state,
                    onGolfClubTap: () async {
                      await viewModel.onFetchGolfClubList();
                      if (!context.mounted) {
                        return;
                      }
                      final latestState = viewModel.getCurrentAsLoaded();
                      GolfClubSelectionBottomSheet.show(
                        context: context,
                        clubs: latestState.golfClubList,
                        selectedClub: latestState.selectedGolfClub,
                        onClubSelected: (club) {
                          viewModel.onUserIntent(OnSelectGolfClub(club.slug));
                        },
                      );
                    },
                    onPlayerCountChanged: (value) {
                      viewModel.onUserIntent(OnPlayerCountChanged(value));
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

                          GolfKakisCalenderSelection(
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
                      child: GolfKakisRequiredMessageContainer(
                        title: state.golfClubList.isNotEmpty
                            ? 'Please select a golf club'
                            : 'No Golf Clubs Available',
                        message: state.golfClubList.isNotEmpty
                            ? 'Only Kinrara Golf Club is available for booking right now.'
                            : 'There are no golf clubs available right now.',
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

                  if (canActivateCalendar) ...[
                    Text(
                      'Available Time Slots',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          if (canActivateCalendar)
            GolfKakisPeriodHeader(
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
                  child: Center(
                    child: GolfKakisLoadingContainer(
                      message: 'Loading slots...',
                    ),
                  ),
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
                      if (state.isLoadingSlotDetails) {
                        return;
                      }

                      viewModel.onUserIntent(
                        OnSlotDetailsClick(state.visibleSlots[visibleIndex]),
                      );
                    },
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _SlotBookingSearchCard extends StatelessWidget {
  const _SlotBookingSearchCard({
    required this.state,
    required this.onGolfClubTap,
    required this.onPlayerCountChanged,
  });

  final BookingSubmissionSlotDataLoaded state;
  final VoidCallback onGolfClubTap;
  final ValueChanged<int> onPlayerCountChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE1E7E4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _SlotGolfClubField(
            selectedClub: state.selectedGolfClub,
            isLoading: state.isLoading && state.golfClubList.isEmpty,
            onTap: onGolfClubTap,
          ),
          const SizedBox(height: 14),
          GolfKakisCountSelectionCard(
            title: 'No Of Players',
            value: state.playerCount,
            minValue: 2,
            maxValue: 6,
            onChanged: onPlayerCountChanged,
          ),
        ],
      ),
    );
  }
}

class _SlotGolfClubField extends StatelessWidget {
  const _SlotGolfClubField({
    required this.selectedClub,
    required this.isLoading,
    required this.onTap,
  });

  final GolfClubModel? selectedClub;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final club = selectedClub;

    return Material(
      color: const Color(0xFFF8F8F6),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE1E7E4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.golf_course_rounded, color: Color(0xFF0D7A3A)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Golf Club',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0A1F1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isLoading
                          ? 'Loading golf clubs...'
                          : club?.name ?? 'Select Golf Club',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: club == null ? Colors.black45 : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
