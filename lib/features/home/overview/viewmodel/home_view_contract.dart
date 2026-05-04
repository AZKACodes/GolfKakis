import 'package:golf_kakis/features/foundation/default_values.dart';
import 'package:golf_kakis/features/foundation/model/home/home_advertisement_view_data.dart';
import 'package:golf_kakis/features/foundation/model/home/home_hot_deal_view_data.dart';
import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

abstract class HomeViewContract {
  HomeViewState get viewState;
  Stream<HomeNavEffect> get navEffects;
  void onUserIntent(HomeUserIntent intent);
}

// ------ View State ------

sealed class HomeViewState implements ViewState {
  const HomeViewState();
}

class HomeDataLoaded extends HomeViewState {
  const HomeDataLoaded({
    this.advertisements = const <HomeAdvertisementViewData>[],
    this.deals = const <HomeHotDealViewData>[],
    this.headerDisplayName = emptyString,
    this.headerAvatarIndex = 0,
    this.isLoading = emptyBool,
    this.errorSnackbarMessageModel = SnackbarMessageModel.emptyValue,
  }) : super();

  final List<HomeAdvertisementViewData> advertisements;
  final List<HomeHotDealViewData> deals;
  final String headerDisplayName;
  final int headerAvatarIndex;
  final bool isLoading;
  final SnackbarMessageModel errorSnackbarMessageModel;

  HomeDataLoaded copyWith({
    List<HomeAdvertisementViewData>? advertisements,
    List<HomeHotDealViewData>? deals,
    String? headerDisplayName,
    int? headerAvatarIndex,
    bool? isLoading,
    SnackbarMessageModel? errorSnackbarMessageModel,
    bool clearError = false,
  }) {
    return HomeDataLoaded(
      headerDisplayName: headerDisplayName ?? this.headerDisplayName,
      headerAvatarIndex: headerAvatarIndex ?? this.headerAvatarIndex,
      isLoading: isLoading ?? this.isLoading,
      errorSnackbarMessageModel: clearError
          ? SnackbarMessageModel.emptyValue
          : (errorSnackbarMessageModel ?? this.errorSnackbarMessageModel),
      advertisements: advertisements ?? this.advertisements,
      deals: deals ?? this.deals,
    );
  }

  static const initial = HomeDataLoaded();
}

// ------ UserIntent ------

sealed class HomeUserIntent implements UserIntent {
  const HomeUserIntent();
}

class OnHomeOverviewInit extends HomeUserIntent {
  const OnHomeOverviewInit({required this.isLoggedIn, this.accessToken});

  final bool isLoggedIn;
  final String? accessToken;
}

class OnRefreshHomeOverview extends HomeUserIntent {
  const OnRefreshHomeOverview({required this.isLoggedIn, this.accessToken});

  final bool isLoggedIn;
  final String? accessToken;
}

class OnNewBookingClick extends HomeUserIntent {
  const OnNewBookingClick();
}

class OnGolfClubListClick extends HomeUserIntent {
  const OnGolfClubListClick();
}

class OnBookingListClick extends HomeUserIntent {
  const OnBookingListClick();
}

// ------ NavEffect ------

sealed class HomeNavEffect implements NavEffect {
  const HomeNavEffect();
}

class NavigateToBookingSlotSubmission extends HomeNavEffect {
  const NavigateToBookingSlotSubmission();
}

class NavigateToGolfClubList extends HomeNavEffect {
  const NavigateToGolfClubList();
}

class NavigateToBookingOverview extends HomeNavEffect {
  const NavigateToBookingOverview();
}
