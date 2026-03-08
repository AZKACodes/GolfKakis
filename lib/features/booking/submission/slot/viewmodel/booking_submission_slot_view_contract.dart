import 'package:xxx_demo_app/features/foundation/enums/booking/time_period.dart';
import 'package:xxx_demo_app/features/foundation/default_values.dart';
import 'package:xxx_demo_app/features/foundation/model/booking/booking_slot_model.dart';
import 'package:xxx_demo_app/features/foundation/model/booking/golf_club_model.dart';
import 'package:xxx_demo_app/features/foundation/util/default_constant_util.dart';
import 'package:xxx_demo_app/features/foundation/util/date_util.dart';
import 'package:xxx_demo_app/features/foundation/viewmodel/mvi_contract.dart';

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

  factory BookingSubmissionSlotDataLoaded.initial() {
    return BookingSubmissionSlotDataLoaded(selectedDate: DateTime.now());
  }

  final List<GolfClubModel> golfClubList;
  final List<BookingSlotModel> bookingSlots;
  final String selectedClubSlug;
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

  String get selectedSlotPriceLabel {
    final price = selectedSlot?.price ?? 0;
    final currency =
        selectedSlot?.currency ?? DefaultConstantUtil.defaultCurrency;
    return '$currency ${price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2)} / pax';
  }

  BookingSubmissionSlotDataLoaded copyWith({
    List<GolfClubModel>? golfClubList,
    List<BookingSlotModel>? bookingSlots,
    String? selectedClubSlug,
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
    required this.golfClubName,
    required this.golfClubSlug,
    required this.teeTimeSlot,
    required this.pricePerPerson,
    required this.currency,
    this.guestId,
  });

  final String golfClubName;
  final String golfClubSlug;
  final String teeTimeSlot;
  final double pricePerPerson;
  final String currency;
  final String? guestId;
}
