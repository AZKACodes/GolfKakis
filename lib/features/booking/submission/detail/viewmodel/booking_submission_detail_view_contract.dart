import 'package:xxx_demo_app/features/foundation/default_values.dart';
import 'package:xxx_demo_app/features/foundation/model/booking/booking_submission_player_model.dart';
import 'package:xxx_demo_app/features/foundation/viewmodel/mvi_contract.dart';

abstract class BookingSubmissionDetailViewContract {
  BookingSubmissionDetailViewState get viewState;
  Stream<BookingSubmissionDetailNavEffect> get navEffects;
  void onUserIntent(BookingSubmissionDetailUserIntent intent);
}

// =========================
// ViewState
// =========================

sealed class BookingSubmissionDetailViewState extends ViewState {
  BookingSubmissionDetailViewState() : super();

  static final initial = BookingSubmissionDetailDataLoaded.initial();
}

class BookingSubmissionDetailDataLoaded extends BookingSubmissionDetailViewState {
  BookingSubmissionDetailDataLoaded({
    this.golfClubSlug = emptyString,
    this.teeTimeSlot = emptyString,
    this.guestId,
    this.hostName = emptyString,
    this.hostPhoneNumber = emptyString,
    this.playerCount = 4,
    this.maxPlayerCount = 4,
    this.caddieCount = 0,
    this.golfCartCount = 0,
    this.playerDetails = const <BookingSubmissionPlayerModel>[],
    this.canContinue = false,
  }) : super();

  factory BookingSubmissionDetailDataLoaded.initial() {
    return BookingSubmissionDetailDataLoaded();
  }

  final String golfClubSlug;
  final String teeTimeSlot;
  final String? guestId;
  final String hostName;
  final String hostPhoneNumber;
  final int playerCount;
  final int maxPlayerCount;
  final int caddieCount;
  final int golfCartCount;
  final List<BookingSubmissionPlayerModel> playerDetails;
  final bool canContinue;

  BookingSubmissionDetailDataLoaded copyWith({
    String? golfClubSlug,
    String? teeTimeSlot,
    String? guestId,
    String? hostName,
    String? hostPhoneNumber,
    int? playerCount,
    int? maxPlayerCount,
    int? caddieCount,
    int? golfCartCount,
    List<BookingSubmissionPlayerModel>? playerDetails,
    bool? canContinue,
  }) {
    return BookingSubmissionDetailDataLoaded(
      golfClubSlug: golfClubSlug ?? this.golfClubSlug,
      teeTimeSlot: teeTimeSlot ?? this.teeTimeSlot,
      guestId: guestId ?? this.guestId,
      hostName: hostName ?? this.hostName,
      hostPhoneNumber: hostPhoneNumber ?? this.hostPhoneNumber,
      playerCount: playerCount ?? this.playerCount,
      maxPlayerCount: maxPlayerCount ?? this.maxPlayerCount,
      caddieCount: caddieCount ?? this.caddieCount,
      golfCartCount: golfCartCount ?? this.golfCartCount,
      playerDetails: playerDetails ?? this.playerDetails,
      canContinue: canContinue ?? this.canContinue,
    );
  }
}

// =========================
// UserIntent
// =========================

sealed class BookingSubmissionDetailUserIntent extends UserIntent {
  const BookingSubmissionDetailUserIntent() : super();
}

class OnInit extends BookingSubmissionDetailUserIntent {
  const OnInit({
    required this.golfClubSlug,
    required this.teeTimeSlot,
    this.guestId,
  });

  final String golfClubSlug;
  final String teeTimeSlot;
  final String? guestId;
}

class OnBackClick extends BookingSubmissionDetailUserIntent {
  const OnBackClick();
}

class OnHostNameChanged extends BookingSubmissionDetailUserIntent {
  const OnHostNameChanged(this.value);

  final String value;
}

class OnHostPhoneNumberChanged extends BookingSubmissionDetailUserIntent {
  const OnHostPhoneNumberChanged(this.value);

  final String value;
}

class OnPlayerCountChanged extends BookingSubmissionDetailUserIntent {
  const OnPlayerCountChanged(this.value);

  final int value;
}

class OnPlayerNameChanged extends BookingSubmissionDetailUserIntent {
  const OnPlayerNameChanged({required this.index, required this.value});

  final int index;
  final String value;
}

class OnPlayerPhoneNumberChanged extends BookingSubmissionDetailUserIntent {
  const OnPlayerPhoneNumberChanged({required this.index, required this.value});

  final int index;
  final String value;
}

class OnCaddieCountChanged extends BookingSubmissionDetailUserIntent {
  const OnCaddieCountChanged(this.value);

  final int value;
}

class OnGolfCartCountChanged extends BookingSubmissionDetailUserIntent {
  const OnGolfCartCountChanged(this.value);

  final int value;
}

class OnContinueClick extends BookingSubmissionDetailUserIntent {
  const OnContinueClick();
}

// =========================
// NavEffect
// =========================

sealed class BookingSubmissionDetailNavEffect extends NavEffect {
  const BookingSubmissionDetailNavEffect() : super();
}

class NavigateBack extends BookingSubmissionDetailNavEffect {
  const NavigateBack();
}

class NavigateToBookingSubmissionConfirmation
    extends BookingSubmissionDetailNavEffect {
  const NavigateToBookingSubmissionConfirmation({
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
