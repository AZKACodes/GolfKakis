import 'package:golf_kakis/features/foundation/default_values.dart';
import 'package:golf_kakis/features/foundation/enums/booking/tee_time_slot.dart';
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
    this.bookingRef = emptyString,
    this.holdDurationSeconds = 0,
    DateTime? holdExpiresAt,
    this.playerCount = 4,
    this.maxPlayerCount = 4,
    this.selectedNine,
    this.initialCaddieCount = 0,
    this.initialGolfCartCount = 0,
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
  final String bookingRef;
  final int holdDurationSeconds;
  final DateTime holdExpiresAt;
  final int playerCount;
  final int maxPlayerCount;
  final String? selectedNine;
  final int initialCaddieCount;
  final int initialGolfCartCount;
  final int caddieCount;
  final int golfCartCount;
  final List<BookingSubmissionPlayerModel> playerDetails;
  final int remainingHoldSeconds;
  final bool isHoldExpired;
  final bool canContinue;
  final bool isSubmitting;

  String get pricePerPersonLabel =>
      CurrencyUtil.formatPrice(pricePerPerson, currency);

  String get totalCostLabel => CurrencyUtil.formatPrice(totalCost, currency);

  String get buggySurchargeLabel =>
      CurrencyUtil.formatPrice(buggySurcharge, currency);

  double get normalPricePerPerson => pricePerPerson;

  double get seniorPricePerPerson => pricePerPerson * 0.88;

  double get juniorPricePerPerson => pricePerPerson * 0.72;

  double get playerSubtotal =>
      (normalPlayerCount * normalPricePerPerson) +
      (seniorPlayerCount * seniorPricePerPerson) +
      (juniorPlayerCount * juniorPricePerPerson);

  int get buggySurchargeUnitCount {
    if (golfCartCount <= 0) {
      return 0;
    }

    final totalIncludedBuggyCoverage = playerCount * 40;
    final totalBuggyCost = golfCartCount * 80;
    final surcharge = totalBuggyCost - totalIncludedBuggyCoverage;
    return surcharge <= 0 ? 0 : (surcharge / 40).round();
  }

  double get buggySurcharge {
    if (golfCartCount <= 0) {
      return 0;
    }

    final totalIncludedBuggyCoverage = playerCount * 40;
    final totalBuggyCost = golfCartCount * 80;
    final surcharge = totalBuggyCost - totalIncludedBuggyCoverage;
    return surcharge <= 0 ? 0 : surcharge.toDouble();
  }

  int get minGolfCartCount =>
      _defaultGolfCartCountFor(playerCount: playerCount);

  int get maxGolfCartCount => _maxGolfCartCountFor(playerCount: playerCount);

  int get normalPlayerCount => playerDetails
      .where((player) => _normalizePlayerCategory(player.category) == 'normal')
      .length;

  int get seniorPlayerCount => playerDetails
      .where((player) => _normalizePlayerCategory(player.category) == 'senior')
      .length;

  int get juniorPlayerCount => playerDetails
      .where((player) => _normalizePlayerCategory(player.category) == 'junior')
      .length;

  double get totalCost => playerSubtotal + buggySurcharge;

  String get holdCountdownLabel {
    final safeSeconds = remainingHoldSeconds < 0 ? 0 : remainingHoldSeconds;
    final minutes = (safeSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (safeSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  TeeTimeSlot? get teeTime => TeeTimeSlot.fromLabel(teeTimeSlot);

  bool get isForcedSharedCaddieSlot =>
      teeTime?.requiresSharedCaddieAndJumboBuggy == true;

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
    String? bookingRef,
    int? holdDurationSeconds,
    DateTime? holdExpiresAt,
    int? playerCount,
    int? maxPlayerCount,
    String? selectedNine,
    int? initialCaddieCount,
    int? initialGolfCartCount,
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
      bookingRef: bookingRef ?? this.bookingRef,
      holdDurationSeconds: holdDurationSeconds ?? this.holdDurationSeconds,
      holdExpiresAt: holdExpiresAt ?? this.holdExpiresAt,
      playerCount: playerCount ?? this.playerCount,
      maxPlayerCount: maxPlayerCount ?? this.maxPlayerCount,
      selectedNine: selectedNine ?? this.selectedNine,
      initialCaddieCount: initialCaddieCount ?? this.initialCaddieCount,
      initialGolfCartCount: initialGolfCartCount ?? this.initialGolfCartCount,
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

String _normalizePlayerCategory(String value) {
  switch (value.trim().toLowerCase()) {
    case 'senior':
    case 'senior_citizen':
      return 'senior';
    case 'junior':
      return 'junior';
    case 'normal':
    default:
      return 'normal';
  }
}

int _defaultGolfCartCountFor({required int playerCount}) {
  if (playerCount <= 2) {
    return 1;
  }

  if (playerCount <= 4) {
    return 2;
  }

  return 3;
}

int _maxGolfCartCountFor({required int playerCount}) {
  return playerCount;
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
    required this.bookingRef,
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
    this.selectedNine,
    this.initialCaddieCount = 0,
    this.initialGolfCartCount = 0,
    this.initialPlayerName = emptyString,
    this.initialPlayerPhoneNumber = emptyString,
    this.guestId,
  });

  final String slotId;
  final String bookingId;
  final String bookingRef;
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
  final String? selectedNine;
  final int initialCaddieCount;
  final int initialGolfCartCount;
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

class OnPlayerCategoryChanged extends BookingSubmissionDetailUserIntent {
  const OnPlayerCategoryChanged({required this.index, required this.value});

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

  final String bookingId;
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

class ShowBookingSessionExpired extends BookingSubmissionDetailNavEffect {
  const ShowBookingSessionExpired();
}

class ShowErrorMessage extends BookingSubmissionDetailNavEffect {
  const ShowErrorMessage(this.message);

  final String message;
}
