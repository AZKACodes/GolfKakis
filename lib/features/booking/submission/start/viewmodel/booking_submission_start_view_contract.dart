import 'package:golf_kakis/features/foundation/default_values.dart';
import 'package:golf_kakis/features/foundation/model/golf_club_model.dart';
import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

abstract class BookingSubmissionStartViewContract {
  BookingSubmissionStartViewState get viewState;
  Stream<BookingSubmissionStartNavEffect> get navEffects;
  void onUserIntent(BookingSubmissionStartUserIntent intent);
}

sealed class BookingSubmissionStartViewState extends ViewState {
  const BookingSubmissionStartViewState();
}

class BookingSubmissionStartDataLoaded extends BookingSubmissionStartViewState {
  const BookingSubmissionStartDataLoaded({
    this.golfClubList = const <GolfClubModel>[],
    this.selectedGolfClub,
    this.playerCount = 2,
    this.isLoadingGolfClubs = emptyBool,
    this.isNearbySortActive = emptyBool,
    this.errorSnackbarMessageModel = SnackbarMessageModel.emptyValue,
  }) : super();

  static const initial = BookingSubmissionStartDataLoaded();

  final List<GolfClubModel> golfClubList;
  final GolfClubModel? selectedGolfClub;
  final int playerCount;
  final bool isLoadingGolfClubs;
  final bool isNearbySortActive;
  final SnackbarMessageModel errorSnackbarMessageModel;

  String get errorMessage => errorSnackbarMessageModel.message;
  bool get canSearch => selectedGolfClub != null;

  BookingSubmissionStartDataLoaded copyWith({
    List<GolfClubModel>? golfClubList,
    GolfClubModel? selectedGolfClub,
    bool clearSelectedGolfClub = false,
    int? playerCount,
    bool? isLoadingGolfClubs,
    bool? isNearbySortActive,
    SnackbarMessageModel? errorSnackbarMessageModel,
    bool clearErrorMessage = false,
  }) {
    return BookingSubmissionStartDataLoaded(
      golfClubList: golfClubList ?? this.golfClubList,
      selectedGolfClub: clearSelectedGolfClub
          ? null
          : (selectedGolfClub ?? this.selectedGolfClub),
      playerCount: playerCount ?? this.playerCount,
      isLoadingGolfClubs: isLoadingGolfClubs ?? this.isLoadingGolfClubs,
      isNearbySortActive: isNearbySortActive ?? this.isNearbySortActive,
      errorSnackbarMessageModel: clearErrorMessage
          ? SnackbarMessageModel.emptyValue
          : (errorSnackbarMessageModel ?? this.errorSnackbarMessageModel),
    );
  }
}

sealed class BookingSubmissionStartUserIntent implements UserIntent {
  const BookingSubmissionStartUserIntent();
}

class OnInitBookingSubmissionStart extends BookingSubmissionStartUserIntent {
  const OnInitBookingSubmissionStart();
}

class OnFetchGolfClubList extends BookingSubmissionStartUserIntent {
  const OnFetchGolfClubList();
}

class OnSelectStartGolfClub extends BookingSubmissionStartUserIntent {
  const OnSelectStartGolfClub(this.club);

  final GolfClubModel club;
}

class OnStartPlayerCountChanged extends BookingSubmissionStartUserIntent {
  const OnStartPlayerCountChanged(this.value);

  final int value;
}

class OnSortStartGolfClubsByNearbyClick
    extends BookingSubmissionStartUserIntent {
  const OnSortStartGolfClubsByNearbyClick();
}

class OnSearchBookingSlotsClick extends BookingSubmissionStartUserIntent {
  const OnSearchBookingSlotsClick();
}

class OnBackClick extends BookingSubmissionStartUserIntent {
  const OnBackClick();
}

sealed class BookingSubmissionStartNavEffect implements NavEffect {
  const BookingSubmissionStartNavEffect();
}

class NavigateBack extends BookingSubmissionStartNavEffect {
  const NavigateBack();
}

class NavigateToBookingSubmissionSlotSelection
    extends BookingSubmissionStartNavEffect {
  const NavigateToBookingSubmissionSlotSelection({
    required this.club,
    required this.playerCount,
  });

  final GolfClubModel club;
  final int playerCount;
}

class ShowBookingSubmissionStartError extends BookingSubmissionStartNavEffect {
  const ShowBookingSubmissionStartError(this.message);

  final String message;
}
