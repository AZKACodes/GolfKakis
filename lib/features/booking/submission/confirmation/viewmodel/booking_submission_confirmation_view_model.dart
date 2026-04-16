import 'dart:async';

import 'package:golf_kakis/features/booking/submission/slot/domain/booking_submission_slot_use_case.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_submission_request_model.dart';
import 'package:golf_kakis/features/foundation/model/data_status_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_submission_player_model.dart';
import 'package:golf_kakis/features/foundation/util/date_util.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import 'booking_submission_confirmation_view_contract.dart';

class BookingSubmissionConfirmationViewModel
    extends
        MviViewModel<
          BookingSubmissionConfirmationUserIntent,
          BookingSubmissionConfirmationViewState,
          BookingSubmissionConfirmationNavEffect
        >
    implements BookingSubmissionConfirmationViewContract {
  BookingSubmissionConfirmationViewModel(this._useCase);

  final BookingSubmissionSlotUseCase _useCase;
  StreamSubscription<DataStatusModel<dynamic>>? _submissionSubscription;

  @override
  BookingSubmissionConfirmationViewState createInitialState() {
    return BookingSubmissionConfirmationDataLoaded.initial();
  }

  @override
  Future<void> handleIntent(
    BookingSubmissionConfirmationUserIntent intent,
  ) async {
    switch (intent) {
      case OnInit():
        emitViewState((state) {
          return getCurrentAsLoaded().copyWith(
            bookingRef: intent.bookingRef,
            golfClubName: intent.golfClubName,
            golfClubSlug: intent.golfClubSlug,
            selectedDate: intent.selectedDate,
            teeTimeSlot: intent.teeTimeSlot,
            pricePerPerson: intent.pricePerPerson,
            currency: intent.currency,
            guestId: intent.guestId,
            hostName: intent.hostName,
            hostPhoneNumber: intent.hostPhoneNumber,
            playerCount: intent.playerCount,
            caddiePreference: intent.caddiePreference,
            buggyType: intent.buggyType,
            buggySharingPreference: intent.buggySharingPreference,
            caddieCount: intent.caddieCount,
            golfCartCount: intent.golfCartCount,
            playerDetails: intent.playerDetails,
            clearErrorMessage: true,
          );
        });
      case OnBackClick():
        sendNavEffect(() => const NavigateBack());
      case OnConfirmClick():
        final current = getCurrentAsLoaded();
        if (current.isSubmitting) {
          return;
        }
        await _createBookingSubmission(current);
    }
  }

  BookingSubmissionConfirmationDataLoaded getCurrentAsLoaded() {
    final state = currentState;
    if (state is BookingSubmissionConfirmationDataLoaded) {
      return state;
    }

    return BookingSubmissionConfirmationDataLoaded.initial();
  }

  Future<void> _createBookingSubmission(
    BookingSubmissionConfirmationDataLoaded current,
  ) async {
    emitViewState((state) {
      return getCurrentAsLoaded().copyWith(
        isSubmitting: true,
        clearErrorMessage: true,
      );
    });

    await _submissionSubscription?.cancel();
    _submissionSubscription = _useCase
        .onCreateBookingSubmission(request: _buildRequest(current))
        .listen((result) {
          switch (result.status) {
            case DataStatus.success:
              final latest = getCurrentAsLoaded();
              final bookingId = _resolveBookingId(result.data);
              if (bookingId.isEmpty) {
                emitViewState((state) {
                  return latest.copyWith(
                    isSubmitting: false,
                    errorMessage:
                        'Booking submission succeeded without a booking ID.',
                  );
                });
                return;
              }
              emitViewState((state) {
                return latest.copyWith(
                  isSubmitting: false,
                  clearErrorMessage: true,
                );
              });
              sendNavEffect(
                () => NavigateToBookingSubmissionSuccess(
                  bookingId: bookingId,
                  bookingRef:
                      _resolveBookingRef(result.data) ?? latest.bookingRef,
                  bookingDate: DateUtil.formatApiDate(latest.selectedDate),
                  golfClubName: latest.golfClubName,
                  golfClubSlug: latest.golfClubSlug,
                  teeTimeSlot: latest.teeTimeSlot,
                  pricePerPerson: latest.pricePerPerson,
                  currency: latest.currency,
                  hostName: latest.hostName,
                  hostPhoneNumber: latest.hostPhoneNumber,
                  playerCount: latest.playerCount,
                  caddieCount: latest.caddieCount,
                  golfCartCount: latest.golfCartCount,
                ),
              );
            case DataStatus.error:
              emitViewState((state) {
                return getCurrentAsLoaded().copyWith(
                  isSubmitting: false,
                  errorMessage: result.apiMessage.isEmpty
                      ? 'Failed to submit booking. Please try again.'
                      : result.apiMessage,
                );
              });
            default:
              break;
          }
        });
  }

  BookingSubmissionRequestModel _buildRequest(
    BookingSubmissionConfirmationDataLoaded current,
  ) {
    return BookingSubmissionRequestModel(
      bookingRef: current.bookingRef,
      caddieArrangement: current.caddiePreference,
      buggyType: current.buggyType,
      buggySharingPreference: current.buggySharingPreference,
      playerDetails: _buildPlayerDetails(current),
      acknowledgedTerms: true,
    );
  }

  List<BookingSubmissionPlayerModel> _buildPlayerDetails(
    BookingSubmissionConfirmationDataLoaded current,
  ) {
    return current.playerDetails.indexed.map((entry) {
      final index = entry.$1;
      final player = entry.$2;
      return player.copyWith(category: 'normal', isHost: index == 0);
    }).toList();
  }

  String _resolveBookingId(dynamic response) {
    if (response is Map<String, dynamic>) {
      final dynamic bookingId =
          response['bookingId'] ??
          response['booking_id'] ??
          response['id'] ??
          response['reference'] ??
          response['bookingReference'];
      if (bookingId is String && bookingId.trim().isNotEmpty) {
        return bookingId;
      }
      if (bookingId != null) {
        return bookingId.toString();
      }
    }

    return '';
  }

  String? _resolveBookingRef(dynamic response) {
    if (response is Map<String, dynamic>) {
      final dynamic bookingRef =
          response['bookingRef'] ?? response['bookingReference'];
      if (bookingRef is String && bookingRef.trim().isNotEmpty) {
        return bookingRef;
      }
      if (bookingRef != null) {
        return bookingRef.toString();
      }
    }

    return null;
  }

  @override
  void dispose() {
    _submissionSubscription?.cancel();
    super.dispose();
  }
}
