import 'package:xxx_demo_app/features/foundation/default_values.dart';

abstract class BookingSubmissionDetailViewContract {
  BookingSubmissionDetailViewState get viewState;
  Stream<BookingSubmissionDetailNavEffect> get navEffects;
  void onUserIntent(BookingSubmissionDetailUserIntent intent);
}

sealed class BookingSubmissionDetailViewState {
  const BookingSubmissionDetailViewState();

  static const initial = BookingSubmissionDetailDataLoaded();
}

class BookingSubmissionDetailDataLoaded
    extends BookingSubmissionDetailViewState {
  const BookingSubmissionDetailDataLoaded({
    this.golfClubSlug = emptyString,
    this.teeTimeSlot = emptyString,
    this.guestId,
    this.hostName = emptyString,
    this.hostPhoneNumber = emptyString,
    this.playerCount = 4,
    this.caddieCount = 0,
    this.golfCartCount = 0,
  });

  final String golfClubSlug;
  final String teeTimeSlot;
  final String? guestId;
  final String hostName;
  final String hostPhoneNumber;
  final int playerCount;
  final int caddieCount;
  final int golfCartCount;

  BookingSubmissionDetailDataLoaded copyWith({
    String? golfClubSlug,
    String? teeTimeSlot,
    String? guestId,
    String? hostName,
    String? hostPhoneNumber,
    int? playerCount,
    int? caddieCount,
    int? golfCartCount,
  }) {
    return BookingSubmissionDetailDataLoaded(
      golfClubSlug: golfClubSlug ?? this.golfClubSlug,
      teeTimeSlot: teeTimeSlot ?? this.teeTimeSlot,
      guestId: guestId ?? this.guestId,
      hostName: hostName ?? this.hostName,
      hostPhoneNumber: hostPhoneNumber ?? this.hostPhoneNumber,
      playerCount: playerCount ?? this.playerCount,
      caddieCount: caddieCount ?? this.caddieCount,
      golfCartCount: golfCartCount ?? this.golfCartCount,
    );
  }
}

sealed class BookingSubmissionDetailUserIntent {
  const BookingSubmissionDetailUserIntent();
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

class OnCaddieCountChanged extends BookingSubmissionDetailUserIntent {
  const OnCaddieCountChanged(this.value);

  final int value;
}

class OnGolfCartCountChanged extends BookingSubmissionDetailUserIntent {
  const OnGolfCartCountChanged(this.value);

  final int value;
}

sealed class NavEffect {
  const NavEffect();
}

sealed class BookingSubmissionDetailNavEffect extends NavEffect {
  const BookingSubmissionDetailNavEffect();
}
