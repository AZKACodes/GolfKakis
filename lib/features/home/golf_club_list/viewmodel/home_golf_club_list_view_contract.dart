import 'package:golf_kakis/features/foundation/default_values.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';
import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

abstract class HomeGolfClubListViewContract {
  HomeGolfClubListViewState get viewState;
  Stream<HomeGolfClubListNavEffect> get navEffects;
  void onUserIntent(HomeGolfClubListUserIntent intent);
}

// ------ View State ------

sealed class HomeGolfClubListViewState implements ViewState {
  const HomeGolfClubListViewState();
}

class HomeGolfClubListDataLoaded extends HomeGolfClubListViewState {
  const HomeGolfClubListDataLoaded({
    this.golfClubList = const <GolfClubModel>[],
    this.isLoading = emptyBool,
    this.errorSnackbarMessageModel = SnackbarMessageModel.emptyValue,
  }) : super();

  static const initial = HomeGolfClubListDataLoaded(isLoading: true);

  final List<GolfClubModel> golfClubList;
  final bool isLoading;
  final SnackbarMessageModel errorSnackbarMessageModel;

  String? get errorMessage => errorSnackbarMessageModel.hasMessage
      ? errorSnackbarMessageModel.message
      : null;

  HomeGolfClubListDataLoaded copyWith({
    List<GolfClubModel>? golfClubList,
    bool? isLoading,
    SnackbarMessageModel? errorSnackbarMessageModel,
    bool clearErrorMessage = false,
  }) {
    return HomeGolfClubListDataLoaded(
      golfClubList: golfClubList ?? this.golfClubList,
      isLoading: isLoading ?? this.isLoading,
      errorSnackbarMessageModel: clearErrorMessage
          ? SnackbarMessageModel.emptyValue
          : (errorSnackbarMessageModel ?? this.errorSnackbarMessageModel),
    );
  }
}

// ------ UserIntent ------

sealed class HomeGolfClubListUserIntent implements UserIntent {
  const HomeGolfClubListUserIntent();
}

class OnInitHomeGolfClubList extends HomeGolfClubListUserIntent {
  const OnInitHomeGolfClubList();
}

class OnRefreshHomeGolfClubList extends HomeGolfClubListUserIntent {
  const OnRefreshHomeGolfClubList();
}

class OnGolfClubDetailClick extends HomeGolfClubListUserIntent {
  const OnGolfClubDetailClick(this.club);

  final GolfClubModel club;
}

// ------ NavEffect ------

sealed class HomeGolfClubListNavEffect implements NavEffect {
  const HomeGolfClubListNavEffect();
}

class NavigateToHomeGolfClubDetail extends HomeGolfClubListNavEffect {
  const NavigateToHomeGolfClubDetail(this.club);

  final GolfClubModel club;
}
