import 'package:golf_kakis/features/foundation/default_values.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_submission_player_model.dart';
import 'package:golf_kakis/features/foundation/util/currency_util.dart';
import 'package:golf_kakis/features/foundation/util/default_constant_util.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

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

class BookingSubmissionDetailDataLoaded
    extends BookingSubmissionDetailViewState {
  BookingSubmissionDetailDataLoaded({
    this.slotId = emptyString,
    this.playType = emptyString,
    this.golfClubName = emptyString,
    this.golfClubSlug = emptyString,
    DateTime? selectedDate,
    this.teeTimeSlot = emptyString,
    this.pricePerPerson = 0,
    this.currency = DefaultConstantUtil.defaultCurrency,
    this.guestId,
    this.bookingId = emptyString,
    this.holdDurationSeconds = 0,
    DateTime? holdExpiresAt,
    this.playerCount = 4,
    this.maxPlayerCount = 4,
    this.caddiePreference = 'none',
    this.buggyType = 'normal',
    this.buggySharingPreference = 'shared',
    this.selectedNine,
    this.caddieCount = 0,
    this.golfCartCount = 0,
    this.playerDetails = const <BookingSubmissionPlayerModel>[],
    this.remainingHoldSeconds = 0,
    this.isHoldExpired = false,
    this.canContinue = false,
    this.isSubmitting = false,
  }) : holdExpiresAt = holdExpiresAt ?? DateTime.now(),
       selectedDate = selectedDate ?? DateTime.now(),
       super();

  factory BookingSubmissionDetailDataLoaded.initial() {
    return BookingSubmissionDetailDataLoaded();
  }

  final String slotId;
  final String playType;
  final String golfClubName;
  final String golfClubSlug;
  final DateTime selectedDate;
  final String teeTimeSlot;
  final double pricePerPerson;
  final String currency;
  final String? guestId;
  final String bookingId;
  final int holdDurationSeconds;
  final DateTime holdExpiresAt;
  final int playerCount;
  final int maxPlayerCount;
  final String caddiePreference;
  final String buggyType;
  final String buggySharingPreference;
  final String? selectedNine;
  final int caddieCount;
  final int golfCartCount;
  final List<BookingSubmissionPlayerModel> playerDetails;
  final int remainingHoldSeconds;
  final bool isHoldExpired;
  final bool canContinue;
  final bool isSubmitting;

  String get pricePerPersonLabel =>
      CurrencyUtil.formatPrice(pricePerPerson, currency);

  String get totalCostLabel =>
      CurrencyUtil.formatPrice(pricePerPerson * playerCount, currency);

  String get holdCountdownLabel {
    final safeSeconds = remainingHoldSeconds < 0 ? 0 : remainingHoldSeconds;
    final minutes = (safeSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (safeSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  BookingSubmissionDetailDataLoaded copyWith({
    String? slotId,
    String? playType,
    String? golfClubName,
    String? golfClubSlug,
    DateTime? selectedDate,
    String? teeTimeSlot,
    double? pricePerPerson,
    String? currency,
    String? guestId,
    String? bookingId,
    int? holdDurationSeconds,
    DateTime? holdExpiresAt,
    int? playerCount,
    int? maxPlayerCount,
    String? caddiePreference,
    String? buggyType,
    String? buggySharingPreference,
    String? selectedNine,
    int? caddieCount,
    int? golfCartCount,
    List<BookingSubmissionPlayerModel>? playerDetails,
    int? remainingHoldSeconds,
    bool? isHoldExpired,
    bool? canContinue,
    bool? isSubmitting,
  }) {
    return BookingSubmissionDetailDataLoaded(
      slotId: slotId ?? this.slotId,
      playType: playType ?? this.playType,
      golfClubName: golfClubName ?? this.golfClubName,
      golfClubSlug: golfClubSlug ?? this.golfClubSlug,
      selectedDate: selectedDate ?? this.selectedDate,
      teeTimeSlot: teeTimeSlot ?? this.teeTimeSlot,
      pricePerPerson: pricePerPerson ?? this.pricePerPerson,
      currency: currency ?? this.currency,
      guestId: guestId ?? this.guestId,
      bookingId: bookingId ?? this.bookingId,
      holdDurationSeconds: holdDurationSeconds ?? this.holdDurationSeconds,
      holdExpiresAt: holdExpiresAt ?? this.holdExpiresAt,
      playerCount: playerCount ?? this.playerCount,
      maxPlayerCount: maxPlayerCount ?? this.maxPlayerCount,
      caddiePreference: caddiePreference ?? this.caddiePreference,
      buggyType: buggyType ?? this.buggyType,
      buggySharingPreference:
          buggySharingPreference ?? this.buggySharingPreference,
      selectedNine: selectedNine ?? this.selectedNine,
      caddieCount: caddieCount ?? this.caddieCount,
      golfCartCount: golfCartCount ?? this.golfCartCount,
      playerDetails: playerDetails ?? this.playerDetails,
      remainingHoldSeconds: remainingHoldSeconds ?? this.remainingHoldSeconds,
      isHoldExpired: isHoldExpired ?? this.isHoldExpired,
      canContinue: canContinue ?? this.canContinue,
      isSubmitting: isSubmitting ?? this.isSubmitting,
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
    required this.slotId,
    required this.bookingId,
    required this.holdDurationSeconds,
    required this.holdExpiresAt,
    required this.playType,
    required this.golfClubName,
    required this.golfClubSlug,
    required this.selectedDate,
    required this.teeTimeSlot,
    required this.pricePerPerson,
    required this.currency,
    this.initialPlayerCount = 4,
    this.caddiePreference = 'none',
    this.buggyType = 'normal',
    this.buggySharingPreference = 'shared',
    this.selectedNine,
    this.initialPlayerName = emptyString,
    this.initialPlayerPhoneNumber = emptyString,
    this.guestId,
  });

  final String slotId;
  final String bookingId;
  final int holdDurationSeconds;
  final DateTime holdExpiresAt;
  final String playType;
  final String golfClubName;
  final String golfClubSlug;
  final DateTime selectedDate;
  final String teeTimeSlot;
  final double pricePerPerson;
  final String currency;
  final int initialPlayerCount;
  final String caddiePreference;
  final String buggyType;
  final String buggySharingPreference;
  final String? selectedNine;
  final String initialPlayerName;
  final String initialPlayerPhoneNumber;
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
    required this.bookingId,
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
    required this.caddieCount,
    required this.golfCartCount,
    required this.playerDetails,
  });

  final String bookingId;
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
  final int caddieCount;
  final int golfCartCount;
  final List<BookingSubmissionPlayerModel> playerDetails;
}

class ShowBookingSessionExpired extends BookingSubmissionDetailNavEffect {
  const ShowBookingSessionExpired();
}

class ShowErrorMessage extends BookingSubmissionDetailNavEffect {
  const ShowErrorMessage(this.message);

  final String message;
}
