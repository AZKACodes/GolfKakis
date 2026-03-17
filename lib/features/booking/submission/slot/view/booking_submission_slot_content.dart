import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/submission/slot/view/widgets/booking_submission_calendar.dart';
import 'package:golf_kakis/features/booking/submission/slot/view/widgets/booking_submission_period_header.dart';
import 'package:golf_kakis/features/booking/submission/slot/view/widgets/booking_submission_slot_dot_label.dart';
import 'package:golf_kakis/features/booking/submission/slot/view/widgets/booking_submission_slot_grid.dart';
import 'package:golf_kakis/features/booking/submission/slot/viewmodel/booking_submission_slot_view_contract.dart';
import 'package:golf_kakis/features/booking/submission/slot/viewmodel/booking_submission_slot_view_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';
import 'package:golf_kakis/features/foundation/widgets/app_date_picker_button.dart';

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

                _GolfClubPickerCard(
                  selectedClub: selectedClub,
                  clubs: state.golfClubList,
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

class _GolfClubPickerCard extends StatelessWidget {
  const _GolfClubPickerCard({
    required this.selectedClub,
    required this.clubs,
    required this.enabled,
    required this.onClubSelected,
  });

  final GolfClubModel? selectedClub;
  final List<GolfClubModel> clubs;
  final bool enabled;
  final ValueChanged<GolfClubModel> onClubSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final club = selectedClub;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? () => _showClubPicker(context) : null,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFFF5FBF5), Color(0xFFEAF4EE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFCEE2D2)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D7A3A),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.golf_course_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: club == null
                      ? Text(
                          'No golf clubs available',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              club.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0A1F1A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              club.address,
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
                                _ClubInfoPill(
                                  icon: Icons.flag_outlined,
                                  label: '${club.noOfHoles} holes',
                                ),
                                _ClubInfoPill(
                                  icon: Icons.tune_rounded,
                                  label: 'Tap to switch',
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0x1A000000)),
                  ),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF0A1F1A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showClubPicker(BuildContext context) async {
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.iOS) {
      await showCupertinoModalPopup<void>(
        context: context,
        builder: (context) => CupertinoActionSheet(
          title: const Text('Select Golf Club'),
          message: const Text('Choose the course for this booking.'),
          actions: clubs
              .map(
                (club) => CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onClubSelected(club);
                  },
                  child: Column(
                    children: [
                      Text(
                        club.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${club.address} • ${club.noOfHoles} holes',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            isDefaultAction: true,
            child: const Text('Cancel'),
          ),
        ),
      );
      return;
    }

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
                'Select Golf Club',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose the course for this booking.',
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
                  itemCount: clubs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final club = clubs[index];
                    final isSelected = club.slug == selectedClub?.slug;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          Navigator.of(context).pop();
                          onClubSelected(club);
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      club.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      club.address,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${club.noOfHoles} holes',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: const Color(0xFF0D7A3A),
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 10),
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF0D7A3A),
                                ),
                              ],
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
}

class _ClubInfoPill extends StatelessWidget {
  const _ClubInfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF0D7A3A)),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0A1F1A),
            ),
          ),
        ],
      ),
    );
  }
}
