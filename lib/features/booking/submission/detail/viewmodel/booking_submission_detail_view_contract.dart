import 'package:golf_kakis/features/foundation/default_values.dart';
import 'package:golf_kakis/features/foundation/enums/booking/tee_time_slot.dart';
import 'package:golf_kakis/features/foundation/model/booking_slot_details_model.dart';
import 'package:golf_kakis/features/foundation/model/booking_submission_player_model.dart';
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
    this.categoryPricing = const <BookingSlotCategoryPriceModel>[],
    this.caddyFee = 0,
    this.buggyFeePerPlayer = 0,
    this.singleRiderSurcharge = 0,
    this.remainingHoldSeconds = 0,
    this.isHoldExpired = false,
    this.canContinue = false,
    this.isSubmitting = false,
    this.isExtendingHold = false,
    this.isLoadingSlotDetails = false,
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
  final List<BookingSlotCategoryPriceModel> categoryPricing;
  final double caddyFee;
  final double buggyFeePerPlayer;
  final double singleRiderSurcharge;
  final int remainingHoldSeconds;
  final bool isHoldExpired;
  final bool canContinue;
  final bool isSubmitting;
  final bool isExtendingHold;
  final bool isLoadingSlotDetails;

  String get pricePerPersonLabel =>
      CurrencyUtil.formatPrice(pricePerPerson, currency);

  String get totalCostLabel => CurrencyUtil.formatPrice(totalCost, currency);

  String get buggySurchargeLabel =>
      CurrencyUtil.formatPrice(singleRiderSurchargeTotal, currency);

  String get buggyFeeTotalLabel =>
      CurrencyUtil.formatPrice(buggyFeeTotal, currency);

  String get caddyFeeTotalLabel =>
      CurrencyUtil.formatPrice(caddyFeeTotal, currency);

  double get normalPricePerPerson =>
      _priceForCategory(category: 'normal', fallback: pricePerPerson);

  double get seniorPricePerPerson =>
      _priceForCategory(category: 'senior', fallback: pricePerPerson);

  double get juniorPricePerPerson =>
      _priceForCategory(category: 'junior', fallback: pricePerPerson);

  double get playerSubtotal =>
      (normalPlayerCount * normalPricePerPerson) +
      (seniorPlayerCount * seniorPricePerPerson) +
      (juniorPlayerCount * juniorPricePerPerson);

  int get singleRiderSurchargeUnitCount {
    if (golfCartCount <= 0 || playerCount <= 0) {
      return 0;
    }

    final singleRiders = (golfCartCount * 2) - playerCount;
    return singleRiders <= 0 ? 0 : singleRiders;
  }

  double get buggyFeeTotal {
    if (buggyAddOnRiderCount <= 0 || buggyFeePerPlayer <= 0) {
      return 0;
    }

    return buggyAddOnRiderCount * buggyFeePerPlayer;
  }

  int get buggyAddOnCount {
    final addOnCount = golfCartCount - minGolfCartCount;
    return addOnCount <= 0 ? 0 : addOnCount;
  }

  int get buggyAddOnRiderCount {
    if (buggyAddOnCount <= 0) {
      return 0;
    }

    final addOnCapacity = buggyAddOnCount * 2;
    return addOnCapacity > playerCount ? playerCount : addOnCapacity;
  }

  double get caddyFeeTotal {
    if (caddieCount <= 0 || caddyFee <= 0) {
      return 0;
    }

    return caddieCount * caddyFee;
  }

  double get singleRiderSurchargeTotal {
    if (singleRiderSurcharge <= 0) {
      return 0;
    }

    return singleRiderSurchargeUnitCount * singleRiderSurcharge;
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

  double get totalCost =>
      playerSubtotal +
      buggyFeeTotal +
      caddyFeeTotal +
      singleRiderSurchargeTotal;

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
    List<BookingSlotCategoryPriceModel>? categoryPricing,
    double? caddyFee,
    double? buggyFeePerPlayer,
    double? singleRiderSurcharge,
    int? remainingHoldSeconds,
    bool? isHoldExpired,
    bool? canContinue,
    bool? isSubmitting,
    bool? isExtendingHold,
    bool? isLoadingSlotDetails,
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
      categoryPricing: categoryPricing ?? this.categoryPricing,
      caddyFee: caddyFee ?? this.caddyFee,
      buggyFeePerPlayer: buggyFeePerPlayer ?? this.buggyFeePerPlayer,
      singleRiderSurcharge: singleRiderSurcharge ?? this.singleRiderSurcharge,
      remainingHoldSeconds: remainingHoldSeconds ?? this.remainingHoldSeconds,
      isHoldExpired: isHoldExpired ?? this.isHoldExpired,
      canContinue: canContinue ?? this.canContinue,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isExtendingHold: isExtendingHold ?? this.isExtendingHold,
      isLoadingSlotDetails: isLoadingSlotDetails ?? this.isLoadingSlotDetails,
    );
  }

  double _priceForCategory({
    required String category,
    required double fallback,
  }) {
    final normalizedCategory = _normalizePlayerCategory(category);
    for (final item in categoryPricing) {
      if (_normalizePlayerCategory(item.label) == normalizedCategory) {
        return item.amount;
      }
    }
    return fallback;
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

class OnExtendBookingHoldClick extends BookingSubmissionDetailUserIntent {
  const OnExtendBookingHoldClick({required this.accessToken});

  final String accessToken;
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

class DismissBookingSessionExpired extends BookingSubmissionDetailNavEffect {
  const DismissBookingSessionExpired();
}

class ShowErrorMessage extends BookingSubmissionDetailNavEffect {
  const ShowErrorMessage(this.message);

  final String message;
}
