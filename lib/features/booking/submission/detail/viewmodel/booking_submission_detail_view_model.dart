import 'dart:async';

import 'package:golf_kakis/features/booking/submission/slot/domain/booking_submission_slot_use_case.dart';
import 'package:golf_kakis/features/foundation/model/booking_slot_details_model.dart';
import 'package:golf_kakis/features/foundation/model/booking_submission_player_model.dart';
import 'package:golf_kakis/features/foundation/model/data_status_model.dart';
import 'package:golf_kakis/features/foundation/util/date_util.dart';
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
  BookingSubmissionDetailViewModel(this._useCase);

  final BookingSubmissionSlotUseCase _useCase;
  StreamSubscription<DataStatusModel<BookingSlotDetailsModel>>?
  _slotDetailsSubscription;
  StreamSubscription<DataStatusModel<dynamic>>? _extendHoldSubscription;
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
          2,
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
              selectedNine: intent.selectedNine,
              initialCaddieCount: intent.initialCaddieCount,
              initialGolfCartCount: intent.initialGolfCartCount,
              caddieCount: intent.initialCaddieCount,
              golfCartCount: intent.initialGolfCartCount,
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
        await _fetchSlotDetails();
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
          final nextPlayerCount = intent.value.clamp(2, current.maxPlayerCount);
          return _deriveState(
            current.copyWith(
              playerCount: nextPlayerCount,
              caddieCount: current.caddieCount.clamp(0, nextPlayerCount),
              golfCartCount: current.golfCartCount.clamp(
                _defaultGolfCartCount(nextPlayerCount),
                _maxGolfCartCount(nextPlayerCount),
              ),
            ),
          );
        });
        await _fetchSlotDetails();
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
      case OnPlayerCategoryChanged():
        emitViewState((state) {
          return _deriveState(
            _updatePlayerDetails(
              current: getCurrentAsLoaded(),
              index: intent.index,
              category: intent.value,
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
              golfCartCount: intent.value.clamp(
                _defaultGolfCartCount(current.playerCount),
                _maxGolfCartCount(current.playerCount),
              ),
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
            holdDurationSeconds: current.holdDurationSeconds,
            holdExpiresAt: current.holdExpiresAt,
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
            selectedNine: current.selectedNine,
            caddieCount: current.caddieCount,
            golfCartCount: current.golfCartCount,
            playerDetails: current.playerDetails,
          ),
        );
      case OnExtendBookingHoldClick():
        await _extendBookingHold(intent.accessToken);
    }
  }

  BookingSubmissionDetailDataLoaded _deriveState(
    BookingSubmissionDetailDataLoaded state,
  ) {
    final normalizedPlayerCount = state.playerCount.clamp(
      2,
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
      _defaultGolfCartCount(normalizedPlayerCount),
      _maxGolfCartCount(normalizedPlayerCount),
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

    if (remainingHoldSeconds <= 60 && !_hasShownExpiryDialog) {
      _hasShownExpiryDialog = true;
      sendNavEffect(() => const ShowBookingSessionExpired());
    }

    if (isHoldExpired) {
      _holdCountdownTimer?.cancel();
    }
  }

  Future<void> _extendBookingHold(String accessToken) async {
    final current = getCurrentAsLoaded();
    if (current.bookingRef.trim().isEmpty || accessToken.trim().isEmpty) {
      sendNavEffect(
        () => const ShowErrorMessage(
          'Unable to extend this booking hold. Please try again.',
        ),
      );
      return;
    }

    emitViewState((state) {
      return current.copyWith(isExtendingHold: true);
    });

    await _extendHoldSubscription?.cancel();
    _extendHoldSubscription = _useCase
        .onExtendBookingHold(
          bookingRef: current.bookingRef,
          accessToken: accessToken,
        )
        .listen((result) {
          switch (result.status) {
            case DataStatus.success:
              final latest = getCurrentAsLoaded();
              final payload = _readMap(result.data);
              final holdDurationSeconds =
                  _readInt(
                    payload['holdDurationSeconds'] ??
                        payload['hold_duration_seconds'],
                  ) ??
                  latest.holdDurationSeconds;
              final holdExpiresAt =
                  DateTime.tryParse(
                    payload['holdExpiresAt']?.toString() ??
                        payload['hold_expires_at']?.toString() ??
                        '',
                  ) ??
                  DateTime.now().add(Duration(seconds: holdDurationSeconds));
              final remainingHoldSeconds = _remainingSecondsUntil(
                holdExpiresAt,
              );

              emitViewState((state) {
                return latest.copyWith(
                  bookingRef:
                      payload['bookingRef']?.toString() ??
                      payload['booking_ref']?.toString() ??
                      latest.bookingRef,
                  holdDurationSeconds: holdDurationSeconds,
                  holdExpiresAt: holdExpiresAt,
                  remainingHoldSeconds: remainingHoldSeconds,
                  isHoldExpired: false,
                  isExtendingHold: false,
                );
              });
              _hasShownExpiryDialog = false;
              _startHoldCountdown();
              sendNavEffect(() => const DismissBookingSessionExpired());
            case DataStatus.error:
              emitViewState((state) {
                return getCurrentAsLoaded().copyWith(isExtendingHold: false);
              });
              sendNavEffect(
                () => ShowErrorMessage(
                  result.apiMessage.isEmpty
                      ? 'Failed to extend booking hold. Please try again.'
                      : result.apiMessage,
                ),
              );
            default:
              break;
          }
        });
  }

  Future<void> _fetchSlotDetails() async {
    final current = getCurrentAsLoaded();
    if (current.slotId.trim().isEmpty ||
        current.golfClubSlug.trim().isEmpty ||
        current.playType.trim().isEmpty) {
      return;
    }

    emitViewState((state) {
      return getCurrentAsLoaded().copyWith(isLoadingSlotDetails: true);
    });

    await _slotDetailsSubscription?.cancel();
    _slotDetailsSubscription = _useCase
        .onFetchSlotDetails(
          slotId: current.slotId,
          clubSlug: current.golfClubSlug,
          date: DateUtil.formatApiDate(current.selectedDate),
          playType: current.playType,
          playerCount: current.playerCount,
          selectedNine: current.selectedNine,
        )
        .listen((result) {
          switch (result.status) {
            case DataStatus.success:
              final details = result.data;
              emitViewState((state) {
                return _deriveState(
                  getCurrentAsLoaded().copyWith(
                    golfClubName: details.golfClubName.isEmpty
                        ? null
                        : details.golfClubName,
                    golfClubSlug: details.golfClubSlug.isEmpty
                        ? null
                        : details.golfClubSlug,
                    teeTimeSlot: details.teeTimeSlot.isEmpty
                        ? null
                        : details.teeTimeSlot,
                    pricePerPerson: details.pricePerPerson > 0
                        ? details.pricePerPerson
                        : null,
                    currency: details.currency,
                    maxPlayerCount: details.maxPlayers,
                    categoryPricing: details.categoryPricing,
                    caddyFee: details.addOns.caddyFee,
                    buggyFeePerPlayer: details.addOns.buggyFeePerPlayer,
                    singleRiderSurcharge: details.addOns.singleRiderSurcharge,
                    isLoadingSlotDetails: false,
                  ),
                );
              });
            case DataStatus.error:
              emitViewState((state) {
                return getCurrentAsLoaded().copyWith(
                  isLoadingSlotDetails: false,
                );
              });
              sendNavEffect(
                () => ShowErrorMessage(
                  result.apiMessage.isEmpty
                      ? 'Failed to fetch slot details.'
                      : result.apiMessage,
                ),
              );
            default:
              break;
          }
        });
  }

  int _remainingSecondsUntil(DateTime expiresAt) {
    final difference = expiresAt.difference(DateTime.now()).inSeconds;
    return difference < 0 ? 0 : difference;
  }

  Map<String, dynamic> _readMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return <String, dynamic>{};
  }

  int? _readInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  BookingSubmissionDetailDataLoaded _updatePlayerDetails({
    required BookingSubmissionDetailDataLoaded current,
    required int index,
    String? name,
    String? phoneNumber,
    String? category,
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
      category: _normalizePlayerCategory(
        category ?? updatedPlayers[index].category,
      ),
    );

    return current.copyWith(playerDetails: updatedPlayers);
  }

  List<BookingSubmissionPlayerModel> _resizePlayerDetails({
    required List<BookingSubmissionPlayerModel> players,
    required int playerCount,
  }) {
    if (players.length == playerCount) {
      return List<BookingSubmissionPlayerModel>.generate(playerCount, (index) {
        return players[index].copyWith(
          category: _normalizePlayerCategory(players[index].category),
          isHost: index == 0,
        );
      });
    }

    if (players.length > playerCount) {
      return List<BookingSubmissionPlayerModel>.generate(playerCount, (index) {
        return players[index].copyWith(
          category: _normalizePlayerCategory(players[index].category),
          isHost: index == 0,
        );
      });
    }

    return List<BookingSubmissionPlayerModel>.generate(playerCount, (index) {
      if (index < players.length) {
        return players[index].copyWith(
          category: _normalizePlayerCategory(players[index].category),
          isHost: index == 0,
        );
      }

      return BookingSubmissionPlayerModel(
        category: 'normal',
        isHost: index == 0,
      );
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
          category: 'normal',
          isHost: true,
        );
      }

      return const BookingSubmissionPlayerModel();
    });
  }

  String _normalizePlayerCategory(String value) {
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

  int _maxGolfCartCount(int playerCount) {
    return playerCount;
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
    _slotDetailsSubscription?.cancel();
    _extendHoldSubscription?.cancel();
    super.dispose();
  }
}
