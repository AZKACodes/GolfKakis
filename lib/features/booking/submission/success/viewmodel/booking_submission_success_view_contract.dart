import 'package:xxx_demo_app/features/foundation/default_values.dart';
import 'package:xxx_demo_app/features/foundation/viewmodel/mvi_contract.dart';

abstract class BookingSubmissionSuccessViewContract {
  BookingSubmissionSuccessViewState get viewState;
  Stream<BookingSubmissionSuccessNavEffect> get navEffects;
  void onUserIntent(BookingSubmissionSuccessUserIntent intent);
}

sealed class BookingSubmissionSuccessViewState extends ViewState {
  BookingSubmissionSuccessViewState() : super();

  static final initial = BookingSubmissionSuccessDataLoaded.initial();
}

class BookingSubmissionSuccessDataLoaded
    extends BookingSubmissionSuccessViewState {
  BookingSubmissionSuccessDataLoaded({
    this.bookingId = emptyString,
    this.bookingDate = emptyString,
    this.golfClubSlug = emptyString,
    this.teeTimeSlot = emptyString,
    this.hostName = emptyString,
    this.hostPhoneNumber = emptyString,
    this.playerCount = 0,
    this.caddieCount = 0,
    this.golfCartCount = 0,
  }) : super();

  factory BookingSubmissionSuccessDataLoaded.initial() {
    return BookingSubmissionSuccessDataLoaded();
  }

  final String bookingId;
  final String bookingDate;
  final String golfClubSlug;
  final String teeTimeSlot;
  final String hostName;
  final String hostPhoneNumber;
  final int playerCount;
  final int caddieCount;
  final int golfCartCount;

  BookingSubmissionSuccessDataLoaded copyWith({
    String? bookingId,
    String? bookingDate,
    String? golfClubSlug,
    String? teeTimeSlot,
    String? hostName,
    String? hostPhoneNumber,
    int? playerCount,
    int? caddieCount,
    int? golfCartCount,
  }) {
    return BookingSubmissionSuccessDataLoaded(
      bookingId: bookingId ?? this.bookingId,
      bookingDate: bookingDate ?? this.bookingDate,
      golfClubSlug: golfClubSlug ?? this.golfClubSlug,
      teeTimeSlot: teeTimeSlot ?? this.teeTimeSlot,
      hostName: hostName ?? this.hostName,
      hostPhoneNumber: hostPhoneNumber ?? this.hostPhoneNumber,
      playerCount: playerCount ?? this.playerCount,
      caddieCount: caddieCount ?? this.caddieCount,
      golfCartCount: golfCartCount ?? this.golfCartCount,
    );
  }
}

sealed class BookingSubmissionSuccessUserIntent extends UserIntent {
  const BookingSubmissionSuccessUserIntent() : super();
}

class OnInit extends BookingSubmissionSuccessUserIntent {
  const OnInit({
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

class OnDoneClick extends BookingSubmissionSuccessUserIntent {
  const OnDoneClick();
}

sealed class BookingSubmissionSuccessNavEffect extends NavEffect {
  const BookingSubmissionSuccessNavEffect() : super();
}

class NavigateToSubmissionStart extends BookingSubmissionSuccessNavEffect {
  const NavigateToSubmissionStart();
}
