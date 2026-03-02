import 'package:xxx_demo_app/features/foundation/default_values.dart';
import 'package:xxx_demo_app/features/foundation/model/booking/booking_slot_model.dart';

abstract class BookingSubmissionSlotViewContract {
  BookingSubmissionSlotViewState get viewState;
  Stream<BookingSubmissionSlotNavEffect> get navEffects;
  void onUserIntent(BookingSubmissionSlotUserIntent intent);
}

sealed class BookingSubmissionSlotViewState {
  const BookingSubmissionSlotViewState();

  static const initial = BookingSubmissionSlotDataLoaded();
}

class BookingSubmissionSlotDataLoaded extends BookingSubmissionSlotViewState {
  const BookingSubmissionSlotDataLoaded({
    this.golfClubList = const <String>[],
    this.bookingSlots = const <BookingSlotModel>[],
    this.selectedClubSlug = emptyString,
    this.selectedDate = emptyString,
    this.isLoading = false,
    this.errorMessage = emptyString,
  });

  final List<String> golfClubList;
  final List<BookingSlotModel> bookingSlots;
  final String selectedClubSlug;
  final String selectedDate;
  final bool isLoading;
  final String errorMessage;

  BookingSubmissionSlotDataLoaded copyWith({
    List<String>? golfClubList,
    List<BookingSlotModel>? bookingSlots,
    String? selectedClubSlug,
    String? selectedDate,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return BookingSubmissionSlotDataLoaded(
      golfClubList: golfClubList ?? this.golfClubList,
      bookingSlots: bookingSlots ?? this.bookingSlots,
      selectedClubSlug: selectedClubSlug ?? this.selectedClubSlug,
      selectedDate: selectedDate ?? this.selectedDate,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? emptyString
          : (errorMessage ?? this.errorMessage),
    );
  }
}

sealed class BookingSubmissionSlotUserIntent {
  const BookingSubmissionSlotUserIntent();
}

class OnFetchGolfClubList extends BookingSubmissionSlotUserIntent {
  const OnFetchGolfClubList();
}

class OnFetchAvailableSlots extends BookingSubmissionSlotUserIntent {
  const OnFetchAvailableSlots({required this.clubSlug, required this.date});

  final String clubSlug;
  final String date;
}

class OnSelectGolfClub extends BookingSubmissionSlotUserIntent {
  const OnSelectGolfClub(this.clubSlug);

  final String clubSlug;
}

class OnSelectDate extends BookingSubmissionSlotUserIntent {
  const OnSelectDate(this.date);

  final String date;
}

sealed class NavEffect {
  const NavEffect();
}

sealed class BookingSubmissionSlotNavEffect extends NavEffect {
  const BookingSubmissionSlotNavEffect();
}
