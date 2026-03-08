import 'package:xxx_demo_app/features/foundation/viewmodel/mvi_view_model.dart';

import 'booking_submission_success_view_contract.dart';

class BookingSubmissionSuccessViewModel
    extends
        MviViewModel<
          BookingSubmissionSuccessUserIntent,
          BookingSubmissionSuccessViewState,
          BookingSubmissionSuccessNavEffect
        >
    implements BookingSubmissionSuccessViewContract {
  BookingSubmissionSuccessViewModel();

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
            bookingDate: intent.bookingDate,
            golfClubName: intent.golfClubName,
            golfClubSlug: intent.golfClubSlug,
            teeTimeSlot: intent.teeTimeSlot,
            pricePerPerson: intent.pricePerPerson,
            currency: intent.currency,
            hostName: intent.hostName,
            hostPhoneNumber: intent.hostPhoneNumber,
            playerCount: intent.playerCount,
            caddieCount: intent.caddieCount,
            golfCartCount: intent.golfCartCount,
          );
        });
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
}
