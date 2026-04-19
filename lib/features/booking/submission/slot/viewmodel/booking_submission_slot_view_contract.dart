import 'package:golf_kakis/features/foundation/enums/booking/time_period.dart';
import 'package:golf_kakis/features/foundation/default_values.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_slot_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';
import 'package:golf_kakis/features/foundation/util/currency_util.dart';
import 'package:golf_kakis/features/foundation/util/default_constant_util.dart';
import 'package:golf_kakis/features/foundation/util/date_util.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

abstract class BookingSubmissionSlotViewContract {
  BookingSubmissionSlotViewState get viewState;
  Stream<BookingSubmissionSlotNavEffect> get navEffects;
  void onUserIntent(BookingSubmissionSlotUserIntent intent);
}

enum BookingCaddiePreference {
  none('none', 'None'),
  shared('shared', 'Shared'),
  perPlayer('per_player', 'Per Player');

  const BookingCaddiePreference(this.value, this.label);

  final String value;
  final String label;
}

enum BookingBuggyType {
  normal('normal', 'Normal'),
  jumbo('jumbo', 'Jumbo');

  const BookingBuggyType(this.value, this.label);

  final String value;
  final String label;
}

enum BookingBuggySharingPreference {
  shared('shared', 'Shared'),
  mix('mix', 'Mix');

  const BookingBuggySharingPreference(this.value, this.label);

  final String value;
  final String label;
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
    this.normalPlayerCount = 2,
    this.seniorPlayerCount = 0,
    this.caddiePreference = BookingCaddiePreference.none,
    this.buggyType = BookingBuggyType.normal,
    this.buggySharingPreference = BookingBuggySharingPreference.shared,
    DateTime? selectedDate,
    this.selectedSlot,
    this.selectedPeriod = TimePeriod.am,
    DateTime? pickerInitialDate,
    List<BookingSlotModel>? visibleSlots,
    Set<int>? visibleUnavailableIndices,
    this.visibleSelectedIndex,
    this.canContinue = false,
    this.isLoading = false,
    this.errorMessage = emptyString,
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
  final int normalPlayerCount;
  final int seniorPlayerCount;
  final BookingCaddiePreference caddiePreference;
  final BookingBuggyType buggyType;
  final BookingBuggySharingPreference buggySharingPreference;
  final DateTime selectedDate;
  final DateTime pickerInitialDate;
  final BookingSlotModel? selectedSlot;
  final TimePeriod selectedPeriod;
  final List<BookingSlotModel> visibleSlots;
  final Set<int> visibleUnavailableIndices;
  final int? visibleSelectedIndex;
  final bool canContinue;
  final bool isLoading;
  final String errorMessage;

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

  bool get canActivateCalendar =>
      selectedGolfClub != null &&
      (!requiresSupportedNineSelection || selectedSupportedNine.isNotEmpty);

  int get playerCount => normalPlayerCount + seniorPlayerCount;

  String get playTypeValue {
    final club = selectedGolfClub;
    if (club == null) {
      return emptyString;
    }

    return '18_holes';
  }

  List<BookingBuggyType> get availableBuggyTypes {
    if (playerCount > 4) {
      return const <BookingBuggyType>[
        BookingBuggyType.normal,
        BookingBuggyType.jumbo,
      ];
    }

    return const <BookingBuggyType>[BookingBuggyType.normal];
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
    int? normalPlayerCount,
    int? seniorPlayerCount,
    BookingCaddiePreference? caddiePreference,
    BookingBuggyType? buggyType,
    BookingBuggySharingPreference? buggySharingPreference,
    DateTime? selectedDate,
    DateTime? pickerInitialDate,
    BookingSlotModel? selectedSlot,
    bool clearSelectedSlot = false,
    TimePeriod? selectedPeriod,
    List<BookingSlotModel>? visibleSlots,
    Set<int>? visibleUnavailableIndices,
    int? visibleSelectedIndex,
    bool clearVisibleSelectedIndex = false,
    bool? canContinue,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return BookingSubmissionSlotDataLoaded(
      golfClubList: golfClubList ?? this.golfClubList,
      bookingSlots: bookingSlots ?? this.bookingSlots,
      selectedClubSlug: selectedClubSlug ?? this.selectedClubSlug,
      selectedSupportedNine: clearSelectedSupportedNine
          ? emptyString
          : (selectedSupportedNine ?? this.selectedSupportedNine),
      normalPlayerCount: normalPlayerCount ?? this.normalPlayerCount,
      seniorPlayerCount: seniorPlayerCount ?? this.seniorPlayerCount,
      caddiePreference: caddiePreference ?? this.caddiePreference,
      buggyType: buggyType ?? this.buggyType,
      buggySharingPreference:
          buggySharingPreference ?? this.buggySharingPreference,
      selectedDate: selectedDate ?? this.selectedDate,
      pickerInitialDate: pickerInitialDate ?? this.pickerInitialDate,
      selectedSlot: clearSelectedSlot
          ? null
          : (selectedSlot ?? this.selectedSlot),
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      visibleSlots: visibleSlots ?? this.visibleSlots,
      visibleUnavailableIndices:
          visibleUnavailableIndices ?? this.visibleUnavailableIndices,
      visibleSelectedIndex: clearVisibleSelectedIndex
          ? null
          : (visibleSelectedIndex ?? this.visibleSelectedIndex),
      canContinue: canContinue ?? this.canContinue,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? emptyString
          : (errorMessage ?? this.errorMessage),
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

class OnNormalPlayerCountChanged extends BookingSubmissionSlotUserIntent {
  const OnNormalPlayerCountChanged(this.value);

  final int value;
}

class OnSeniorPlayerCountChanged extends BookingSubmissionSlotUserIntent {
  const OnSeniorPlayerCountChanged(this.value);

  final int value;
}

class OnSelectCaddiePreference extends BookingSubmissionSlotUserIntent {
  const OnSelectCaddiePreference(this.value);

  final BookingCaddiePreference value;
}

class OnSelectBuggyType extends BookingSubmissionSlotUserIntent {
  const OnSelectBuggyType(this.value);

  final BookingBuggyType value;
}

class OnSelectBuggySharingPreference extends BookingSubmissionSlotUserIntent {
  const OnSelectBuggySharingPreference(this.value);

  final BookingBuggySharingPreference value;
}

class OnSelectDate extends BookingSubmissionSlotUserIntent {
  const OnSelectDate(this.date);

  final DateTime date;
}

class OnSelectSlot extends BookingSubmissionSlotUserIntent {
  const OnSelectSlot(this.slot);

  final BookingSlotModel slot;
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

class NavigateToBookingSubmissionDetail extends BookingSubmissionSlotNavEffect {
  const NavigateToBookingSubmissionDetail({
    required this.slotId,
    required this.playType,
    required this.golfClubName,
    required this.golfClubSlug,
    required this.selectedDate,
    required this.teeTimeSlot,
    required this.pricePerPerson,
    required this.currency,
    required this.playerCount,
    required this.caddiePreference,
    required this.buggyType,
    required this.buggySharingPreference,
    this.selectedNine,
    this.guestId,
  });

  final String slotId;
  final String playType;
  final String golfClubName;
  final String golfClubSlug;
  final DateTime selectedDate;
  final String teeTimeSlot;
  final double pricePerPerson;
  final String currency;
  final int playerCount;
  final String caddiePreference;
  final String buggyType;
  final String buggySharingPreference;
  final String? selectedNine;
  final String? guestId;
}

class ShowErrorMessage extends BookingSubmissionSlotNavEffect {
  const ShowErrorMessage(this.message);

  final String message;
}
