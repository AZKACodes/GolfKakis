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
  BookingSubmissionConfirmationViewModel();

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
          );
        });
      case OnBackClick():
        sendNavEffect(() => const NavigateBack());
      case OnConfirmClick():
        final current = getCurrentAsLoaded();
        sendNavEffect(
          () => NavigateToBookingSubmissionSuccess(
            bookingId: _buildBookingId(current),
            bookingDate: _buildBookingDate(),
            golfClubName: current.golfClubName,
            golfClubSlug: current.golfClubSlug,
            teeTimeSlot: current.teeTimeSlot,
            pricePerPerson: current.pricePerPerson,
            currency: current.currency,
            hostName: current.hostName,
            hostPhoneNumber: current.hostPhoneNumber,
            playerCount: current.playerCount,
            caddieCount: current.caddieCount,
            golfCartCount: current.golfCartCount,
          ),
        );
    }
  }

  BookingSubmissionConfirmationDataLoaded getCurrentAsLoaded() {
    final state = currentState;
    if (state is BookingSubmissionConfirmationDataLoaded) {
      return state;
    }

    return BookingSubmissionConfirmationDataLoaded.initial();
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

  String _buildBookingDate() {
    final now = DateTime.now();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
