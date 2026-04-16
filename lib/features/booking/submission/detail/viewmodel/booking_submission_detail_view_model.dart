import 'dart:async';

import 'package:golf_kakis/features/foundation/model/booking/booking_submission_player_model.dart';
import 'package:golf_kakis/features/foundation/util/phone_util.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import 'booking_submission_detail_view_contract.dart';

class BookingSubmissionDetailViewModel
    extends
        MviViewModel<
          BookingSubmissionDetailUserIntent,
          BookingSubmissionDetailViewState,
          BookingSubmissionDetailNavEffect
        >
    implements BookingSubmissionDetailViewContract {
  BookingSubmissionDetailViewModel();

  Timer? _holdCountdownTimer;
  bool _hasShownExpiryDialog = false;

  @override
  BookingSubmissionDetailViewState createInitialState() {
    return BookingSubmissionDetailDataLoaded.initial();
  }

  @override
  Future<void> handleIntent(BookingSubmissionDetailUserIntent intent) async {
    switch (intent) {
      case OnInit():
        final maxPlayerCount = _maxPlayerCountForSlot(intent.teeTimeSlot);
        final initialPlayerCount = intent.initialPlayerCount.clamp(
          1,
          maxPlayerCount,
        );
        final initialPhoneParts = PhoneUtil.splitPhoneNumber(
          intent.initialPlayerPhoneNumber,
        );
        emitViewState((state) {
          return _deriveState(
            getCurrentAsLoaded().copyWith(
              slotId: intent.slotId,
              bookingId: intent.bookingId,
              bookingRef: intent.bookingRef,
              holdDurationSeconds: intent.holdDurationSeconds,
              holdExpiresAt: intent.holdExpiresAt,
              playType: intent.playType,
              golfClubName: intent.golfClubName,
              golfClubSlug: intent.golfClubSlug,
              selectedDate: intent.selectedDate,
              teeTimeSlot: intent.teeTimeSlot,
              pricePerPerson: intent.pricePerPerson,
              currency: intent.currency,
              guestId: intent.guestId,
              maxPlayerCount: maxPlayerCount,
              playerCount: initialPlayerCount,
              caddiePreference: intent.caddiePreference,
              buggyType: intent.buggyType,
              buggySharingPreference: intent.buggySharingPreference,
              selectedNine: intent.selectedNine,
              golfCartCount: _defaultGolfCartCount(initialPlayerCount),
              playerDetails: _buildInitialPlayerDetails(
                playerCount: initialPlayerCount,
                playerName: intent.initialPlayerName,
                playerPhoneNumber: initialPhoneParts.localNumber.isEmpty
                    ? intent.initialPlayerPhoneNumber
                    : PhoneUtil.normalizeFullPhoneNumber(
                        countryCode: initialPhoneParts.countryCode,
                        localNumber: initialPhoneParts.localNumber,
                      ),
              ),
              remainingHoldSeconds: _remainingSecondsUntil(
                intent.holdExpiresAt,
              ),
              isHoldExpired: _remainingSecondsUntil(intent.holdExpiresAt) <= 0,
            ),
          );
        });
        _hasShownExpiryDialog = false;
        _startHoldCountdown();
      case OnBackClick():
        sendNavEffect(() => const NavigateBack());
      case OnHostNameChanged():
        emitViewState((state) {
          return _deriveState(
            _updatePlayerDetails(
              current: getCurrentAsLoaded(),
              index: 0,
              name: intent.value,
            ),
          );
        });
      case OnHostPhoneNumberChanged():
        emitViewState((state) {
          return _deriveState(
            _updatePlayerDetails(
              current: getCurrentAsLoaded(),
              index: 0,
              phoneNumber: intent.value,
            ),
          );
        });
      case OnPlayerCountChanged():
        emitViewState((state) {
          final current = getCurrentAsLoaded();
          final nextPlayerCount = intent.value.clamp(1, current.maxPlayerCount);
          return _deriveState(
            current.copyWith(
              playerCount: nextPlayerCount,
              golfCartCount: _defaultGolfCartCount(nextPlayerCount),
            ),
          );
        });
      case OnPlayerNameChanged():
        emitViewState((state) {
          return _deriveState(
            _updatePlayerDetails(
              current: getCurrentAsLoaded(),
              index: intent.index,
              name: intent.value,
            ),
          );
        });
      case OnPlayerPhoneNumberChanged():
        emitViewState((state) {
          return _deriveState(
            _updatePlayerDetails(
              current: getCurrentAsLoaded(),
              index: intent.index,
              phoneNumber: intent.value,
            ),
          );
        });
      case OnCaddieCountChanged():
        emitViewState((state) {
          final current = getCurrentAsLoaded();
          return _deriveState(
            current.copyWith(
              caddieCount: intent.value.clamp(0, current.playerCount),
            ),
          );
        });
      case OnGolfCartCountChanged():
        emitViewState((state) {
          final current = getCurrentAsLoaded();
          return _deriveState(
            current.copyWith(
              golfCartCount: intent.value.clamp(0, current.playerCount),
            ),
          );
        });
      case OnContinueClick():
        final current = getCurrentAsLoaded();
        if (!current.canContinue ||
            current.isSubmitting ||
            current.isHoldExpired ||
            current.bookingId.trim().isEmpty) {
          return;
        }
        sendNavEffect(
          () => NavigateToBookingSubmissionConfirmation(
            bookingId: current.bookingId,
            bookingRef: current.bookingRef,
            golfClubName: current.golfClubName,
            golfClubSlug: current.golfClubSlug,
            selectedDate: current.selectedDate,
            teeTimeSlot: current.teeTimeSlot,
            pricePerPerson: current.pricePerPerson,
            currency: current.currency,
            guestId: current.guestId,
            hostName: _primaryPlayer(current).name,
            hostPhoneNumber: _primaryPlayer(current).phoneNumber,
            playerCount: current.playerCount,
            caddiePreference: current.caddiePreference,
            buggyType: current.buggyType,
            buggySharingPreference: current.buggySharingPreference,
            caddieCount: current.caddieCount,
            golfCartCount: current.golfCartCount,
            playerDetails: current.playerDetails,
          ),
        );
    }
  }

  BookingSubmissionDetailDataLoaded _deriveState(
    BookingSubmissionDetailDataLoaded state,
  ) {
    final normalizedPlayerCount = state.playerCount.clamp(
      1,
      state.maxPlayerCount,
    );
    final normalizedPlayerDetails = _resizePlayerDetails(
      players: state.playerDetails,
      playerCount: normalizedPlayerCount,
    );
    final normalizedCaddieCount = state.caddieCount.clamp(
      0,
      normalizedPlayerCount,
    );
    final normalizedGolfCartCount = state.golfCartCount.clamp(
      0,
      normalizedPlayerCount,
    );

    return state.copyWith(
      playerCount: normalizedPlayerCount,
      caddieCount: normalizedCaddieCount,
      golfCartCount: normalizedGolfCartCount,
      playerDetails: normalizedPlayerDetails,
      canContinue:
          state.slotId.trim().isNotEmpty &&
          state.bookingId.trim().isNotEmpty &&
          !state.isHoldExpired &&
          normalizedPlayerDetails.length == normalizedPlayerCount &&
          normalizedPlayerDetails.every((player) => player.isComplete),
    );
  }

  void _startHoldCountdown() {
    _holdCountdownTimer?.cancel();
    _tickHoldCountdown();
    _holdCountdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tickHoldCountdown();
    });
  }

  void _tickHoldCountdown() {
    final current = getCurrentAsLoaded();
    if (current.bookingId.trim().isEmpty) {
      return;
    }

    final remainingHoldSeconds = _remainingSecondsUntil(current.holdExpiresAt);
    final isHoldExpired = remainingHoldSeconds <= 0;

    emitViewState((state) {
      return current.copyWith(
        remainingHoldSeconds: remainingHoldSeconds,
        isHoldExpired: isHoldExpired,
      );
    });

    if (isHoldExpired) {
      _holdCountdownTimer?.cancel();
      if (!_hasShownExpiryDialog) {
        _hasShownExpiryDialog = true;
        sendNavEffect(() => const ShowBookingSessionExpired());
      }
    }
  }

  int _remainingSecondsUntil(DateTime expiresAt) {
    final difference = expiresAt.difference(DateTime.now()).inSeconds;
    return difference < 0 ? 0 : difference;
  }

  BookingSubmissionDetailDataLoaded _updatePlayerDetails({
    required BookingSubmissionDetailDataLoaded current,
    required int index,
    String? name,
    String? phoneNumber,
  }) {
    final updatedPlayers = List<BookingSubmissionPlayerModel>.from(
      current.playerDetails,
    );
    if (index < 0 || index >= updatedPlayers.length) {
      return current;
    }

    updatedPlayers[index] = updatedPlayers[index].copyWith(
      name: name,
      phoneNumber: phoneNumber,
    );

    return current.copyWith(playerDetails: updatedPlayers);
  }

  List<BookingSubmissionPlayerModel> _resizePlayerDetails({
    required List<BookingSubmissionPlayerModel> players,
    required int playerCount,
  }) {
    if (players.length == playerCount) {
      return players;
    }

    if (players.length > playerCount) {
      return players.sublist(0, playerCount);
    }

    return List<BookingSubmissionPlayerModel>.generate(playerCount, (index) {
      if (index < players.length) {
        return players[index];
      }

      return const BookingSubmissionPlayerModel();
    });
  }

  List<BookingSubmissionPlayerModel> _buildInitialPlayerDetails({
    required int playerCount,
    required String playerName,
    required String playerPhoneNumber,
  }) {
    return List<BookingSubmissionPlayerModel>.generate(playerCount, (index) {
      if (index == 0) {
        return BookingSubmissionPlayerModel(
          name: playerName,
          phoneNumber: playerPhoneNumber,
        );
      }

      return const BookingSubmissionPlayerModel();
    });
  }

  BookingSubmissionPlayerModel _primaryPlayer(
    BookingSubmissionDetailDataLoaded current,
  ) {
    if (current.playerDetails.isNotEmpty) {
      return current.playerDetails.first;
    }

    return const BookingSubmissionPlayerModel();
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

  int _maxPlayerCountForSlot(String teeTimeSlot) {
    final parts = teeTimeSlot.split(' ');
    if (parts.length != 2) {
      return 4;
    }

    final timeParts = parts.first.split(':');
    if (timeParts.length != 2) {
      return 4;
    }

    final hour = int.tryParse(timeParts.first);
    final minute = int.tryParse(timeParts.last);
    if (hour == null || minute == null) {
      return 4;
    }

    var hour24 = hour % 12;
    if (parts.last.toUpperCase() == 'PM') {
      hour24 += 12;
    }

    final totalMinutes = (hour24 * 60) + minute;
    const start = 14 * 60;
    const end = 15 * 60;
    return totalMinutes >= start && totalMinutes <= end ? 6 : 4;
  }

  BookingSubmissionDetailDataLoaded getCurrentAsLoaded() {
    final state = currentState;
    if (state is BookingSubmissionDetailDataLoaded) {
      return state;
    }

    return BookingSubmissionDetailDataLoaded.initial();
  }

  @override
  void dispose() {
    _holdCountdownTimer?.cancel();
    super.dispose();
  }
}
