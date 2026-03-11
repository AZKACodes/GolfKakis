import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xxx_demo_app/features/booking/submission/detail/view/widgets/booking_submission_add_on_selection.dart';
import 'package:xxx_demo_app/features/booking/submission/detail/view/widgets/booking_submission_add_on_selection_item.dart';
import 'package:xxx_demo_app/features/booking/submission/detail/view/widgets/booking_submission_detail_player_selection.dart';
import 'package:xxx_demo_app/features/booking/submission/detail/view/widgets/booking_submission_detail_selection_summary.dart';
import 'package:xxx_demo_app/features/booking/submission/detail/viewmodel/booking_submission_detail_view_contract.dart';
import 'package:xxx_demo_app/features/booking/submission/detail/viewmodel/booking_submission_detail_view_model.dart';
import 'package:xxx_demo_app/features/foundation/model/booking/booking_submission_player_model.dart';

class BookingSubmissionDetailContent extends StatefulWidget {
  const BookingSubmissionDetailContent({
    required this.viewModel,
    required this.state,
    super.key,
  });

  final BookingSubmissionDetailViewModel viewModel;
  final BookingSubmissionDetailDataLoaded state;

  @override
  State<BookingSubmissionDetailContent> createState() =>
      _BookingSubmissionDetailContentState();
}

class _BookingSubmissionDetailContentState
    extends State<BookingSubmissionDetailContent> {
  late final TextEditingController _hostNameController;
  late final TextEditingController _hostPhoneController;
  final List<TextEditingController> _playerNameControllers =
      <TextEditingController>[];
  final List<TextEditingController> _playerPhoneControllers =
      <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    _hostNameController = TextEditingController(text: widget.state.hostName);
    _hostPhoneController = TextEditingController(
      text: widget.state.hostPhoneNumber,
    );
    _syncPlayerControllers(widget.state.playerDetails);
  }

  @override
  void didUpdateWidget(covariant BookingSubmissionDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_hostNameController.text != widget.state.hostName) {
      _hostNameController.text = widget.state.hostName;
    }

    if (_hostPhoneController.text != widget.state.hostPhoneNumber) {
      _hostPhoneController.text = widget.state.hostPhoneNumber;
    }

    _syncPlayerControllers(widget.state.playerDetails);
  }

  @override
  void dispose() {
    _hostNameController.dispose();
    _hostPhoneController.dispose();
    for (final controller in _playerNameControllers) {
      controller.dispose();
    }
    for (final controller in _playerPhoneControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = widget.state;

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
            BookingSubmissionDetailSelectionSummary(state: state),
            const SizedBox(height: 20),
            TextField(
              controller: _hostNameController,
              textCapitalization: TextCapitalization.words,
              onChanged: (value) =>
                  widget.viewModel.onUserIntent(OnHostNameChanged(value)),
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
            BookingSubmissionDetailPlayerSelection(
              title: 'Players',
              subtitle:
                  'How many players are joining this booking? Max ${state.maxPlayerCount} for this tee time.',
              value: state.playerCount,
              minValue: 1,
              onChanged: (value) =>
                  widget.viewModel.onUserIntent(OnPlayerCountChanged(value)),
            ),
            const SizedBox(height: 16),
            _PlayerDetailsSection(
              playerCount: state.playerCount,
              nameControllers: _playerNameControllers,
              phoneControllers: _playerPhoneControllers,
              onNameChanged: (index, value) => widget.viewModel.onUserIntent(
                OnPlayerNameChanged(index: index, value: value),
              ),
              onPhoneChanged: (index, value) => widget.viewModel.onUserIntent(
                OnPlayerPhoneNumberChanged(index: index, value: value),
              ),
            ),
            const SizedBox(height: 16),
            BookingSubmissionAddOnSelection(
              title: 'Support',
              children: [
                BookingSubmissionAddOnSelectionItem(
                  label: 'Caddies',
                  value: state.caddieCount,
                  onChanged: (value) => widget.viewModel.onUserIntent(
                    OnCaddieCountChanged(value),
                  ),
                ),
                const Divider(height: 1),
                BookingSubmissionAddOnSelectionItem(
                  label: 'Golf Carts',
                  value: state.golfCartCount,
                  onChanged: (value) => widget.viewModel.onUserIntent(
                    OnGolfCartCountChanged(value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FBF7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x14000000)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Cost',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _CostRow(
                    label: 'Price per person',
                    value: state.pricePerPersonLabel,
                  ),
                  const SizedBox(height: 8),
                  _CostRow(label: 'Players', value: '${state.playerCount}'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  _CostRow(
                    label: 'Estimated total',
                    value: state.totalCostLabel,
                    emphasize: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _syncPlayerControllers(List<BookingSubmissionPlayerModel> players) {
    while (_playerNameControllers.length < players.length) {
      _playerNameControllers.add(TextEditingController());
      _playerPhoneControllers.add(TextEditingController());
    }

    while (_playerNameControllers.length > players.length) {
      _playerNameControllers.removeLast().dispose();
      _playerPhoneControllers.removeLast().dispose();
    }

    for (var index = 0; index < players.length; index++) {
      final player = players[index];
      if (_playerNameControllers[index].text != player.name) {
        _playerNameControllers[index].text = player.name;
      }
      if (_playerPhoneControllers[index].text != player.phoneNumber) {
        _playerPhoneControllers[index].text = player.phoneNumber;
      }
    }
  }
}

class _CostRow extends StatelessWidget {
  const _CostRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: emphasize ? const Color(0xFF0D7A3A) : Colors.black54,
            fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: emphasize ? const Color(0xFF0D7A3A) : Colors.black87,
            fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PlayerDetailsSection extends StatelessWidget {
  const _PlayerDetailsSection({
    required this.playerCount,
    required this.nameControllers,
    required this.phoneControllers,
    required this.onNameChanged,
    required this.onPhoneChanged,
  });

  final int playerCount;
  final List<TextEditingController> nameControllers;
  final List<TextEditingController> phoneControllers;
  final void Function(int index, String value) onNameChanged;
  final void Function(int index, String value) onPhoneChanged;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Player Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Fill in the name and phone number for each player.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          for (var index = 0; index < playerCount; index++) ...[
            Text(
              'Player ${index + 1}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameControllers[index],
              textCapitalization: TextCapitalization.words,
              onChanged: (value) => onNameChanged(index, value),
              decoration: InputDecoration(
                labelText: 'Player ${index + 1} Name',
                hintText: 'Enter player name',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneControllers[index],
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+\- ]')),
              ],
              onChanged: (value) => onPhoneChanged(index, value),
              decoration: InputDecoration(
                labelText: 'Player ${index + 1} Phone',
                hintText: 'Enter phone number',
                border: const OutlineInputBorder(),
              ),
            ),
            if (index != playerCount - 1) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
            ],
          ],
        ],
      ),
    );
  }
}
