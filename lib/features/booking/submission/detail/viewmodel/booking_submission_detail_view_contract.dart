import 'package:golf_kakis/features/foundation/default_values.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_submission_player_model.dart';
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
    this.golfClubName = emptyString,
    this.golfClubSlug = emptyString,
    DateTime? selectedDate,
    this.teeTimeSlot = emptyString,
    this.pricePerPerson = 0,
    this.currency = DefaultConstantUtil.defaultCurrency,
    this.guestId,
    this.hostName = emptyString,
    this.hostPhoneNumber = emptyString,
    this.playerCount = 4,
    this.maxPlayerCount = 4,
    this.caddieCount = 0,
    this.golfCartCount = 0,
    this.playerDetails = const <BookingSubmissionPlayerModel>[],
    this.canContinue = false,
  }) : selectedDate = selectedDate ?? DateTime.now(),
       super();

  factory BookingSubmissionDetailDataLoaded.initial() {
    return BookingSubmissionDetailDataLoaded();
  }

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
  final int maxPlayerCount;
  final int caddieCount;
  final int golfCartCount;
  final List<BookingSubmissionPlayerModel> playerDetails;
  final bool canContinue;

  String get pricePerPersonLabel => _formatCurrency(pricePerPerson, currency);

  String get totalCostLabel =>
      _formatCurrency(pricePerPerson * playerCount, currency);

  BookingSubmissionDetailDataLoaded copyWith({
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
    int? maxPlayerCount,
    int? caddieCount,
    int? golfCartCount,
    List<BookingSubmissionPlayerModel>? playerDetails,
    bool? canContinue,
  }) {
    return BookingSubmissionDetailDataLoaded(
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
    required this.golfClubName,
    required this.golfClubSlug,
    required this.selectedDate,
    required this.teeTimeSlot,
    required this.pricePerPerson,
    required this.currency,
    this.guestId,
  });

  final String golfClubName;
  final String golfClubSlug;
  final DateTime selectedDate;
  final String teeTimeSlot;
  final double pricePerPerson;
  final String currency;
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

String _formatCurrency(double value, String currency) {
  return '${currency.toUpperCase()} ${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
}
