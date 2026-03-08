import 'package:xxx_demo_app/features/foundation/default_values.dart';
import 'package:xxx_demo_app/features/foundation/model/booking/booking_submission_player_model.dart';
import 'package:xxx_demo_app/features/foundation/util/default_constant_util.dart';
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
    this.golfClubName = emptyString,
    this.golfClubSlug = emptyString,
    this.teeTimeSlot = emptyString,
    this.pricePerPerson = 0,
    this.currency = DefaultConstantUtil.defaultCurrency,
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

  final String golfClubName;
  final String golfClubSlug;
  final String teeTimeSlot;
  final double pricePerPerson;
  final String currency;
  final String? guestId;
  final String hostName;
  final String hostPhoneNumber;
  final int playerCount;
  final int caddieCount;
  final int golfCartCount;
  final List<BookingSubmissionPlayerModel> playerDetails;

  String get pricePerPersonLabel => _formatCurrency(pricePerPerson, currency);

  String get totalCostLabel =>
      _formatCurrency(pricePerPerson * playerCount, currency);

  BookingSubmissionConfirmationDataLoaded copyWith({
    String? golfClubName,
    String? golfClubSlug,
    String? teeTimeSlot,
    double? pricePerPerson,
    String? currency,
    String? guestId,
    String? hostName,
    String? hostPhoneNumber,
    int? playerCount,
    int? caddieCount,
    int? golfCartCount,
    List<BookingSubmissionPlayerModel>? playerDetails,
  }) {
    return BookingSubmissionConfirmationDataLoaded(
      golfClubName: golfClubName ?? this.golfClubName,
      golfClubSlug: golfClubSlug ?? this.golfClubSlug,
      teeTimeSlot: teeTimeSlot ?? this.teeTimeSlot,
      pricePerPerson: pricePerPerson ?? this.pricePerPerson,
      currency: currency ?? this.currency,
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
    required this.golfClubName,
    required this.golfClubSlug,
    required this.teeTimeSlot,
    required this.pricePerPerson,
    required this.currency,
    this.guestId,
    required this.hostName,
    required this.hostPhoneNumber,
    required this.playerCount,
    required this.caddieCount,
    required this.golfCartCount,
    required this.playerDetails,
  });

  final String golfClubName;
  final String golfClubSlug;
  final String teeTimeSlot;
  final double pricePerPerson;
  final String currency;
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
    required this.golfClubName,
    required this.golfClubSlug,
    required this.teeTimeSlot,
    required this.pricePerPerson,
    required this.currency,
    required this.hostName,
    required this.hostPhoneNumber,
    required this.playerCount,
    required this.caddieCount,
    required this.golfCartCount,
  });

  final String golfClubName;
  final String bookingId;
  final String bookingDate;
  final String golfClubSlug;
  final String teeTimeSlot;
  final double pricePerPerson;
  final String currency;
  final String hostName;
  final String hostPhoneNumber;
  final int playerCount;
  final int caddieCount;
  final int golfCartCount;
}

String _formatCurrency(double value, String currency) {
  return '${currency.toUpperCase()} ${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
}
