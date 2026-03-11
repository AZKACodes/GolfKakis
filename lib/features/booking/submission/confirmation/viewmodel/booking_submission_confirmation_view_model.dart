import 'dart:async';

import 'package:xxx_demo_app/features/booking/submission/slot/domain/booking_submission_slot_use_case.dart';
import 'package:xxx_demo_app/features/foundation/model/booking/booking_submission_request_model.dart';
import 'package:xxx_demo_app/features/foundation/model/data_status_model.dart';
import 'package:xxx_demo_app/features/foundation/util/date_util.dart';
import 'package:xxx_demo_app/features/foundation/viewmodel/mvi_view_model.dart';

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
              emitViewState((state) {
                return latest.copyWith(isSubmitting: false, clearErrorMessage: true);
              });
              sendNavEffect(
                () => NavigateToBookingSubmissionSuccess(
                  bookingId: _resolveBookingId(result.data, latest),
                  bookingSlug: _resolveBookingSlug(result.data),
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
      golfClubName: current.golfClubName,
      golfClubSlug: current.golfClubSlug,
      bookingDate: DateUtil.formatApiDate(current.selectedDate),
      teeTimeSlot: current.teeTimeSlot,
      pricePerPerson: current.pricePerPerson,
      currency: current.currency,
      guestId: current.guestId,
      hostName: current.hostName,
      hostPhoneNumber: current.hostPhoneNumber,
      playerCount: current.playerCount,
      caddieCount: current.caddieCount,
      golfCartCount: current.golfCartCount,
      playerDetails: current.playerDetails,
    );
  }

  String _buildBookingId(BookingSubmissionConfirmationDataLoaded current) {
    final normalizedClub = current.golfClubSlug
        .replaceAll('-', '')
        .toUpperCase();
    final suffix = DateTime.now().millisecondsSinceEpoch.toString().substring(
      8,
    );
    return '${normalizedClub.substring(0, normalizedClub.length.clamp(0, 4))}-$suffix';
  }

  String _resolveBookingId(
    dynamic response,
    BookingSubmissionConfirmationDataLoaded current,
  ) {
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

    return _buildBookingId(current);
  }

  String _resolveBookingSlug(dynamic response) {
    if (response is Map<String, dynamic>) {
      final dynamic bookingSlug =
          response['bookingSlug'] ??
          response['booking_slug'] ??
          response['slug'];
      if (bookingSlug is String && bookingSlug.trim().isNotEmpty) {
        return bookingSlug;
      }
      if (bookingSlug != null) {
        return bookingSlug.toString();
      }
    }

    return '';
  }

  @override
  void dispose() {
    _submissionSubscription?.cancel();
    super.dispose();
  }
}
