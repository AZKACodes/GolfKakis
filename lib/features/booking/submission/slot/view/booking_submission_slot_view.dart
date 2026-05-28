import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/submission/slot/view/widgets/booking_slot_container.dart';
import 'package:golf_kakis/features/booking/submission/slot/view/widgets/bottomsheet/golf_club_selection_bottom_sheet.dart';
import 'package:golf_kakis/features/booking/submission/slot/viewmodel/booking_submission_slot_view_contract.dart';
import 'package:golf_kakis/features/booking/submission/slot/viewmodel/booking_submission_slot_view_model.dart';
import 'package:golf_kakis/features/foundation/widgets/app_date_picker_button.dart';
import 'package:golf_kakis/features/foundation/widgets/app_nav_bar.dart';
import 'package:golf_kakis/features/foundation/widgets/calendar/golf_kakis_calender_selection.dart';
import 'package:golf_kakis/features/foundation/widgets/calendar/golf_kakis_period_header.dart';
import 'package:golf_kakis/features/foundation/widgets/card/golf_kakis_count_selection_card.dart';
import 'package:golf_kakis/features/foundation/widgets/container/golf_kakis_required_message_container.dart';
import 'package:golf_kakis/features/foundation/widgets/card/golf_kakis_selection_card.dart';
import 'package:golf_kakis/features/foundation/widgets/container/golf_kakis_loading_container.dart';
import 'package:golf_kakis/features/foundation/widgets/icon_info_pill.dart';

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
    final hasAvailableGolfClubs = state.golfClubList.isNotEmpty;
    final hasSelectableGolfClubs = state.hasSelectableGolfClubs;
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

                  GolfKakisCountSelectionCard(
                    title: 'Number of Players',
                    subtitle:
                        'Player category will be selected on the next screen for each player.',
                    value: state.playerCount,
                    minValue: 2,
                    maxValue: 6,
                    onChanged: (value) {
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

                  GolfKakisSelectionCard(
                    placeholder: 'Select Golf Club',
                    unavailablePlaceholder: 'No Golf Clubs Available',
                    loadingPlaceholder: 'Loading golf clubs...',
                    hasOptions: hasAvailableGolfClubs,
                    isLoading: state.isLoading && state.golfClubList.isEmpty,
                    enabled: hasAvailableGolfClubs && hasSelectableGolfClubs,
                    icon: Icons.golf_course_rounded,
                    onTap: () {
                      GolfClubSelectionBottomSheet.show(
                        context: context,
                        clubs: state.golfClubList,
                        selectedClub: selectedClub,
                        onClubSelected: (club) {
                          viewModel.onUserIntent(OnSelectGolfClub(club.slug));
                        },
                      );
                    },
                    selectedBuilder: selectedClub == null
                        ? null
                        : (context) => _GolfClubSelectionContent(
                            name: selectedClub.name,
                            address: selectedClub.address,
                            holes: selectedClub.noOfHoles,
                          ),
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
                        title: hasAvailableGolfClubs
                            ? 'Please select a golf club'
                            : 'No Golf Clubs Available',
                        message: hasAvailableGolfClubs
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

class _GolfClubSelectionContent extends StatelessWidget {
  const _GolfClubSelectionContent({
    required this.name,
    required this.address,
    required this.holes,
  });

  final String name;
  final String address;
  final int holes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0A1F1A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          address,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            IconInfoPill(icon: Icons.flag_outlined, label: '$holes holes'),
          ],
        ),
      ],
    );
  }
}
