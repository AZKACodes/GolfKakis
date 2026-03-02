import 'package:flutter/material.dart';
import 'package:xxx_demo_app/features/booking/submission/slot/viewmodel/booking_submission_slot_view_contract.dart';
import 'package:xxx_demo_app/features/booking/submission/slot/viewmodel/booking_submission_slot_view_model.dart';
import 'package:xxx_demo_app/features/booking/submission/slot/view/widgets/tee_time_calendar_strip.dart';
import 'package:xxx_demo_app/features/booking/submission/slot/view/widgets/tee_time_slot_grid.dart';

class BookingSubmissionSlotView extends StatefulWidget {
  const BookingSubmissionSlotView({required this.viewModel, super.key});

  final BookingSubmissionSlotViewModel viewModel;

  @override
  State<BookingSubmissionSlotView> createState() =>
      _BookingSubmissionSlotViewState();
}

class _BookingSubmissionSlotViewState extends State<BookingSubmissionSlotView> {
  final Set<int> _unavailableSlots = const {1, 4, 7, 10};

  late DateTime _selectedDate;
  int? _selectedSlot;
  _TimePeriod _selectedPeriod = _TimePeriod.am;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateUtils.dateOnly(DateTime.now());
    widget.viewModel.onUserIntent(const OnFetchGolfClubList());
    widget.viewModel.onUserIntent(OnSelectDate(_formatDate(_selectedDate)));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final state = widget.viewModel.viewState;

        return switch (state) {
          BookingSubmissionSlotDataLoaded() => _buildDataLoaded(context, state),
        };
      },
    );
  }

  Widget _buildDataLoaded(
    BuildContext context,
    BookingSubmissionSlotDataLoaded state,
  ) {
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);
    final allSlots = state.bookingSlots.map((slot) => slot.slotList).toList();
    final List<int> visibleSlotIndices = allSlots
        .asMap()
        .entries
        .where((entry) => _periodForSlot(entry.value) == _selectedPeriod)
        .map((entry) => entry.key)
        .toList();
    final List<String> visibleSlots = visibleSlotIndices
        .map((slotIndex) => allSlots[slotIndex])
        .toList();
    final int? visibleSelectedIndex = _selectedSlot == null
        ? null
        : visibleSlotIndices.indexOf(_selectedSlot!);
    final Set<int> visibleUnavailableIndices = visibleSlotIndices
        .asMap()
        .entries
        .where((entry) => _unavailableSlots.contains(entry.value))
        .map((entry) => entry.key)
        .toSet();
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

                          setState(() {
                            _selectedSlot = null;
                          });
                          widget.viewModel.onUserIntent(
                            OnSelectGolfClub(value),
                          );
                          widget.viewModel.onUserIntent(
                            OnFetchAvailableSlots(
                              clubSlug: value,
                              date: state.selectedDate.isEmpty
                                  ? _formatDate(_selectedDate)
                                  : state.selectedDate,
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
                    OutlinedButton.icon(
                      onPressed: () => _openDatePicker(context, state),
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: const Text('Pick Date'),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  localizations.formatFullDate(_selectedDate),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TeeTimeCalendarStrip(
                  selectedDate: _selectedDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                      _selectedSlot = null;
                    });
                    final formattedDate = _formatDate(date);
                    widget.viewModel.onUserIntent(OnSelectDate(formattedDate));
                    if (state.selectedClubSlug.isNotEmpty) {
                      widget.viewModel.onUserIntent(
                        OnFetchAvailableSlots(
                          clubSlug: state.selectedClubSlug,
                          date: formattedDate,
                        ),
                      );
                    }
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
                    _LegendDot(color: Colors.grey.shade300, label: 'Booked'),
                    const SizedBox(width: 10),
                    const _LegendDot(color: Colors.white, label: 'Open'),
                    const SizedBox(width: 10),
                    _LegendDot(
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
        SliverPersistentHeader(
          pinned: true,
          delegate: _PeriodToggleHeaderDelegate(
            selectedPeriod: _selectedPeriod,
            onPeriodChanged: (period) {
              setState(() {
                _selectedPeriod = period;
                _selectedSlot = null;
              });
            },
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: visibleSlots.isEmpty && !state.isLoading
                ? Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'No slots available.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  )
                : TeeTimeSlotGrid(
                    slots: visibleSlots,
                    selectedIndex: visibleSelectedIndex == -1
                        ? null
                        : visibleSelectedIndex,
                    unavailableIndices: visibleUnavailableIndices,
                    onSelected: (visibleIndex) {
                      final int globalIndex = visibleSlotIndices[visibleIndex];
                      setState(() {
                        _selectedSlot = globalIndex;
                      });
                    },
                  ),
          ),
        ),
      ],
    );
  }

  _TimePeriod _periodForSlot(String slot) {
    return slot.endsWith('PM') ? _TimePeriod.pm : _TimePeriod.am;
  }

  Future<void> _openDatePicker(
    BuildContext context,
    BookingSubmissionSlotDataLoaded state,
  ) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(today) ? today : _selectedDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );

    if (!mounted || picked == null) {
      return;
    }

    setState(() {
      _selectedDate = DateUtils.dateOnly(picked);
    });

    final formattedDate = _formatDate(_selectedDate);
    widget.viewModel.onUserIntent(OnSelectDate(formattedDate));

    if (state.selectedClubSlug.isNotEmpty) {
      widget.viewModel.onUserIntent(
        OnFetchAvailableSlots(
          clubSlug: state.selectedClubSlug,
          date: formattedDate,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final normalized = DateUtils.dateOnly(date);
    final year = normalized.year.toString().padLeft(4, '0');
    final month = normalized.month.toString().padLeft(2, '0');
    final day = normalized.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

enum _TimePeriod { am, pm }

class _PeriodToggleHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _PeriodToggleHeaderDelegate({
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  final _TimePeriod selectedPeriod;
  final ValueChanged<_TimePeriod> onPeriodChanged;

  @override
  double get minExtent => 54;

  @override
  double get maxExtent => 54;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('AM'),
            selected: selectedPeriod == _TimePeriod.am,
            onSelected: (_) => onPeriodChanged(_TimePeriod.am),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('PM'),
            selected: selectedPeriod == _TimePeriod.pm,
            onSelected: (_) => onPeriodChanged(_TimePeriod.pm),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _PeriodToggleHeaderDelegate oldDelegate) {
    return oldDelegate.selectedPeriod != selectedPeriod ||
        oldDelegate.onPeriodChanged != onPeriodChanged;
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: Colors.black26),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
