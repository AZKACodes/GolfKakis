import 'package:flutter/material.dart';

import 'widgets/tee_time_calendar_strip.dart';
import 'widgets/tee_time_slot_grid.dart';

class BookingSubmissionView extends StatefulWidget {
  const BookingSubmissionView({super.key});

  @override
  State<BookingSubmissionView> createState() => _BookingSubmissionViewState();
}

class _BookingSubmissionViewState extends State<BookingSubmissionView> {
  static const String _defaultClub = 'Kinrara Golf Club';

  final List<String> _clubs = const [
    _defaultClub,
    'Saujana Golf & Country Club',
    'Kota Permai Golf & Country Club',
    'Mines Resort & Golf Club',
  ];

  final List<String> _times = const [
    '06:30 AM',
    '06:50 AM',
    '07:10 AM',
    '07:30 AM',
    '07:50 AM',
    '08:10 AM',
    '08:30 AM',
    '08:50 AM',
    '09:10 AM',
    '09:30 AM',
    '09:50 AM',
    '10:10 AM',
  ];

  final Set<int> _unavailableSlots = const {1, 4, 7, 10};

  late DateTime _selectedDate;
  late String _selectedClub;
  int? _selectedSlot;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateUtils.dateOnly(DateTime.now());
    _selectedClub = _defaultClub;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Submission',
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
            initialValue: _selectedClub,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            items: _clubs
                .map(
                  (club) => DropdownMenuItem(
                    value: club,
                    child: Text(club),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() {
                _selectedClub = value;
              });
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Calendar',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
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
            },
          ),
          const SizedBox(height: 20),
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
              _LegendDot(color: Colors.white, label: 'Open'),
              const SizedBox(width: 10),
              _LegendDot(color: theme.colorScheme.primary, label: 'Selected'),
            ],
          ),
          const SizedBox(height: 10),
          TeeTimeSlotGrid(
            slots: _times,
            selectedIndex: _selectedSlot,
            unavailableIndices: _unavailableSlots,
            onSelected: (index) {
              setState(() {
                _selectedSlot = index;
              });
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _selectedSlot == null ? null : () {},
              child: const Text('Continue Booking'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
  });

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
