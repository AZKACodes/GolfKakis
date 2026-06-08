import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/overview/view/widgets/booking_details_item.dart';
import 'package:golf_kakis/features/booking/overview/viewmodel/booking_overview_view_contract.dart';
import 'package:golf_kakis/features/booking/submission/slot/view/widgets/bottomsheet/golf_club_selection_bottom_sheet.dart';
import 'package:golf_kakis/features/booking/submission/start/viewmodel/booking_submission_start_view_contract.dart';
import 'package:golf_kakis/features/foundation/model/booking_model.dart';
import 'package:golf_kakis/features/foundation/model/golf_club_model.dart';
import 'package:golf_kakis/features/foundation/widgets/card/golf_kakis_count_selection_card.dart';
import 'package:golf_kakis/features/foundation/widgets/container/golf_kakis_shimmer_container.dart';

const double _bottomNavScrollClearance = 136;

class BookingOverviewView extends StatelessWidget {
  const BookingOverviewView({
    required this.controller,
    required this.state,
    required this.startBookingState,
    required this.onLoadStartGolfClubs,
    required this.onRefresh,
    required this.onRefreshCalendar,
    required this.onStartBookingIntent,
    required this.onViewModeChanged,
    required this.onViewBookingDetailClick,
    super.key,
  });

  final TabController controller;
  final BookingOverviewViewState state;
  final BookingSubmissionStartViewState startBookingState;
  final Future<BookingSubmissionStartDataLoaded> Function()
  onLoadStartGolfClubs;
  final Future<void> Function(BookingOverviewTab tab) onRefresh;
  final Future<void> Function() onRefreshCalendar;
  final ValueChanged<BookingSubmissionStartUserIntent> onStartBookingIntent;
  final ValueChanged<BookingOverviewViewMode> onViewModeChanged;
  final ValueChanged<BookingModel> onViewBookingDetailClick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BookingOverviewStartBookingSection(
          state: switch (startBookingState) {
            BookingSubmissionStartDataLoaded() =>
              startBookingState as BookingSubmissionStartDataLoaded,
          },
          onUserIntent: onStartBookingIntent,
          onLoadGolfClubs: onLoadStartGolfClubs,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Align(
            alignment: Alignment.centerRight,
            child: _BookingOverviewViewModeToggle(
              value: state.viewMode,
              onChanged: onViewModeChanged,
            ),
          ),
        ),
        if (state.viewMode == BookingOverviewViewMode.calendar)
          Expanded(
            child: _BookingCalendarContent(
              bookings: [...state.upcomingBookings, ...state.pastBookings],
              isLoading: state.isCalendarLoading,
              hasLoaded: state.hasLoadedUpcoming && state.hasLoadedPast,
              onRefresh: onRefreshCalendar,
              onViewBookingDetailClick: onViewBookingDetailClick,
            ),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: controller,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelStyle: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: theme.textTheme.labelLarge,
                  labelColor: Colors.black87,
                  unselectedLabelColor: Colors.black54,
                  splashBorderRadius: BorderRadius.circular(8),
                  tabs: const [
                    Tab(text: 'Upcoming'),
                    Tab(text: 'Past'),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: controller,
              children: [
                _BookingOverviewTabContent(
                  bookings: state.upcomingBookings,
                  emptyLabel: 'No Upcoming Bookings Yet',
                  isLoading: state.isUpcomingLoading,
                  hasLoaded: state.hasLoadedUpcoming,
                  tab: BookingOverviewTab.upcoming,
                  onRefresh: onRefresh,
                  onViewBookingDetailClick: onViewBookingDetailClick,
                ),
                _BookingOverviewTabContent(
                  bookings: state.pastBookings,
                  emptyLabel: 'No Past Bookings Available',
                  isLoading: state.isPastLoading,
                  hasLoaded: state.hasLoadedPast,
                  tab: BookingOverviewTab.past,
                  onRefresh: onRefresh,
                  onViewBookingDetailClick: onViewBookingDetailClick,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _BookingOverviewViewModeToggle extends StatelessWidget {
  const _BookingOverviewViewModeToggle({
    required this.value,
    required this.onChanged,
  });

  final BookingOverviewViewMode value;
  final ValueChanged<BookingOverviewViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final isList = value == BookingOverviewViewMode.list;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BookingOverviewViewModeButton(
            icon: Icons.view_list_rounded,
            isSelected: isList,
            onTap: () => onChanged(BookingOverviewViewMode.list),
          ),
          _BookingOverviewViewModeButton(
            icon: Icons.calendar_month_rounded,
            isSelected: !isList,
            onTap: () => onChanged(BookingOverviewViewMode.calendar),
          ),
        ],
      ),
    );
  }
}

class _BookingOverviewStartBookingSection extends StatelessWidget {
  const _BookingOverviewStartBookingSection({
    required this.state,
    required this.onUserIntent,
    required this.onLoadGolfClubs,
  });

  final BookingSubmissionStartDataLoaded state;
  final ValueChanged<BookingSubmissionStartUserIntent> onUserIntent;
  final Future<BookingSubmissionStartDataLoaded> Function() onLoadGolfClubs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
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
            _OverviewStartGolfClubField(
              selectedClub: state.selectedGolfClub,
              isLoading: state.isLoadingGolfClubs,
              onTap: () => _openGolfClubPicker(context),
            ),
            const SizedBox(height: 12),
            GolfKakisCountSelectionCard(
              title: 'No Of Players',
              subtitle: 'Select how many players will join this booking.',
              value: state.playerCount,
              minValue: 2,
              maxValue: 6,
              onChanged: (value) {
                onUserIntent(OnStartPlayerCountChanged(value));
              },
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: state.canSearch
                    ? () => onUserIntent(const OnSearchBookingSlotsClick())
                    : null,
                icon: const Icon(Icons.search_rounded),
                label: const Text('Search'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openGolfClubPicker(BuildContext context) async {
    final latestState = await onLoadGolfClubs();
    if (!context.mounted) {
      return;
    }
    GolfClubSelectionBottomSheet.show(
      context: context,
      clubs: latestState.golfClubList,
      selectedClub: latestState.selectedGolfClub,
      isNearbySortActive: latestState.isNearbySortActive,
      onNearbyTap: () =>
          onUserIntent(const OnSortStartGolfClubsByNearbyClick()),
      onClubSelected: (club) {
        onUserIntent(OnSelectStartGolfClub(club));
      },
    );
  }
}

class _OverviewStartGolfClubField extends StatelessWidget {
  const _OverviewStartGolfClubField({
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
              _OverviewGolfClubThumbnail(imageUrl: club?.coverPhotoUrl),
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

class _OverviewGolfClubThumbnail extends StatelessWidget {
  const _OverviewGolfClubThumbnail({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 42,
        height: 42,
        child: url.isEmpty
            ? const ColoredBox(
                color: Color(0xFFE2F3E8),
                child: Icon(
                  Icons.golf_course_rounded,
                  color: Color(0xFF0D7A3A),
                ),
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const ColoredBox(
                  color: Color(0xFFE2F3E8),
                  child: Icon(
                    Icons.golf_course_rounded,
                    color: Color(0xFF0D7A3A),
                  ),
                ),
              ),
      ),
    );
  }
}

class _BookingOverviewViewModeButton extends StatelessWidget {
  const _BookingOverviewViewModeButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          width: 42,
          height: 34,
          child: Icon(
            icon,
            size: 20,
            color: isSelected ? const Color(0xFF0A1F1A) : Colors.black54,
          ),
        ),
      ),
    );
  }
}

class _BookingCalendarContent extends StatefulWidget {
  const _BookingCalendarContent({
    required this.bookings,
    required this.isLoading,
    required this.hasLoaded,
    required this.onRefresh,
    required this.onViewBookingDetailClick,
  });

  final List<BookingModel> bookings;
  final bool isLoading;
  final bool hasLoaded;
  final Future<void> Function() onRefresh;
  final ValueChanged<BookingModel> onViewBookingDetailClick;

  @override
  State<_BookingCalendarContent> createState() =>
      _BookingCalendarContentState();
}

class _BookingCalendarContentState extends State<_BookingCalendarContent> {
  late DateTime _visibleMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _visibleMonth = _monthStart(DateTime.now());
    _selectedDate = _dateOnly(DateTime.now());
  }

  @override
  void didUpdateWidget(covariant _BookingCalendarContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bookings == oldWidget.bookings) {
      return;
    }

    _selectedDate ??= _dateOnly(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && !widget.hasLoaded) {
      return const _BookingCalendarLoadingShimmer();
    }

    final groupedBookings = _groupBookingsByDate(widget.bookings);
    final selectedBookings = _selectedDate == null
        ? const <BookingModel>[]
        : groupedBookings[_dateOnly(_selectedDate!)] ?? const <BookingModel>[];

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverToBoxAdapter(
              child: _BookingMonthCalendar(
                visibleMonth: _visibleMonth,
                selectedDate: _selectedDate,
                bookingCountsByDate: groupedBookings.map(
                  (date, bookings) => MapEntry(date, bookings.length),
                ),
                onPreviousMonth: () {
                  setState(() {
                    _visibleMonth = DateTime(
                      _visibleMonth.year,
                      _visibleMonth.month - 1,
                    );
                  });
                },
                onNextMonth: () {
                  setState(() {
                    _visibleMonth = DateTime(
                      _visibleMonth.year,
                      _visibleMonth.month + 1,
                    );
                  });
                },
                onDateSelected: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              _bottomNavScrollClearance,
            ),
            sliver: selectedBookings.isEmpty
                ? SliverToBoxAdapter(
                    child: _CalendarSelectedDateEmptyState(
                      label: _selectedDate == null
                          ? 'No bookings found'
                          : 'No bookings on ${_formatDateLabel(_selectedDate!)}',
                    ),
                  )
                : SliverList.separated(
                    itemCount: selectedBookings.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, index) {
                      final booking = selectedBookings[index];
                      final isPast = _isPastBooking(booking);

                      return Opacity(
                        opacity: isPast ? 0.56 : 1,
                        child: BookingDetailsItem(
                          item: booking,
                          showStatus: !isPast,
                          onViewBookingDetailClick:
                              widget.onViewBookingDetailClick,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _BookingMonthCalendar extends StatelessWidget {
  const _BookingMonthCalendar({
    required this.visibleMonth,
    required this.selectedDate,
    required this.bookingCountsByDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDateSelected,
  });

  final DateTime visibleMonth;
  final DateTime? selectedDate;
  final Map<DateTime, int> bookingCountsByDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = _calendarDaysForMonth(visibleMonth);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(
                  '${_monthNames[visibleMonth.month - 1]} ${visibleMonth.year}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: onNextMonth,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              _WeekdayLabel('Mon'),
              _WeekdayLabel('Tue'),
              _WeekdayLabel('Wed'),
              _WeekdayLabel('Thu'),
              _WeekdayLabel('Fri'),
              _WeekdayLabel('Sat'),
              _WeekdayLabel('Sun'),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              final day = days[index];
              final date = _dateOnly(day);
              final isCurrentMonth = day.month == visibleMonth.month;
              final isSelected =
                  selectedDate != null && date == _dateOnly(selectedDate!);
              final bookingCount = bookingCountsByDate[date] ?? 0;

              return _CalendarDayCell(
                day: day.day,
                isCurrentMonth: isCurrentMonth,
                isSelected: isSelected,
                bookingCount: bookingCount,
                onTap: () => onDateSelected(date),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.black45,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.day,
    required this.isCurrentMonth,
    required this.isSelected,
    required this.bookingCount,
    required this.onTap,
  });

  final int day;
  final bool isCurrentMonth;
  final bool isSelected;
  final int bookingCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isSelected
        ? Colors.white
        : isCurrentMonth
        ? Colors.black87
        : Colors.black26;

    return Material(
      color: isSelected ? const Color(0xFF0A1F1A) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              day.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: foregroundColor,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
            if (bookingCount > 0)
              Positioned(
                bottom: 5,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CalendarSelectedDateEmptyState extends StatelessWidget {
  const _CalendarSelectedDateEmptyState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
      ),
    );
  }
}

class _BookingOverviewTabContent extends StatelessWidget {
  const _BookingOverviewTabContent({
    required this.bookings,
    required this.emptyLabel,
    required this.isLoading,
    required this.hasLoaded,
    required this.tab,
    required this.onRefresh,
    required this.onViewBookingDetailClick,
  });

  final List<BookingModel> bookings;
  final String emptyLabel;
  final bool isLoading;
  final bool hasLoaded;
  final BookingOverviewTab tab;
  final Future<void> Function(BookingOverviewTab tab) onRefresh;
  final ValueChanged<BookingModel> onViewBookingDetailClick;

  @override
  Widget build(BuildContext context) {
    if (isLoading && !hasLoaded) {
      return const _BookingListLoadingShimmer();
    }

    return RefreshIndicator(
      onRefresh: () => onRefresh(tab),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (bookings.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    emptyLabel,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                _bottomNavScrollClearance,
              ),
              sliver: SliverList.separated(
                itemCount: bookings.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, index) => BookingDetailsItem(
                  item: bookings[index],
                  onViewBookingDetailClick: onViewBookingDetailClick,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BookingListLoadingShimmer extends StatelessWidget {
  const _BookingListLoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            _bottomNavScrollClearance,
          ),
          sliver: SliverList.separated(
            itemCount: 4,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, _) => const _BookingCardLoadingShimmer(),
          ),
        ),
      ],
    );
  }
}

class _BookingCalendarLoadingShimmer extends StatelessWidget {
  const _BookingCalendarLoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          sliver: SliverToBoxAdapter(
            child: GolfKakisShimmerContainer(height: 318, borderRadius: 18),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            _bottomNavScrollClearance,
          ),
          sliver: SliverList.separated(
            itemCount: 2,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, _) => const _BookingCardLoadingShimmer(),
          ),
        ),
      ],
    );
  }
}

class _BookingCardLoadingShimmer extends StatelessWidget {
  const _BookingCardLoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GolfKakisShimmerContainer(height: 20, borderRadius: 8),
              ),
              SizedBox(width: 12),
              GolfKakisShimmerContainer(
                width: 76,
                height: 24,
                borderRadius: 999,
              ),
            ],
          ),
          SizedBox(height: 14),
          GolfKakisShimmerContainer(height: 14, borderRadius: 7),
          SizedBox(height: 10),
          GolfKakisShimmerContainer(width: 220, height: 14, borderRadius: 7),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GolfKakisShimmerContainer(height: 36, borderRadius: 10),
              ),
              SizedBox(width: 10),
              Expanded(
                child: GolfKakisShimmerContainer(height: 36, borderRadius: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Map<DateTime, List<BookingModel>> _groupBookingsByDate(
  List<BookingModel> bookings,
) {
  final grouped = <DateTime, List<BookingModel>>{};
  for (final booking in bookings) {
    final date = _bookingDate(booking);
    if (date == null) {
      continue;
    }
    grouped.putIfAbsent(_dateOnly(date), () => <BookingModel>[]).add(booking);
  }

  for (final bookings in grouped.values) {
    bookings.sort((left, right) => left.timeLabel.compareTo(right.timeLabel));
  }

  return grouped;
}

bool _isPastBooking(BookingModel booking) {
  final bookingDateTime = _bookingDateTime(booking);
  if (bookingDateTime == null) {
    return false;
  }
  return bookingDateTime.isBefore(DateTime.now());
}

DateTime? _bookingDate(BookingModel booking) {
  final rawDate = booking.bookingDate?.trim();
  if (rawDate != null && rawDate.isNotEmpty) {
    final parsed = DateTime.tryParse(rawDate);
    if (parsed != null) {
      return parsed;
    }
  }
  return DateTime.tryParse(booking.dateLabel.trim());
}

DateTime? _bookingDateTime(BookingModel booking) {
  final date = _bookingDate(booking);
  if (date == null) {
    return null;
  }

  final timeOfDay =
      _parseBookingTime(booking.teeTimeSlot) ??
      _parseBookingTime(booking.timeLabel);
  if (timeOfDay == null) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  return DateTime(
    date.year,
    date.month,
    date.day,
    timeOfDay.hour,
    timeOfDay.minute,
  );
}

TimeOfDay? _parseBookingTime(String rawTime) {
  final trimmed = rawTime.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  final match = RegExp(
    r'(\d{1,2})[:.](\d{2})\s*(am|pm)?',
    caseSensitive: false,
  ).firstMatch(trimmed);
  if (match == null) {
    return null;
  }

  var hour = int.tryParse(match.group(1) ?? '');
  final minute = int.tryParse(match.group(2) ?? '');
  if (hour == null || minute == null || minute > 59) {
    return null;
  }

  final meridiem = match.group(3)?.toLowerCase();
  if (meridiem == 'pm' && hour < 12) {
    hour += 12;
  } else if (meridiem == 'am' && hour == 12) {
    hour = 0;
  }

  if (hour > 23) {
    return null;
  }

  return TimeOfDay(hour: hour, minute: minute);
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

DateTime _monthStart(DateTime date) {
  return DateTime(date.year, date.month);
}

List<DateTime> _calendarDaysForMonth(DateTime month) {
  final firstDay = DateTime(month.year, month.month);
  final leadingDays = firstDay.weekday - DateTime.monday;
  final gridStart = firstDay.subtract(Duration(days: leadingDays));
  return List<DateTime>.generate(42, (index) {
    return _dateOnly(gridStart.add(Duration(days: index)));
  });
}

String _formatDateLabel(DateTime date) {
  return '${date.day} ${_monthNames[date.month - 1]} ${date.year}';
}

const List<String> _monthNames = <String>[
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
