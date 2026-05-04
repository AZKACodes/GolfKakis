import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:golf_kakis/features/booking/submission/detail/view/widgets/add_on/booking_submission_add_on_selection.dart';
import 'package:golf_kakis/features/booking/submission/detail/view/widgets/booking_submission_detail_counter_control.dart';
import 'package:golf_kakis/features/booking/submission/detail/view/widgets/booking_submission_detail_selection_summary.dart';
import 'package:golf_kakis/features/booking/submission/detail/viewmodel/booking_submission_detail_view_contract.dart';
import 'package:golf_kakis/features/booking/submission/detail/viewmodel/booking_submission_detail_view_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_submission_player_model.dart';
import 'package:golf_kakis/features/foundation/model/profile/profile_friend_model.dart';
import 'package:golf_kakis/features/foundation/util/currency_util.dart';
import 'package:golf_kakis/features/foundation/util/phone_util.dart';

const double _compactDetailPhoneInputHeight = 54;

class BookingSubmissionDetailContent extends StatefulWidget {
  const BookingSubmissionDetailContent({
    required this.viewModel,
    required this.state,
    required this.savedFriends,
    required this.isLoadingFriends,
    required this.onSaveFriend,
    super.key,
  });

  final BookingSubmissionDetailViewModel viewModel;
  final BookingSubmissionDetailDataLoaded state;
  final List<ProfileFriendModel> savedFriends;
  final bool isLoadingFriends;
  final Future<void> Function(ProfileFriendModel friend) onSaveFriend;

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
  bool _isSyncScheduled = false;

  @override
  void initState() {
    super.initState();
    _schedulePlayerControllerSync();
  }

  @override
  void didUpdateWidget(covariant BookingSubmissionDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    _schedulePlayerControllerSync();
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
              caddieCount: state.caddieCount,
              golfCartCount: state.golfCartCount,
              playerCount: state.playerCount,
              isForcedSharedCaddieSlot: state.isForcedSharedCaddieSlot,
              onCaddieCountChanged: (value) =>
                  widget.viewModel.onUserIntent(OnCaddieCountChanged(value)),
              onGolfCartCountChanged: (value) =>
                  widget.viewModel.onUserIntent(OnGolfCartCountChanged(value)),
            ),
            const SizedBox(height: 16),
            _PlayerManagementSummaryCard(
              playerCount: state.playerCount,
              playerDetails: state.playerDetails,
              isLoadingFriends: widget.isLoadingFriends,
              friendCount: widget.savedFriends.length,
              onManagePlayers: () => _showPlayerManagementSheet(context),
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
                  ..._buildCategoryCostRows(state),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  _CostRow(
                    label: 'Total',
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

  void _schedulePlayerControllerSync() {
    if (_isSyncScheduled) {
      return;
    }

    _isSyncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isSyncScheduled = false;
      if (!mounted) {
        return;
      }
      _syncPlayerControllers(widget.state.playerDetails);
    });
  }

  Future<void> _showPlayerManagementSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.92,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manage Players',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pick a saved Golf Kaki or add a new golfer here. New golfers can be saved back into your friend list.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListenableBuilder(
                      listenable: widget.viewModel,
                      builder: (context, _) {
                        final state = widget.viewModel.viewState;
                        if (state is! BookingSubmissionDetailDataLoaded) {
                          return const SizedBox.shrink();
                        }

                        return SingleChildScrollView(
                          child: _PlayerDetailsSection(
                            playerCount: state.playerCount,
                            playerDetails: state.playerDetails,
                            nameControllers: _playerNameControllers,
                            phoneControllers: _playerPhoneControllers,
                            countryCodes: _playerCountryCodes,
                            savedFriends: widget.savedFriends,
                            isLoadingFriends: widget.isLoadingFriends,
                            onPickFriend: _showFriendPickerSheet,
                            onSaveFriend: _savePlayerAsFriend,
                            onCategoryChanged: (index, value) =>
                                widget.viewModel.onUserIntent(
                                  OnPlayerCategoryChanged(
                                    index: index,
                                    value: value,
                                  ),
                                ),
                            onNameChanged: (index, value) =>
                                widget.viewModel.onUserIntent(
                                  OnPlayerNameChanged(
                                    index: index,
                                    value: value,
                                  ),
                                ),
                            onPhoneChanged: (index, value) =>
                                widget.viewModel.onUserIntent(
                                  OnPlayerPhoneNumberChanged(
                                    index: index,
                                    value: value,
                                  ),
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showFriendPickerSheet(
    BuildContext context,
    int playerIndex,
  ) async {
    final selectedFriend = await showModalBottomSheet<ProfileFriendModel>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _BookingFriendPickerSheet(
        friends: widget.savedFriends,
        isLoading: widget.isLoadingFriends,
      ),
    );

    if (!mounted || selectedFriend == null) {
      return;
    }

    widget.viewModel.onUserIntent(
      OnPlayerNameChanged(
        index: playerIndex,
        value: selectedFriend.effectiveDisplayName,
      ),
    );
    widget.viewModel.onUserIntent(
      OnPlayerPhoneNumberChanged(
        index: playerIndex,
        value: selectedFriend.phoneNumber,
      ),
    );
  }

  Future<void> _savePlayerAsFriend(int playerIndex) async {
    if (playerIndex < 0 || playerIndex >= widget.state.playerDetails.length) {
      return;
    }

    final player = widget.state.playerDetails[playerIndex];
    final normalizedPhoneNumber = player.phoneNumber.trim();
    final displayName = player.name.trim();
    if (displayName.isEmpty || normalizedPhoneNumber.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Enter the player name and phone number first.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    final contactKey = normalizedPhoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final friend = ProfileFriendModel(
      contactKey: contactKey.isEmpty ? normalizedPhoneNumber : contactKey,
      displayName: displayName,
      phoneNumber: normalizedPhoneNumber,
    );
    await widget.onSaveFriend(friend);
  }

  List<Widget> _buildCategoryCostRows(BookingSubmissionDetailDataLoaded state) {
    final rows = <Widget>[];

    void addRow({
      required int count,
      required String label,
      required double unitPrice,
    }) {
      if (count <= 0) {
        return;
      }
      if (rows.isNotEmpty) {
        rows.add(const SizedBox(height: 8));
      }
      final unitPriceLabel = CurrencyUtil.formatPrice(
        unitPrice,
        state.currency,
      );
      rows.add(
        _CostRow(
          label: '$label - ${count}x $unitPriceLabel',
          value: CurrencyUtil.formatPrice(count * unitPrice, state.currency),
        ),
      );
    }

    addRow(
      count: state.normalPlayerCount,
      label: 'Normal',
      unitPrice: state.normalPricePerPerson,
    );
    addRow(
      count: state.seniorPlayerCount,
      label: 'Senior',
      unitPrice: state.seniorPricePerPerson,
    );
    addRow(
      count: state.juniorPlayerCount,
      label: 'Junior',
      unitPrice: state.juniorPricePerPerson,
    );
    if (state.buggySurcharge > 0) {
      if (rows.isNotEmpty) {
        rows.add(const SizedBox(height: 8));
      }
      rows.add(
        _CostRow(
          label:
              'Buggy surcharge - ${state.buggySurchargeUnitCount}x ${CurrencyUtil.formatPrice(40, state.currency)}',
          value: state.buggySurchargeLabel,
        ),
      );
    }

    return rows;
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
    required this.caddieCount,
    required this.golfCartCount,
    required this.playerCount,
    required this.isForcedSharedCaddieSlot,
    required this.onCaddieCountChanged,
    required this.onGolfCartCountChanged,
  });

  final int caddieCount;
  final int golfCartCount;
  final int playerCount;
  final bool isForcedSharedCaddieSlot;
  final ValueChanged<int> onCaddieCountChanged;
  final ValueChanged<int> onGolfCartCountChanged;

  @override
  Widget build(BuildContext context) {
    return BookingSubmissionAddOnSelection(
      title: 'Round Preferences',
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
              'For tee times between 2:00 PM and 2:30 PM, caddie and buggy counts may be adjusted by the golf club.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF7A5200),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        _CounterPreferenceRow(
          label: 'Caddies',
          description: 'Subject prior to Golf Club Availability',
          trailing: BookingSubmissionDetailCounterControl(
            value: caddieCount,
            minValue: 0,
            onChanged: (value) {
              final nextValue = value.clamp(0, playerCount);
              onCaddieCountChanged(nextValue);
            },
          ),
        ),
        const Divider(height: 1),
        _CounterPreferenceRow(
          label: 'Buggies',
          description: 'Subject prior to Golf Club Availability',
          trailing: BookingSubmissionDetailCounterControl(
            value: golfCartCount,
            minValue: _defaultGolfCartCount(playerCount),
            onChanged: (value) {
              final nextValue = value.clamp(
                _defaultGolfCartCount(playerCount),
                _maxGolfCartCount(playerCount),
              );
              onGolfCartCountChanged(nextValue);
            },
          ),
        ),
      ],
    );
  }
}

class _CounterPreferenceRow extends StatelessWidget {
  const _CounterPreferenceRow({
    required this.label,
    required this.description,
    required this.trailing,
  });

  final String label;
  final String description;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}

class _PlayerManagementSummaryCard extends StatelessWidget {
  const _PlayerManagementSummaryCard({
    required this.playerCount,
    required this.playerDetails,
    required this.isLoadingFriends,
    required this.friendCount,
    required this.onManagePlayers,
  });

  final int playerCount;
  final List<BookingSubmissionPlayerModel> playerDetails;
  final bool isLoadingFriends;
  final int friendCount;
  final VoidCallback onManagePlayers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedPlayers = playerDetails
        .where((player) => player.isComplete)
        .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE7FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Players',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: onManagePlayers,
                icon: const Icon(Icons.group_add_outlined),
                label: const Text('Manage'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _PlayerSummaryPill(
                label: 'Players',
                value: '$completedPlayers / $playerCount ready',
                icon: Icons.groups_2_outlined,
              ),
            ],
          ),
          if (playerDetails.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...playerDetails.indexed.take(3).map((entry) {
              final index = entry.$1;
              final player = entry.$2;
              final name = player.name.trim().isEmpty
                  ? 'Player ${index + 1}'
                  : player.name.trim();
              final subtitle = player.phoneNumber.trim().isEmpty
                  ? _playerCategoryDisplayName(player.category)
                  : '${_playerCategoryDisplayName(player.category)} • ${player.phoneNumber}';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _PlayerPreviewRow(name: name, subtitle: subtitle),
              );
            }),
            if (playerDetails.length > 3)
              Text(
                '+${playerDetails.length - 3} more players',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
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
    required this.savedFriends,
    required this.isLoadingFriends,
    required this.onPickFriend,
    required this.onSaveFriend,
    required this.onCategoryChanged,
    required this.onNameChanged,
    required this.onPhoneChanged,
  });

  final int playerCount;
  final List<BookingSubmissionPlayerModel> playerDetails;
  final List<TextEditingController> nameControllers;
  final List<TextEditingController> phoneControllers;
  final List<PhoneCountryCodeOption> countryCodes;
  final List<ProfileFriendModel> savedFriends;
  final bool isLoadingFriends;
  final Future<void> Function(BuildContext context, int index) onPickFriend;
  final Future<void> Function(int index) onSaveFriend;
  final void Function(int index, String value) onCategoryChanged;
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
            _PlayerQuickActionsRow(
              isLoadingFriends: isLoadingFriends,
              hasSavedFriends: savedFriends.isNotEmpty,
              onPickFriend: () => onPickFriend(context, index),
              onSaveFriend: () => onSaveFriend(index),
            ),
            const SizedBox(height: 12),
            _PlayerCategorySelector(
              value: index < playerDetails.length
                  ? playerDetails[index].category
                  : 'normal',
              onChanged: (value) => onCategoryChanged(index, value),
            ),
            const SizedBox(height: 12),
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

class _PlayerCategorySelector extends StatelessWidget {
  const _PlayerCategorySelector({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: Row(
        children: _playerCategoryOptions.map((option) {
          final isSelected =
              _normalizePlayerCategoryValue(value) == option.value;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onChanged(option.value),
                child: Ink(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE8F5EC)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0D7A3A)
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    option.label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: isSelected
                          ? const Color(0xFF0D7A3A)
                          : const Color(0xFF17397C),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PlayerSummaryPill extends StatelessWidget {
  const _PlayerSummaryPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF17397C)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.black54,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0A1F1A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlayerQuickActionsRow extends StatelessWidget {
  const _PlayerQuickActionsRow({
    required this.isLoadingFriends,
    required this.hasSavedFriends,
    required this.onPickFriend,
    required this.onSaveFriend,
  });

  final bool isLoadingFriends;
  final bool hasSavedFriends;
  final VoidCallback onPickFriend;
  final VoidCallback onSaveFriend;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PlayerActionCard(
            title: isLoadingFriends ? 'Loading Golf Kakis' : 'Choose Golf Kaki',
            subtitle: isLoadingFriends
                ? 'Fetching saved golfers'
                : 'Pull from your saved list',
            icon: Icons.auto_awesome_mosaic_outlined,
            backgroundColor: const Color(0xFFF6F1FF),
            borderColor: const Color(0xFFE1D2FF),
            iconColor: const Color(0xFF5B3FD6),
            onTap: hasSavedFriends && !isLoadingFriends ? onPickFriend : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PlayerActionCard(
            title: 'Save Golf Kaki',
            subtitle: 'Keep this golfer for later',
            icon: Icons.bookmark_add_outlined,
            backgroundColor: const Color(0xFFEAF7F0),
            borderColor: const Color(0xFFCBE8D6),
            iconColor: const Color(0xFF0D7A3A),
            onTap: onSaveFriend,
          ),
        ),
      ],
    );
  }
}

class _PlayerActionCard extends StatelessWidget {
  const _PlayerActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isEnabled ? backgroundColor : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isEnabled ? borderColor : const Color(0x14000000),
            ),
            boxShadow: isEnabled
                ? const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    ),
                  ]
                : const <BoxShadow>[],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: isEnabled ? 0.9 : 0.6),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isEnabled ? Colors.black87 : Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isEnabled ? Colors.black54 : Colors.black38,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerPreviewRow extends StatelessWidget {
  const _PlayerPreviewRow({required this.name, required this.subtitle});

  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0FF),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            _initialsFromName(name),
            style: theme.textTheme.labelLarge?.copyWith(
              color: const Color(0xFF17397C),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BookingFriendPickerSheet extends StatefulWidget {
  const _BookingFriendPickerSheet({
    required this.friends,
    required this.isLoading,
  });

  final List<ProfileFriendModel> friends;
  final bool isLoading;

  @override
  State<_BookingFriendPickerSheet> createState() =>
      _BookingFriendPickerSheetState();
}

class _BookingFriendPickerSheetState extends State<_BookingFriendPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = _query.trim().toLowerCase();
    final filteredFriends = widget.friends.where((friend) {
      if (normalizedQuery.isEmpty) {
        return true;
      }

      return friend.displayName.toLowerCase().contains(normalizedQuery) ||
          friend.effectiveDisplayName.toLowerCase().contains(normalizedQuery) ||
          friend.phoneNumber.toLowerCase().contains(normalizedQuery);
    }).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Golf Kaki',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Pick someone from your saved Golf Kakis list.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Search by name or phone',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (widget.isLoading)
                const LinearProgressIndicator()
              else if (filteredFriends.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      widget.friends.isEmpty
                          ? 'No saved Golf Kakis yet. Save a player to create one.'
                          : 'No golfers match your search.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: filteredFriends.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final friend = filteredFriends[index];
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.of(context).pop(friend),
                          child: Ink(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F9FC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0x14000000),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xFFE8F0FF),
                                  foregroundColor: const Color(0xFF17397C),
                                  child: Text(friend.initials),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        friend.effectiveDisplayName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        friend.phoneNumber,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded),
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

class _PlayerCategoryOption {
  const _PlayerCategoryOption({required this.value, required this.label});

  final String value;
  final String label;
}

const List<_PlayerCategoryOption> _playerCategoryOptions =
    <_PlayerCategoryOption>[
      _PlayerCategoryOption(value: 'normal', label: 'Normal'),
      _PlayerCategoryOption(value: 'senior', label: 'Senior'),
      _PlayerCategoryOption(value: 'junior', label: 'Junior'),
    ];

String _normalizePlayerCategoryValue(String value) {
  switch (value.trim().toLowerCase()) {
    case 'senior':
    case 'senior_citizen':
      return 'senior';
    case 'junior':
      return 'junior';
    case 'normal':
    default:
      return 'normal';
  }
}

String _playerCategoryDisplayName(String value) {
  switch (_normalizePlayerCategoryValue(value)) {
    case 'senior':
      return 'Senior';
    case 'junior':
      return 'Junior';
    case 'normal':
    default:
      return 'Normal';
  }
}

String _initialsFromName(String value) {
  final parts = value
      .split(' ')
      .where((part) => part.trim().isNotEmpty)
      .toList();
  if (parts.isEmpty) {
    return 'GK';
  }
  if (parts.length == 1) {
    final part = parts.first;
    return part.substring(0, part.length >= 2 ? 2 : 1).toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
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

int _defaultGolfCartCount(int playerCount) {
  if (playerCount <= 2) {
    return 1;
  }
  if (playerCount <= 4) {
    return 2;
  }
  return 3;
}

int _maxGolfCartCount(int playerCount) {
  return playerCount;
}
