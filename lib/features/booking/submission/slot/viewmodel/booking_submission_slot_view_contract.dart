import 'package:golf_kakis/features/foundation/enums/booking/time_period.dart';
import 'package:golf_kakis/features/foundation/default_values.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_slot_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_slot_details_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';
import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/util/currency_util.dart';
import 'package:golf_kakis/features/foundation/util/default_constant_util.dart';
import 'package:golf_kakis/features/foundation/util/date_util.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

abstract class BookingSubmissionSlotViewContract {
  BookingSubmissionSlotViewState get viewState;
  Stream<BookingSubmissionSlotNavEffect> get navEffects;
  void onUserIntent(BookingSubmissionSlotUserIntent intent);
}

// =========================
// ViewState
// =========================

sealed class BookingSubmissionSlotViewState extends ViewState {
  BookingSubmissionSlotViewState() : super();

  static final initial = BookingSubmissionSlotDataLoaded.initial();
}

class BookingSubmissionSlotDataLoaded extends BookingSubmissionSlotViewState {
  BookingSubmissionSlotDataLoaded({
    this.golfClubList = const <GolfClubModel>[],
    this.bookingSlots = const <BookingSlotModel>[],
    this.selectedClubSlug = emptyString,
    this.selectedSupportedNine = emptyString,
    this.playerCount = 2,
    DateTime? selectedDate,
    this.selectedSlot,
    this.selectedSlotDetails,
    this.selectedPeriod = TimePeriod.am,
    DateTime? pickerInitialDate,
    List<BookingSlotModel>? visibleSlots,
    Set<int>? visibleUnavailableIndices,
    this.visibleSelectedIndex,
    this.canContinue = false,
    this.isLoading = false,
    this.isLoadingSlotDetails = false,
    this.isSubmittingHold = false,
    this.errorSnackbarMessageModel = SnackbarMessageModel.emptyValue,
  }) : selectedDate = DateUtil.dateOnly(selectedDate ?? DateTime.now()),
       pickerInitialDate = DateUtil.dateOnly(
         pickerInitialDate ?? selectedDate ?? DateTime.now(),
       ),
       visibleSlots = visibleSlots ?? const <BookingSlotModel>[],
       visibleUnavailableIndices = visibleUnavailableIndices ?? const <int>{},
       super();

  factory BookingSubmissionSlotDataLoaded.initial({
    String selectedClubSlug = emptyString,
  }) {
    return BookingSubmissionSlotDataLoaded(
      selectedDate: DateTime.now(),
      selectedClubSlug: selectedClubSlug,
    );
  }

  final List<GolfClubModel> golfClubList;
  final List<BookingSlotModel> bookingSlots;
  final String selectedClubSlug;
  final String selectedSupportedNine;
  final int playerCount;
  final DateTime selectedDate;
  final DateTime pickerInitialDate;
  final BookingSlotModel? selectedSlot;
  final BookingSlotDetailsModel? selectedSlotDetails;
  final TimePeriod selectedPeriod;
  final List<BookingSlotModel> visibleSlots;
  final Set<int> visibleUnavailableIndices;
  final int? visibleSelectedIndex;
  final bool canContinue;
  final bool isLoading;
  final bool isLoadingSlotDetails;
  final bool isSubmittingHold;
  final SnackbarMessageModel errorSnackbarMessageModel;

  String get errorMessage => errorSnackbarMessageModel.message;

  GolfClubModel? get selectedGolfClub {
    for (final club in golfClubList) {
      if (club.slug == selectedClubSlug) {
        return club;
      }
    }

    return null;
  }

  String get selectedClubName => selectedGolfClub?.name ?? emptyString;

  List<String> get availableSupportedNines =>
      selectedGolfClub?.supportedNines ?? const <String>[];

  bool get requiresSupportedNineSelection => availableSupportedNines.isNotEmpty;

  bool get canActivateCalendar => selectedGolfClub != null;

  String get playTypeValue {
    final club = selectedGolfClub;
    if (club == null) {
      return emptyString;
    }

    return '18_holes';
  }

  String get selectedSlotPriceLabel {
    final price = selectedSlot?.price ?? 0;
    final currency =
        selectedSlot?.currency ?? DefaultConstantUtil.defaultCurrency;
    return CurrencyUtil.formatPrice(price, currency, suffix: '/ pax');
  }

  BookingSubmissionSlotDataLoaded copyWith({
    List<GolfClubModel>? golfClubList,
    List<BookingSlotModel>? bookingSlots,
    String? selectedClubSlug,
    String? selectedSupportedNine,
    bool clearSelectedSupportedNine = false,
    int? playerCount,
    DateTime? selectedDate,
    DateTime? pickerInitialDate,
    BookingSlotModel? selectedSlot,
    bool clearSelectedSlot = false,
    BookingSlotDetailsModel? selectedSlotDetails,
    bool clearSelectedSlotDetails = false,
    TimePeriod? selectedPeriod,
    List<BookingSlotModel>? visibleSlots,
    Set<int>? visibleUnavailableIndices,
    int? visibleSelectedIndex,
    bool clearVisibleSelectedIndex = false,
    bool? canContinue,
    bool? isLoading,
    bool? isLoadingSlotDetails,
    bool? isSubmittingHold,
    SnackbarMessageModel? errorSnackbarMessageModel,
    bool clearErrorMessage = false,
  }) {
    return BookingSubmissionSlotDataLoaded(
      golfClubList: golfClubList ?? this.golfClubList,
      bookingSlots: bookingSlots ?? this.bookingSlots,
      selectedClubSlug: selectedClubSlug ?? this.selectedClubSlug,
      selectedSupportedNine: clearSelectedSupportedNine
          ? emptyString
          : (selectedSupportedNine ?? this.selectedSupportedNine),
      playerCount: playerCount ?? this.playerCount,
      selectedDate: selectedDate ?? this.selectedDate,
      pickerInitialDate: pickerInitialDate ?? this.pickerInitialDate,
      selectedSlot: clearSelectedSlot
          ? null
          : (selectedSlot ?? this.selectedSlot),
      selectedSlotDetails: clearSelectedSlotDetails
          ? null
          : (selectedSlotDetails ?? this.selectedSlotDetails),
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      visibleSlots: visibleSlots ?? this.visibleSlots,
      visibleUnavailableIndices:
          visibleUnavailableIndices ?? this.visibleUnavailableIndices,
      visibleSelectedIndex: clearVisibleSelectedIndex
          ? null
          : (visibleSelectedIndex ?? this.visibleSelectedIndex),
      canContinue: canContinue ?? this.canContinue,
      isLoading: isLoading ?? this.isLoading,
      isLoadingSlotDetails: isLoadingSlotDetails ?? this.isLoadingSlotDetails,
      isSubmittingHold: isSubmittingHold ?? this.isSubmittingHold,
      errorSnackbarMessageModel: clearErrorMessage
          ? SnackbarMessageModel.emptyValue
          : (errorSnackbarMessageModel ?? this.errorSnackbarMessageModel),
    );
  }
}

// =========================
// UserIntent
// =========================

sealed class BookingSubmissionSlotUserIntent extends UserIntent {
  const BookingSubmissionSlotUserIntent() : super();
}

class OnFetchGolfClubList extends BookingSubmissionSlotUserIntent {
  const OnFetchGolfClubList();
}

class OnInit extends BookingSubmissionSlotUserIntent {
  const OnInit();
}

class OnFetchAvailableSlots extends BookingSubmissionSlotUserIntent {
  const OnFetchAvailableSlots({required this.clubSlug, required this.date});

  final String clubSlug;
  final DateTime date;
}

class OnSelectGolfClub extends BookingSubmissionSlotUserIntent {
  const OnSelectGolfClub(this.clubSlug);

  final String clubSlug;
}

class OnSelectSupportedNine extends BookingSubmissionSlotUserIntent {
  const OnSelectSupportedNine(this.value);

  final String value;
}

class OnPlayerCountChanged extends BookingSubmissionSlotUserIntent {
  const OnPlayerCountChanged(this.value);

  final int value;
}

class OnSelectDate extends BookingSubmissionSlotUserIntent {
  const OnSelectDate(this.date);

  final DateTime date;
}

class OnSelectSlot extends BookingSubmissionSlotUserIntent {
  const OnSelectSlot(this.slot);

  final BookingSlotModel slot;
}

class OnSlotDetailsClick extends BookingSubmissionSlotUserIntent {
  const OnSlotDetailsClick(this.slot);

  final BookingSlotModel slot;
}

class OnConfirmSlotClick extends BookingSubmissionSlotUserIntent {
  const OnConfirmSlotClick(this.details);

  final BookingSlotDetailsModel details;
}

class OnCreateBookingHoldRequested extends BookingSubmissionSlotUserIntent {
  const OnCreateBookingHoldRequested({
    required this.selectedSlotDetails,
    required this.accessToken,
    required this.hostName,
    required this.hostPhoneNumber,
    required this.source,
    this.idempotencyKey,
  });

  final BookingSlotDetailsModel selectedSlotDetails;
  final String accessToken;
  final String hostName;
  final String hostPhoneNumber;
  final String source;
  final String? idempotencyKey;
}

class OnSelectPeriod extends BookingSubmissionSlotUserIntent {
  const OnSelectPeriod(this.period);

  final TimePeriod period;
}

class OnBackClick extends BookingSubmissionSlotUserIntent {
  const OnBackClick();
}

class OnContinueClick extends BookingSubmissionSlotUserIntent {
  const OnContinueClick();
}

// =========================
// NavEffect
// =========================

sealed class BookingSubmissionSlotNavEffect extends NavEffect {
  const BookingSubmissionSlotNavEffect() : super();
}

class NavigateBack extends BookingSubmissionSlotNavEffect {
  const NavigateBack();
}

class RequestBookingHoldPrefill extends BookingSubmissionSlotNavEffect {
  const RequestBookingHoldPrefill({required this.selectedSlotDetails});

  final BookingSlotDetailsModel selectedSlotDetails;
}

class ShowSlotDetailsBottomSheet extends BookingSubmissionSlotNavEffect {
  const ShowSlotDetailsBottomSheet({required this.details});

  final BookingSlotDetailsModel details;
}

class NavigateToBookingSubmissionDetail extends BookingSubmissionSlotNavEffect {
  const NavigateToBookingSubmissionDetail({
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
    required this.playerCount,
    required this.initialCaddieCount,
    required this.initialGolfCartCount,
    required this.initialPlayerName,
    required this.initialPlayerPhoneNumber,
    this.selectedNine,
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
  final int playerCount;
  final int initialCaddieCount;
  final int initialGolfCartCount;
  final String initialPlayerName;
  final String initialPlayerPhoneNumber;
  final String? selectedNine;
  final String? guestId;
}

class ShowErrorMessage extends BookingSubmissionSlotNavEffect {
  const ShowErrorMessage(this.message);

  final String message;
}
