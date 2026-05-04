import 'package:golf_kakis/features/foundation/default_values.dart';
import 'package:golf_kakis/features/foundation/util/currency_util.dart';
import 'package:golf_kakis/features/foundation/util/default_constant_util.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

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
    this.bookingRef = emptyString,
    this.bookingDate = emptyString,
    this.golfClubName = emptyString,
    this.golfClubSlug = emptyString,
    this.teeTimeSlot = emptyString,
    this.pricePerPerson = 0,
    this.currency = DefaultConstantUtil.defaultCurrency,
    this.playType = '18_holes',
    this.hostName = emptyString,
    this.hostPhoneNumber = emptyString,
    this.playerCount = 0,
    this.caddieCount = 0,
    this.golfCartCount = 0,
    this.isLoading = false,
  }) : super();

  factory BookingSubmissionSuccessDataLoaded.initial() {
    return BookingSubmissionSuccessDataLoaded();
  }

  final String bookingId;
  final String bookingRef;
  final String bookingDate;
  final String golfClubName;
  final String golfClubSlug;
  final String teeTimeSlot;
  final double pricePerPerson;
  final String currency;
  final String playType;
  final String hostName;
  final String hostPhoneNumber;
  final int playerCount;
  final int caddieCount;
  final int golfCartCount;
  final bool isLoading;

  String get pricePerPersonLabel =>
      CurrencyUtil.formatPrice(pricePerPerson, currency);

  String get totalCostLabel =>
      CurrencyUtil.formatPrice(pricePerPerson * playerCount, currency);

  String get paymentMethodLabel => 'Pay At Counter';

  BookingSubmissionSuccessDataLoaded copyWith({
    String? bookingId,
    String? bookingRef,
    String? bookingDate,
    String? golfClubName,
    String? golfClubSlug,
    String? teeTimeSlot,
    double? pricePerPerson,
    String? currency,
    String? playType,
    String? hostName,
    String? hostPhoneNumber,
    int? playerCount,
    int? caddieCount,
    int? golfCartCount,
    bool? isLoading,
  }) {
    return BookingSubmissionSuccessDataLoaded(
      bookingId: bookingId ?? this.bookingId,
      bookingRef: bookingRef ?? this.bookingRef,
      bookingDate: bookingDate ?? this.bookingDate,
      golfClubName: golfClubName ?? this.golfClubName,
      golfClubSlug: golfClubSlug ?? this.golfClubSlug,
      teeTimeSlot: teeTimeSlot ?? this.teeTimeSlot,
      pricePerPerson: pricePerPerson ?? this.pricePerPerson,
      currency: currency ?? this.currency,
      playType: playType ?? this.playType,
      hostName: hostName ?? this.hostName,
      hostPhoneNumber: hostPhoneNumber ?? this.hostPhoneNumber,
      playerCount: playerCount ?? this.playerCount,
      caddieCount: caddieCount ?? this.caddieCount,
      golfCartCount: golfCartCount ?? this.golfCartCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

sealed class BookingSubmissionSuccessUserIntent extends UserIntent {
  const BookingSubmissionSuccessUserIntent() : super();
}

class OnInit extends BookingSubmissionSuccessUserIntent {
  const OnInit({
    required this.bookingId,
    required this.bookingRef,
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

  final String bookingId;
  final String bookingRef;
  final String bookingDate;
  final String golfClubName;
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

class OnDoneClick extends BookingSubmissionSuccessUserIntent {
  const OnDoneClick();
}

sealed class BookingSubmissionSuccessNavEffect extends NavEffect {
  const BookingSubmissionSuccessNavEffect() : super();
}

class NavigateToSubmissionStart extends BookingSubmissionSuccessNavEffect {
  const NavigateToSubmissionStart();
}
