import 'package:xxx_demo_app/features/foundation/default_values.dart';
import 'package:xxx_demo_app/features/foundation/model/booking/booking_submission_player_model.dart';
import 'package:xxx_demo_app/features/foundation/viewmodel/mvi_contract.dart';

abstract class BookingSubmissionConfirmationViewContract {
  BookingSubmissionConfirmationViewState get viewState;
  Stream<BookingSubmissionConfirmationNavEffect> get navEffects;
  void onUserIntent(BookingSubmissionConfirmationUserIntent intent);
}

sealed class BookingSubmissionConfirmationViewState extends ViewState {
  BookingSubmissionConfirmationViewState() : super();

  static final initial = BookingSubmissionConfirmationDataLoaded.initial();
}

class BookingSubmissionConfirmationDataLoaded
    extends BookingSubmissionConfirmationViewState {
  BookingSubmissionConfirmationDataLoaded({
    this.golfClubSlug = emptyString,
    this.teeTimeSlot = emptyString,
    this.guestId,
    this.hostName = emptyString,
    this.hostPhoneNumber = emptyString,
    this.playerCount = 0,
    this.caddieCount = 0,
    this.golfCartCount = 0,
    this.playerDetails = const <BookingSubmissionPlayerModel>[],
  }) : super();

  factory BookingSubmissionConfirmationDataLoaded.initial() {
    return BookingSubmissionConfirmationDataLoaded();
  }

  final String golfClubSlug;
  final String teeTimeSlot;
  final String? guestId;
  final String hostName;
  final String hostPhoneNumber;
  final int playerCount;
  final int caddieCount;
  final int golfCartCount;
  final List<BookingSubmissionPlayerModel> playerDetails;

  BookingSubmissionConfirmationDataLoaded copyWith({
    String? golfClubSlug,
    String? teeTimeSlot,
    String? guestId,
    String? hostName,
    String? hostPhoneNumber,
    int? playerCount,
    int? caddieCount,
    int? golfCartCount,
    List<BookingSubmissionPlayerModel>? playerDetails,
  }) {
    return BookingSubmissionConfirmationDataLoaded(
      golfClubSlug: golfClubSlug ?? this.golfClubSlug,
      teeTimeSlot: teeTimeSlot ?? this.teeTimeSlot,
      guestId: guestId ?? this.guestId,
      hostName: hostName ?? this.hostName,
      hostPhoneNumber: hostPhoneNumber ?? this.hostPhoneNumber,
      playerCount: playerCount ?? this.playerCount,
      caddieCount: caddieCount ?? this.caddieCount,
      golfCartCount: golfCartCount ?? this.golfCartCount,
      playerDetails: playerDetails ?? this.playerDetails,
    );
  }
}

sealed class BookingSubmissionConfirmationUserIntent extends UserIntent {
  const BookingSubmissionConfirmationUserIntent() : super();
}

class OnInit extends BookingSubmissionConfirmationUserIntent {
  const OnInit({
    required this.golfClubSlug,
    required this.teeTimeSlot,
    this.guestId,
    required this.hostName,
    required this.hostPhoneNumber,
    required this.playerCount,
    required this.caddieCount,
    required this.golfCartCount,
    required this.playerDetails,
  });

  final String golfClubSlug;
  final String teeTimeSlot;
  final String? guestId;
  final String hostName;
  final String hostPhoneNumber;
  final int playerCount;
  final int caddieCount;
  final int golfCartCount;
  final List<BookingSubmissionPlayerModel> playerDetails;
}

class OnBackClick extends BookingSubmissionConfirmationUserIntent {
  const OnBackClick();
}

class OnConfirmClick extends BookingSubmissionConfirmationUserIntent {
  const OnConfirmClick();
}

sealed class BookingSubmissionConfirmationNavEffect extends NavEffect {
  const BookingSubmissionConfirmationNavEffect() : super();
}

class NavigateBack extends BookingSubmissionConfirmationNavEffect {
  const NavigateBack();
}

class NavigateToBookingSubmissionSuccess
    extends BookingSubmissionConfirmationNavEffect {
  const NavigateToBookingSubmissionSuccess({
    required this.bookingId,
    required this.bookingDate,
    required this.golfClubSlug,
    required this.teeTimeSlot,
    required this.hostName,
    required this.hostPhoneNumber,
    required this.playerCount,
    required this.caddieCount,
    required this.golfCartCount,
  });

  final String bookingId;
  final String bookingDate;
  final String golfClubSlug;
  final String teeTimeSlot;
  final String hostName;
  final String hostPhoneNumber;
  final int playerCount;
  final int caddieCount;
  final int golfCartCount;
}
