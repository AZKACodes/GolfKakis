import 'package:xxx_demo_app/features/foundation/model/booking/booking_submission_player_model.dart';
import 'package:xxx_demo_app/features/foundation/viewmodel/mvi_view_model.dart';

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

  @override
  BookingSubmissionDetailViewState createInitialState() {
    return BookingSubmissionDetailDataLoaded.initial();
  }

  @override
  Future<void> handleIntent(BookingSubmissionDetailUserIntent intent) async {
    switch (intent) {
      case OnInit():
        final maxPlayerCount = _maxPlayerCountForSlot(intent.teeTimeSlot);
        emitViewState((state) {
          return _deriveState(
            getCurrentAsLoaded().copyWith(
              golfClubSlug: intent.golfClubSlug,
              teeTimeSlot: intent.teeTimeSlot,
              guestId: intent.guestId,
              maxPlayerCount: maxPlayerCount,
              playerCount: _defaultPlayerCount(maxPlayerCount),
              golfCartCount: _defaultGolfCartCount(
                _defaultPlayerCount(maxPlayerCount),
              ),
            ),
          );
        });
      case OnBackClick():
        sendNavEffect(() => const NavigateBack());
      case OnHostNameChanged():
        emitViewState((state) {
          return _deriveState(
            getCurrentAsLoaded().copyWith(hostName: intent.value),
          );
        });
      case OnHostPhoneNumberChanged():
        emitViewState((state) {
          return _deriveState(
            getCurrentAsLoaded().copyWith(hostPhoneNumber: intent.value),
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
            current.copyWith(caddieCount: intent.value.clamp(0, current.playerCount)),
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
        if (!current.canContinue) {
          return;
        }

        sendNavEffect(
          () => NavigateToBookingSubmissionConfirmation(
            golfClubSlug: current.golfClubSlug,
            teeTimeSlot: current.teeTimeSlot,
            guestId: current.guestId,
            hostName: current.hostName,
            hostPhoneNumber: current.hostPhoneNumber,
            playerCount: current.playerCount,
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
    final normalizedPlayerCount = state.playerCount.clamp(1, state.maxPlayerCount);
    final normalizedPlayerDetails = _resizePlayerDetails(
      players: state.playerDetails,
      playerCount: normalizedPlayerCount,
    );
    final normalizedCaddieCount = state.caddieCount.clamp(0, normalizedPlayerCount);
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
          state.hostName.trim().isNotEmpty &&
          state.hostPhoneNumber.trim().isNotEmpty &&
          normalizedPlayerDetails.length == normalizedPlayerCount &&
          normalizedPlayerDetails.every((player) => player.isComplete),
    );
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

  int _defaultPlayerCount(int maxPlayerCount) {
    return maxPlayerCount >= 4 ? 4 : maxPlayerCount;
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
}
