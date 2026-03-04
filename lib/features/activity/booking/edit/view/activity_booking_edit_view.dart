import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../viewmodel/activity_booking_edit_view_contract.dart';

class ActivityBookingEditView extends StatefulWidget {
  const ActivityBookingEditView({
    required this.state,
    required this.onPlayerNameChanged,
    required this.onPlayerPhoneChanged,
    required this.onSaveClick,
    super.key,
  });

  final ActivityBookingEditViewState state;
  final void Function(int index, String value) onPlayerNameChanged;
  final void Function(int index, String value) onPlayerPhoneChanged;
  final VoidCallback onSaveClick;

  @override
  State<ActivityBookingEditView> createState() => _ActivityBookingEditViewState();
}

class _ActivityBookingEditViewState extends State<ActivityBookingEditView> {
  final List<TextEditingController> _nameControllers = <TextEditingController>[];
  final List<TextEditingController> _phoneControllers = <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  @override
  void didUpdateWidget(covariant ActivityBookingEditView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllers();
  }

  @override
  void dispose() {
    for (final controller in _nameControllers) {
      controller.dispose();
    }
    for (final controller in _phoneControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.state.booking;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            title: 'Booking Summary',
            children: [
              _InfoRow(label: 'Booking ID', value: booking.bookingId),
              _InfoRow(label: 'Club', value: booking.courseName),
              _InfoRow(label: 'Date', value: booking.dateLabel),
              _InfoRow(label: 'Tee Time', value: booking.teeTimeSlot),
              _InfoRow(label: 'Host', value: booking.hostName),
              _InfoRow(label: 'Host Phone', value: booking.hostPhoneNumber),
              _InfoRow(label: 'Status', value: booking.statusLabel),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Editable Player Details',
            children: [
              Text(
                'Only player names and phone numbers can be changed.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < booking.playerDetails.length; i++) ...[
                Text(
                  'Player ${i + 1}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameControllers[i],
                  textCapitalization: TextCapitalization.words,
                  onChanged: (value) => widget.onPlayerNameChanged(i, value),
                  decoration: const InputDecoration(
                    labelText: 'Player Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phoneControllers[i],
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\- ]')),
                  ],
                  onChanged: (value) => widget.onPlayerPhoneChanged(i, value),
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (i != booking.playerDetails.length - 1) ...[
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                ],
              ],
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: widget.onSaveClick,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }

  void _syncControllers() {
    final players = widget.state.booking.playerDetails;

    while (_nameControllers.length < players.length) {
      _nameControllers.add(TextEditingController());
      _phoneControllers.add(TextEditingController());
    }

    while (_nameControllers.length > players.length) {
      _nameControllers.removeLast().dispose();
      _phoneControllers.removeLast().dispose();
    }

    for (var i = 0; i < players.length; i++) {
      if (_nameControllers[i].text != players[i].name) {
        _nameControllers[i].text = players[i].name;
      }
      if (_phoneControllers[i].text != players[i].phoneNumber) {
        _phoneControllers[i].text = players[i].phoneNumber;
      }
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
