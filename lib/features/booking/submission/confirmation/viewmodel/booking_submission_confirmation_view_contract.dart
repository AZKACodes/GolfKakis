import 'package:golf_kakis/features/foundation/default_values.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_submission_player_model.dart';
import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/util/currency_util.dart';
import 'package:golf_kakis/features/foundation/util/date_util.dart';
import 'package:golf_kakis/features/foundation/util/default_constant_util.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

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
    this.bookingRef = emptyString,
    this.holdDurationSeconds = 0,
    DateTime? holdExpiresAt,
    this.golfClubName = emptyString,
    this.golfClubSlug = emptyString,
    DateTime? selectedDate,
    this.teeTimeSlot = emptyString,
    this.pricePerPerson = 0,
    this.currency = DefaultConstantUtil.defaultCurrency,
    this.guestId,
    this.hostName = emptyString,
    this.hostPhoneNumber = emptyString,
    this.playerCount = 0,
    this.selectedNine,
    this.caddieCount = 0,
    this.golfCartCount = 0,
    this.playerDetails = const <BookingSubmissionPlayerModel>[],
    this.remainingHoldSeconds = 0,
    this.isHoldExpired = false,
    this.isSubmitting = false,
    this.errorSnackbarMessageModel = SnackbarMessageModel.emptyValue,
  }) : holdExpiresAt = holdExpiresAt ?? DateTime.now(),
       selectedDate = DateUtil.dateOnly(selectedDate ?? DateTime.now()),
       super();

  factory BookingSubmissionConfirmationDataLoaded.initial() {
    return BookingSubmissionConfirmationDataLoaded();
  }

  final String bookingRef;
  final int holdDurationSeconds;
  final DateTime holdExpiresAt;
  final String golfClubName;
  final String golfClubSlug;
  final DateTime selectedDate;
  final String teeTimeSlot;
  final double pricePerPerson;
  final String currency;
  final String? guestId;
  final String hostName;
  final String hostPhoneNumber;
  final int playerCount;
  final String? selectedNine;
  final int caddieCount;
  final int golfCartCount;
  final List<BookingSubmissionPlayerModel> playerDetails;
  final int remainingHoldSeconds;
  final bool isHoldExpired;
  final bool isSubmitting;
  final SnackbarMessageModel errorSnackbarMessageModel;

  String get errorMessage => errorSnackbarMessageModel.message;

  String get pricePerPersonLabel =>
      CurrencyUtil.formatPrice(pricePerPerson, currency);

  String get totalCostLabel =>
      CurrencyUtil.formatPrice(pricePerPerson * playerCount, currency);

  String get paymentMethodLabel => 'Pay At Counter';

  String get holdCountdownLabel {
    final safeSeconds = remainingHoldSeconds < 0 ? 0 : remainingHoldSeconds;
    final minutes = (safeSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (safeSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  BookingSubmissionConfirmationDataLoaded copyWith({
    String? bookingRef,
    int? holdDurationSeconds,
    DateTime? holdExpiresAt,
    String? golfClubName,
    String? golfClubSlug,
    DateTime? selectedDate,
    String? teeTimeSlot,
    double? pricePerPerson,
    String? currency,
    String? guestId,
    String? hostName,
    String? hostPhoneNumber,
    int? playerCount,
    String? selectedNine,
    int? caddieCount,
    int? golfCartCount,
    List<BookingSubmissionPlayerModel>? playerDetails,
    int? remainingHoldSeconds,
    bool? isHoldExpired,
    bool? isSubmitting,
    SnackbarMessageModel? errorSnackbarMessageModel,
    bool clearErrorMessage = false,
  }) {
    return BookingSubmissionConfirmationDataLoaded(
      bookingRef: bookingRef ?? this.bookingRef,
      holdDurationSeconds: holdDurationSeconds ?? this.holdDurationSeconds,
      holdExpiresAt: holdExpiresAt ?? this.holdExpiresAt,
      golfClubName: golfClubName ?? this.golfClubName,
      golfClubSlug: golfClubSlug ?? this.golfClubSlug,
      selectedDate: selectedDate ?? this.selectedDate,
      teeTimeSlot: teeTimeSlot ?? this.teeTimeSlot,
      pricePerPerson: pricePerPerson ?? this.pricePerPerson,
      currency: currency ?? this.currency,
      guestId: guestId ?? this.guestId,
      hostName: hostName ?? this.hostName,
      hostPhoneNumber: hostPhoneNumber ?? this.hostPhoneNumber,
      playerCount: playerCount ?? this.playerCount,
      selectedNine: selectedNine ?? this.selectedNine,
      caddieCount: caddieCount ?? this.caddieCount,
      golfCartCount: golfCartCount ?? this.golfCartCount,
      playerDetails: playerDetails ?? this.playerDetails,
      remainingHoldSeconds: remainingHoldSeconds ?? this.remainingHoldSeconds,
      isHoldExpired: isHoldExpired ?? this.isHoldExpired,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorSnackbarMessageModel: clearErrorMessage
          ? SnackbarMessageModel.emptyValue
          : (errorSnackbarMessageModel ?? this.errorSnackbarMessageModel),
    );
  }
}

sealed class BookingSubmissionConfirmationUserIntent extends UserIntent {
  const BookingSubmissionConfirmationUserIntent() : super();
}

class OnInit extends BookingSubmissionConfirmationUserIntent {
  const OnInit({
    required this.bookingRef,
    required this.holdDurationSeconds,
    required this.holdExpiresAt,
    required this.golfClubName,
    required this.golfClubSlug,
    required this.selectedDate,
    required this.teeTimeSlot,
    required this.pricePerPerson,
    required this.currency,
    this.guestId,
    required this.hostName,
    required this.hostPhoneNumber,
    required this.playerCount,
    this.selectedNine,
    required this.caddieCount,
    required this.golfCartCount,
    required this.playerDetails,
  });

  final String bookingRef;
  final int holdDurationSeconds;
  final DateTime holdExpiresAt;
  final String golfClubName;
  final String golfClubSlug;
  final DateTime selectedDate;
  final String teeTimeSlot;
  final double pricePerPerson;
  final String currency;
  final String? guestId;
  final String hostName;
  final String hostPhoneNumber;
  final int playerCount;
  final String? selectedNine;
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

class NavigateToBookingSubmissionStart
    extends BookingSubmissionConfirmationNavEffect {
  const NavigateToBookingSubmissionStart();
}

class ShowBookingSessionExpired extends BookingSubmissionConfirmationNavEffect {
  const ShowBookingSessionExpired();
}

class NavigateToBookingSubmissionSuccess
    extends BookingSubmissionConfirmationNavEffect {
  const NavigateToBookingSubmissionSuccess({
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

  final String golfClubName;
  final String bookingId;
  final String bookingRef;
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
