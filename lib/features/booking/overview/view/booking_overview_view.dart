import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/overview/viewmodel/booking_overview_view_contract.dart';

const double _bottomNavScrollClearance = 136;

class BookingOverviewDashboardView extends StatelessWidget {
  const BookingOverviewDashboardView({
    required this.state,
    required this.onBookingSubmissionClick,
    required this.onBookingListClick,
    required this.onUpcomingBookingDetailClick,
    super.key,
  });

  final BookingOverviewViewState state;
  final VoidCallback onBookingSubmissionClick;
  final VoidCallback onBookingListClick;
  final VoidCallback onUpcomingBookingDetailClick;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, _bottomNavScrollClearance),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StartBookingHero(onTap: onBookingSubmissionClick),
          const SizedBox(height: 18),
          _BookingListTouchpoint(onTap: onBookingListClick),
          if (state.isLoggedIn) ...[
            const SizedBox(height: 18),
            const _SectionTitle(title: 'Upcoming Booking'),
            const SizedBox(height: 10),
            if (state.isUpcomingLoading)
              const _UpcomingBookingLoadingCard()
            else if (state.upcomingBooking != null)
              _UpcomingCard(
                course: state.upcomingBooking!.courseName,
                dateLabel: state.upcomingBooking!.dateLabel,
                timeLabel: state.upcomingBooking!.teeTimeSlot,
                playersLabel: state.upcomingBooking!.playersLabel,
                countdownLabel: _startsInLabel(
                  state.upcomingBooking!.bookingDate,
                  state.upcomingBooking!.teeTimeSlot,
                ),
                checkInStatus: _checkInStatusLabel(
                  state.upcomingBooking!.bookingDate,
                  state.upcomingBooking!.teeTimeSlot,
                ),
                onOpenDetails: onUpcomingBookingDetailClick,
              )
            else
              const _EmptyUpcomingCard(),
          ],
        ],
      ),
    );
  }
}

String _startsInLabel(String? bookingDate, String teeTimeSlot) {
  final teeDateTime = _resolveTeeDateTime(bookingDate, teeTimeSlot);
  if (teeDateTime == null) {
    return 'Upcoming';
  }

  final difference = teeDateTime.difference(DateTime.now());
  if (difference.isNegative) {
    return 'Tee off passed';
  }

  final days = difference.inDays;
  final hours = difference.inHours.remainder(24);
  if (days > 0) {
    return 'Starts in ${days}d ${hours}h';
  }
  final minutes = difference.inMinutes.remainder(60);
  return 'Starts in ${difference.inHours}h ${minutes}m';
}

String _checkInStatusLabel(String? bookingDate, String teeTimeSlot) {
  final teeDateTime = _resolveTeeDateTime(bookingDate, teeTimeSlot);
  if (teeDateTime == null) {
    return 'Check-in time unavailable';
  }

  final checkInOpenAt = teeDateTime.subtract(const Duration(hours: 3));
  final difference = checkInOpenAt.difference(DateTime.now());
  if (difference.isNegative) {
    return 'Check-in is now open';
  }

  final hours = difference.inHours;
  final minutes = difference.inMinutes.remainder(60);
  if (hours > 0) {
    return 'Check-in opens in ${hours}h ${minutes}m';
  }
  return 'Check-in opens in ${difference.inMinutes}m';
}

DateTime? _resolveTeeDateTime(String? bookingDate, String teeTimeSlot) {
  if (bookingDate == null || bookingDate.trim().isEmpty) {
    return null;
  }

  final date = DateTime.tryParse(bookingDate);
  if (date == null) {
    return null;
  }

  final parts = teeTimeSlot.trim().split(' ');
  if (parts.length != 2) {
    return null;
  }
  final timeParts = parts.first.split(':');
  if (timeParts.length != 2) {
    return null;
  }
  final hour = int.tryParse(timeParts.first);
  final minute = int.tryParse(timeParts.last);
  if (hour == null || minute == null) {
    return null;
  }

  var resolvedHour = hour % 12;
  if (parts.last.toUpperCase() == 'PM') {
    resolvedHour += 12;
  }

  return DateTime(date.year, date.month, date.day, resolvedHour, minute);
}

class _StartBookingHero extends StatelessWidget {
  const _StartBookingHero({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D7A3A), Color(0xFF1F9A55)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x260D7A3A),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ready to lock in your next tee time?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a new booking, pick your preferred club, and secure the slot before it fills up.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0D7A3A),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            ),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Start Booking Now'),
          ),
        ],
      ),
    );
  }
}

class _BookingListTouchpoint extends StatelessWidget {
  const _BookingListTouchpoint({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          const Icon(Icons.list_alt_outlined, color: Color(0xFF0A1F1A)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Booking Overview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'View all upcoming and past bookings',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(onPressed: onTap, child: const Text('Open')),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({
    required this.course,
    required this.dateLabel,
    required this.timeLabel,
    required this.playersLabel,
    required this.countdownLabel,
    required this.checkInStatus,
    required this.onOpenDetails,
  });

  final String course;
  final String dateLabel;
  final String timeLabel;
  final String playersLabel;
  final String countdownLabel;
  final String checkInStatus;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF163C33), Color(0xFF255C4E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_available_outlined, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  course,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              _SurfaceTag(text: countdownLabel),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SurfaceTag(text: dateLabel),
              _SurfaceTag(text: timeLabel),
              _SurfaceTag(text: playersLabel),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  checkInStatus,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              FilledButton(
                onPressed: onOpenDetails,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF163C33),
                ),
                child: const Text('Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpcomingBookingLoadingCard extends StatelessWidget {
  const _UpcomingBookingLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black12),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _EmptyUpcomingCard extends StatelessWidget {
  const _EmptyUpcomingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No upcoming bookings yet',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Once you book a round, your next tee time will show up here.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _SurfaceTag extends StatelessWidget {
  const _SurfaceTag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
