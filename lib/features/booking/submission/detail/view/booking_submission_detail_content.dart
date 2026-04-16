import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:golf_kakis/features/booking/submission/detail/view/widgets/add_on/booking_submission_add_on_selection.dart';
import 'package:golf_kakis/features/booking/submission/detail/view/widgets/booking_submission_detail_selection_summary.dart';
import 'package:golf_kakis/features/booking/submission/detail/viewmodel/booking_submission_detail_view_contract.dart';
import 'package:golf_kakis/features/booking/submission/detail/viewmodel/booking_submission_detail_view_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_submission_player_model.dart';
import 'package:golf_kakis/features/foundation/util/phone_util.dart';

const double _compactDetailPhoneInputHeight = 54;

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
  final List<TextEditingController> _playerNameControllers =
      <TextEditingController>[];
  final List<TextEditingController> _playerPhoneControllers =
      <TextEditingController>[];
  final List<PhoneCountryCodeOption> _playerCountryCodes =
      <PhoneCountryCodeOption>[];

  @override
  void initState() {
    super.initState();
    _syncPlayerControllers(widget.state.playerDetails);
  }

  @override
  void didUpdateWidget(covariant BookingSubmissionDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    _syncPlayerControllers(widget.state.playerDetails);
  }

  @override
  void dispose() {
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
              'Player Information',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Review the booking details and complete the player list before confirming the booking.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: state.isHoldExpired
                    ? const Color(0xFFFDECEC)
                    : const Color(0xFFFFF6E8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: state.isHoldExpired
                      ? const Color(0xFFE7A1A1)
                      : const Color(0xFFFFD58A),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    state.isHoldExpired
                        ? Icons.timer_off_outlined
                        : Icons.timer_outlined,
                    color: state.isHoldExpired
                        ? const Color(0xFF8A3D3D)
                        : const Color(0xFF7A5200),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.isHoldExpired
                          ? 'Booking session expired'
                          : 'Complete your booking within ${state.holdCountdownLabel}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: state.isHoldExpired
                            ? const Color(0xFF8A3D3D)
                            : const Color(0xFF7A5200),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            BookingSubmissionDetailSelectionSummary(state: state),
            const SizedBox(height: 16),
            _RoundPreferencesSection(
              caddiePreference: state.effectiveCaddiePreference,
              buggyType: state.effectiveBuggyType,
              buggySharingPreference: state.buggySharingPreference,
              isForcedSharedCaddieSlot: state.isForcedSharedCaddieSlot,
              onCaddiePreferenceChanged: (value) => widget.viewModel
                  .onUserIntent(OnSelectCaddiePreference(value)),
              onBuggySharingPreferenceChanged: (value) => widget.viewModel
                  .onUserIntent(OnSelectBuggySharingPreference(value)),
            ),
            const SizedBox(height: 16),
            _PlayerDetailsSection(
              playerCount: state.playerCount,
              playerDetails: state.playerDetails,
              nameControllers: _playerNameControllers,
              phoneControllers: _playerPhoneControllers,
              countryCodes: _playerCountryCodes,
              onNameChanged: (index, value) => widget.viewModel.onUserIntent(
                OnPlayerNameChanged(index: index, value: value),
              ),
              onPhoneChanged: (index, value) => widget.viewModel.onUserIntent(
                OnPlayerPhoneNumberChanged(index: index, value: value),
              ),
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
      _playerCountryCodes.add(PhoneUtil.defaultCountryCodeOption);
    }

    while (_playerNameControllers.length > players.length) {
      _playerNameControllers.removeLast().dispose();
      _playerPhoneControllers.removeLast().dispose();
      _playerCountryCodes.removeLast();
    }

    for (var index = 0; index < players.length; index++) {
      final player = players[index];
      final phoneParts = PhoneUtil.splitPhoneNumber(player.phoneNumber);
      if (_playerNameControllers[index].text != player.name) {
        _playerNameControllers[index].text = player.name;
      }
      if (_playerCountryCodes[index] != phoneParts.countryCode) {
        _playerCountryCodes[index] = phoneParts.countryCode;
      }
      if (_playerPhoneControllers[index].text != phoneParts.localNumber) {
        _playerPhoneControllers[index].text = phoneParts.localNumber;
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

class _RoundPreferencesSection extends StatelessWidget {
  const _RoundPreferencesSection({
    required this.caddiePreference,
    required this.buggyType,
    required this.buggySharingPreference,
    required this.isForcedSharedCaddieSlot,
    required this.onCaddiePreferenceChanged,
    required this.onBuggySharingPreferenceChanged,
  });

  final String caddiePreference;
  final String buggyType;
  final String buggySharingPreference;
  final bool isForcedSharedCaddieSlot;
  final ValueChanged<String> onCaddiePreferenceChanged;
  final ValueChanged<String> onBuggySharingPreferenceChanged;

  @override
  Widget build(BuildContext context) {
    return BookingSubmissionAddOnSelection(
      children: [
        if (isForcedSharedCaddieSlot)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6E8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFD58A)),
            ),
            child: Text(
              'For tee times between 2:00 PM and 2:30 PM, caddie arrangement is automatically Shared and buggy type is Jumbo.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF7A5200),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        _SelectionPreferenceRow(
          label: 'Caddies',
          value: _caddieLabel(caddiePreference),
          enabled: !isForcedSharedCaddieSlot,
          onTap: !isForcedSharedCaddieSlot
              ? () => _showCaddiePicker(context)
              : null,
        ),
        const Divider(height: 1),
        _SelectionPreferenceRow(
          label: 'Buggy Type',
          value: _buggyTypeLabel(buggyType),
          enabled: false,
        ),
        const Divider(height: 1),
        _SelectionPreferenceRow(
          label: 'Share Buggy',
          value: _buggySharingLabel(buggySharingPreference),
          onTap: () => _showBuggySharingPicker(context),
        ),
      ],
    );
  }

  Future<void> _showCaddiePicker(BuildContext context) async {
    await _showOptionPicker(
      context: context,
      title: 'Select Caddie Arrangement',
      options: const <String>['none', 'shared', 'per_player'],
      selectedValue: caddiePreference,
      labelFor: _caddieLabel,
      onSelected: onCaddiePreferenceChanged,
    );
  }

  Future<void> _showBuggySharingPicker(BuildContext context) async {
    await _showOptionPicker(
      context: context,
      title: 'Select Buggy Sharing',
      options: const <String>['shared', 'mix'],
      selectedValue: buggySharingPreference,
      labelFor: _buggySharingLabel,
      onSelected: onBuggySharingPreferenceChanged,
    );
  }
}

class _SelectionPreferenceRow extends StatelessWidget {
  const _SelectionPreferenceRow({
    required this.label,
    required this.value,
    this.enabled = true,
    this.onTap,
  });

  final String label;
  final String value;
  final bool enabled;
  final VoidCallback? onTap;

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
                color: enabled ? Colors.black87 : Colors.black54,
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x14000000)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: enabled ? Colors.black87 : Colors.black54,
                    ),
                  ),
                  if (enabled) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerDetailsSection extends StatelessWidget {
  const _PlayerDetailsSection({
    required this.playerCount,
    required this.playerDetails,
    required this.nameControllers,
    required this.phoneControllers,
    required this.countryCodes,
    required this.onNameChanged,
    required this.onPhoneChanged,
  });

  final int playerCount;
  final List<BookingSubmissionPlayerModel> playerDetails;
  final List<TextEditingController> nameControllers;
  final List<TextEditingController> phoneControllers;
  final List<PhoneCountryCodeOption> countryCodes;
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
            Row(
              children: [
                Text(
                  'Player ${index + 1}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                _PlayerCategoryBadge(
                  label: _playerCategoryLabel(
                    index < playerDetails.length
                        ? playerDetails[index].category
                        : 'normal',
                  ),
                ),
              ],
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
            _PlayerPhoneInputRow(
              playerLabel: 'Player ${index + 1} Phone',
              countryCode: countryCodes[index],
              controller: phoneControllers[index],
              onCountryCodeChanged: (countryCode) {
                onPhoneChanged(
                  index,
                  PhoneUtil.normalizeFullPhoneNumber(
                    countryCode: countryCode,
                    localNumber: phoneControllers[index].text,
                  ),
                );
              },
              onPhoneChanged: (value) {
                onPhoneChanged(
                  index,
                  PhoneUtil.normalizeFullPhoneNumber(
                    countryCode: countryCodes[index],
                    localNumber: value,
                  ),
                );
              },
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

class _PlayerCategoryBadge extends StatelessWidget {
  const _PlayerCategoryBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD7E3FF)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: const Color(0xFF17397C),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PlayerPhoneInputRow extends StatefulWidget {
  const _PlayerPhoneInputRow({
    required this.playerLabel,
    required this.countryCode,
    required this.controller,
    required this.onCountryCodeChanged,
    required this.onPhoneChanged,
  });

  final String playerLabel;
  final PhoneCountryCodeOption countryCode;
  final TextEditingController controller;
  final ValueChanged<PhoneCountryCodeOption> onCountryCodeChanged;
  final ValueChanged<String> onPhoneChanged;

  @override
  State<_PlayerPhoneInputRow> createState() => _PlayerPhoneInputRowState();
}

class _PlayerPhoneInputRowState extends State<_PlayerPhoneInputRow> {
  late PhoneCountryCodeOption _selectedCountryCode;

  @override
  void initState() {
    super.initState();
    _selectedCountryCode = widget.countryCode;
  }

  @override
  void didUpdateWidget(covariant _PlayerPhoneInputRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedCountryCode != widget.countryCode) {
      _selectedCountryCode = widget.countryCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailCountryCodePickerButton(
          value: _selectedCountryCode,
          onSelected: (value) {
            setState(() {
              _selectedCountryCode = value;
            });
            widget.onCountryCodeChanged(value);
          },
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: _compactDetailPhoneInputHeight,
            child: TextField(
              controller: widget.controller,
              keyboardType: TextInputType.phone,
              textAlignVertical: TextAlignVertical.center,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: widget.onPhoneChanged,
              decoration: InputDecoration(
                hintText: widget.playerLabel,
                prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
                filled: true,
                fillColor: const Color(0xFFF6F8FC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailCountryCodePickerButton extends StatelessWidget {
  const _DetailCountryCodePickerButton({
    required this.value,
    required this.onSelected,
  });

  final PhoneCountryCodeOption value;
  final ValueChanged<PhoneCountryCodeOption> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 118,
      height: _compactDetailPhoneInputHeight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showCountryCodeBottomSheet(context),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F8FC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value.compactLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCountryCodeBottomSheet(BuildContext context) async {
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
                'Select Country Code',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose the dialing code before entering the phone number.',
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
                  itemCount: PhoneUtil.countryCodeOptions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final option = PhoneUtil.countryCodeOptions[index];
                    final isSelected = option.dialCode == value.dialCode;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          Navigator.of(context).pop();
                          onSelected(option);
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
                                child: Text(
                                  option.bottomSheetLabel,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF0D7A3A),
                                ),
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

String _caddieLabel(String value) {
  switch (value) {
    case 'none':
      return 'None';
    case 'shared':
      return 'Shared';
    case 'per_player':
      return 'Per Player';
    default:
      return value;
  }
}

String _buggyTypeLabel(String value) {
  switch (value) {
    case 'jumbo':
      return 'Jumbo';
    case 'normal':
      return 'Normal';
    default:
      return value;
  }
}

String _buggySharingLabel(String value) {
  switch (value) {
    case 'shared':
      return 'Shared';
    case 'mix':
    case 'mixed':
      return 'Mixed';
    default:
      return value;
  }
}

String _playerCategoryLabel(String value) {
  switch (value) {
    case 'senior':
    case 'senior_citizen':
      return 'Senior Citizen';
    case 'normal':
    default:
      return 'Normal';
  }
}

Future<void> _showOptionPicker({
  required BuildContext context,
  required String title,
  required List<String> options,
  required String selectedValue,
  required String Function(String value) labelFor,
  required ValueChanged<String> onSelected,
}) async {
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
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = option == selectedValue;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        Navigator.of(context).pop();
                        onSelected(option);
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
                              child: Text(
                                labelFor(option),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF0D7A3A),
                              ),
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
