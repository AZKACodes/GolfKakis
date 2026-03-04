import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xxx_demo_app/features/booking/submission/detail/viewmodel/booking_submission_detail_view_contract.dart';
import 'package:xxx_demo_app/features/booking/submission/detail/viewmodel/booking_submission_detail_view_model.dart';

class BookingSubmissionDetailView extends StatefulWidget {
  const BookingSubmissionDetailView({required this.viewModel, super.key});

  final BookingSubmissionDetailViewModel viewModel;

  @override
  State<BookingSubmissionDetailView> createState() =>
      _BookingSubmissionDetailViewState();
}

class _BookingSubmissionDetailViewState
    extends State<BookingSubmissionDetailView> {
  late final TextEditingController _hostNameController;
  late final TextEditingController _hostPhoneController;

  @override
  void initState() {
    super.initState();
    final state = _currentState;
    _hostNameController = TextEditingController(text: state.hostName);
    _hostPhoneController = TextEditingController(text: state.hostPhoneNumber);
  }

  @override
  void dispose() {
    _hostNameController.dispose();
    _hostPhoneController.dispose();
    super.dispose();
  }

  BookingSubmissionDetailDataLoaded get _currentState {
    final state = widget.viewModel.viewState;
    if (state is BookingSubmissionDetailDataLoaded) {
      return state;
    }

    return const BookingSubmissionDetailDataLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final state = _currentState;
        final theme = Theme.of(context);

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Host Information',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Fill in the host contact and round requirements before confirming the booking.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
                _BookingSelectionSummary(state: state),
                const SizedBox(height: 20),
                TextField(
                  controller: _hostNameController,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (value) => widget.viewModel.onUserIntent(
                    OnHostNameChanged(value),
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Host Name',
                    hintText: 'Enter host name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _hostPhoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\- ]')),
                  ],
                  onChanged: (value) => widget.viewModel.onUserIntent(
                    OnHostPhoneNumberChanged(value),
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter phone number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                _CounterCard(
                  title: 'Players',
                  subtitle: 'How many players are joining this booking?',
                  value: state.playerCount,
                  minValue: 1,
                  onChanged: (value) => widget.viewModel.onUserIntent(
                    OnPlayerCountChanged(value),
                  ),
                ),
                const SizedBox(height: 16),
                _CounterSection(
                  title: 'Support',
                  children: [
                    _CounterTile(
                      label: 'Caddies',
                      value: state.caddieCount,
                      onChanged: (value) => widget.viewModel.onUserIntent(
                        OnCaddieCountChanged(value),
                      ),
                    ),
                    const Divider(height: 1),
                    _CounterTile(
                      label: 'Golf Carts',
                      value: state.golfCartCount,
                      onChanged: (value) => widget.viewModel.onUserIntent(
                        OnGolfCartCountChanged(value),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BookingSelectionSummary extends StatelessWidget {
  const _BookingSelectionSummary({required this.state});

  final BookingSubmissionDetailDataLoaded state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8F4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB9D6B9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Booking',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _SummaryRow(label: 'Golf Club', value: state.golfClubSlug),
          const SizedBox(height: 6),
          _SummaryRow(label: 'Tee Time', value: state.teeTimeSlot),
          const SizedBox(height: 6),
          _SummaryRow(
            label: 'Guest ID',
            value: state.guestId?.isNotEmpty == true ? state.guestId! : 'N/A',
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        SizedBox(
          width: 84,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _CounterSection extends StatelessWidget {
  const _CounterSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _CounterCard extends StatelessWidget {
  const _CounterCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.minValue = 0,
  });

  final String title;
  final String subtitle;
  final int value;
  final int minValue;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _CounterControl(
            value: value,
            minValue: minValue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _CounterTile extends StatelessWidget {
  const _CounterTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _CounterControl(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _CounterControl extends StatelessWidget {
  const _CounterControl({
    required this.value,
    required this.onChanged,
    this.minValue = 0,
  });

  final int value;
  final int minValue;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.outlined(
          onPressed: value > minValue ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          width: 32,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        IconButton.filled(
          onPressed: () => onChanged(value + 1),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
