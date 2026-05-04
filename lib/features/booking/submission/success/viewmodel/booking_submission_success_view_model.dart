import 'dart:async';

import 'package:golf_kakis/features/booking/submission/slot/domain/booking_submission_slot_use_case.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_submission_player_model.dart';
import 'package:golf_kakis/features/foundation/model/data_status_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import 'booking_submission_success_view_contract.dart';

class BookingSubmissionSuccessViewModel
    extends
        MviViewModel<
          BookingSubmissionSuccessUserIntent,
          BookingSubmissionSuccessViewState,
          BookingSubmissionSuccessNavEffect
        >
    implements BookingSubmissionSuccessViewContract {
  BookingSubmissionSuccessViewModel(this._useCase);

  final BookingSubmissionSlotUseCase _useCase;
  StreamSubscription<DataStatusModel<dynamic>>? _bookingDetailSubscription;

  @override
  BookingSubmissionSuccessViewState createInitialState() {
    return BookingSubmissionSuccessDataLoaded.initial();
  }

  @override
  Future<void> handleIntent(BookingSubmissionSuccessUserIntent intent) async {
    switch (intent) {
      case OnInit():
        emitViewState((state) {
          return getCurrentAsLoaded().copyWith(
            bookingId: intent.bookingId,
            bookingRef: intent.bookingRef,
            bookingDate: intent.bookingDate,
            golfClubName: intent.golfClubName,
            golfClubSlug: intent.golfClubSlug,
            teeTimeSlot: intent.teeTimeSlot,
            pricePerPerson: intent.pricePerPerson,
            currency: intent.currency,
            playType: _resolvePlayType(intent.teeTimeSlot),
            hostName: intent.hostName,
            hostPhoneNumber: intent.hostPhoneNumber,
            playerCount: intent.playerCount,
            caddieCount: intent.caddieCount,
            golfCartCount: intent.golfCartCount,
          );
        });
        if (intent.bookingRef.isNotEmpty) {
          await _fetchBookingDetails(intent.bookingRef);
        }
      case OnDoneClick():
        sendNavEffect(() => const NavigateToSubmissionStart());
    }
  }

  BookingSubmissionSuccessDataLoaded getCurrentAsLoaded() {
    final state = currentState;
    if (state is BookingSubmissionSuccessDataLoaded) {
      return state;
    }

    return BookingSubmissionSuccessDataLoaded.initial();
  }

  Future<void> _fetchBookingDetails(String bookingRef) async {
    emitViewState((state) {
      return getCurrentAsLoaded().copyWith(isLoading: true);
    });

    await _bookingDetailSubscription?.cancel();
    _bookingDetailSubscription = _useCase
        .onFetchBookingDetails(bookingRef: bookingRef)
        .listen((result) {
          switch (result.status) {
            case DataStatus.success:
              emitViewState((state) {
                return _mergeBookingResponse(
                  current: getCurrentAsLoaded(),
                  response: result.data,
                ).copyWith(isLoading: false);
              });
            case DataStatus.error:
              emitViewState((state) {
                return getCurrentAsLoaded().copyWith(isLoading: false);
              });
            default:
              break;
          }
        });
  }

  BookingSubmissionSuccessDataLoaded _mergeBookingResponse({
    required BookingSubmissionSuccessDataLoaded current,
    required dynamic response,
  }) {
    final data = _normalizeMap(response);
    if (data == null) {
      return current;
    }

    final players = _parsePlayers(
      data['playerDetails'] ?? data['players'] ?? data['player_details'],
    );
    final playerCount = _readInt(data, const <String>[
      'playerCount',
      'player_count',
      'playersCount',
    ]);
    final caddieCount = _readInt(data, const <String>[
      'caddieCount',
      'caddie_count',
    ]);
    final golfCartCount = _readInt(data, const <String>[
      'golfCartCount',
      'golf_cart_count',
      'cartCount',
    ]);
    final pricePerPerson = _readDouble(data, const <String>[
      'pricePerPerson',
      'price_per_person',
      'amountPerPax',
    ]);
    final currency =
        _readString(data, const <String>['currency', 'currencyCode']) ??
        current.currency;
    final resolvedPlayerCount =
        playerCount ?? (players.isEmpty ? current.playerCount : players.length);

    return current.copyWith(
      bookingId:
          _readString(data, const <String>['bookingId', 'booking_id', 'id']) ??
          current.bookingId,
      bookingRef:
          _readString(data, const <String>['bookingRef', 'bookingReference']) ??
          current.bookingRef,
      bookingDate:
          _readString(data, const <String>[
            'bookingDate',
            'booking_date',
            'date',
          ]) ??
          current.bookingDate,
      golfClubName:
          _readString(data, const <String>[
            'golfClubName',
            'golf_club_name',
            'courseName',
            'clubName',
          ]) ??
          current.golfClubName,
      golfClubSlug:
          _readString(data, const <String>[
            'golfClubSlug',
            'golf_club_slug',
            'courseSlug',
            'clubSlug',
          ]) ??
          current.golfClubSlug,
      teeTimeSlot:
          _readString(data, const <String>[
            'teeTimeSlot',
            'tee_time_slot',
            'teeTime',
            'time',
          ]) ??
          current.teeTimeSlot,
      pricePerPerson: pricePerPerson ?? current.pricePerPerson,
      currency: currency,
      playType:
          _readString(data, const <String>['playType', 'play_type']) ??
          current.playType,
      hostName:
          _readString(data, const <String>['hostName', 'host_name']) ??
          current.hostName,
      hostPhoneNumber:
          _readString(data, const <String>[
            'hostPhoneNumber',
            'host_phone_number',
            'hostPhone',
          ]) ??
          current.hostPhoneNumber,
      playerCount: resolvedPlayerCount,
      caddieCount: caddieCount ?? current.caddieCount,
      golfCartCount: golfCartCount ?? current.golfCartCount,
    );
  }

  String _resolvePlayType(String teeTimeSlot) {
    return '18_holes';
  }

  Map<String, dynamic>? _normalizeMap(dynamic response) {
    if (response is Map<String, dynamic>) {
      final nested =
          response['data'] ?? response['item'] ?? response['booking'];
      if (nested is Map<String, dynamic>) {
        return nested;
      }

      return response;
    }

    return null;
  }

  List<BookingSubmissionPlayerModel> _parsePlayers(dynamic rawPlayers) {
    if (rawPlayers is! List) {
      return const <BookingSubmissionPlayerModel>[];
    }

    return rawPlayers.whereType<Map<String, dynamic>>().map((player) {
      return BookingSubmissionPlayerModel(
        name:
            player['name']?.toString() ??
            player['playerName']?.toString() ??
            '',
        phoneNumber:
            player['phoneNumber']?.toString() ??
            player['phone_number']?.toString() ??
            player['phone']?.toString() ??
            '',
      );
    }).toList();
  }

  String? _readString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
      if (value != null) {
        final text = value.toString();
        if (text.trim().isNotEmpty) {
          return text;
        }
      }
    }

    return null;
  }

  int? _readInt(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
    }

    return null;
  }

  double? _readDouble(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is double) {
        return value;
      }
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
    }

    return null;
  }

  @override
  void dispose() {
    _bookingDetailSubscription?.cancel();
    super.dispose();
  }
}
