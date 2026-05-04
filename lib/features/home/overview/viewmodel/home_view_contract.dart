import 'package:golf_kakis/features/foundation/default_values.dart';
import 'package:golf_kakis/features/foundation/model/home/home_hot_deal_view_data.dart';
import 'package:golf_kakis/features/foundation/model/home/home_quick_book_view_data.dart';
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
    this.hotDeals = const <HomeHotDealViewData>[],
    this.quickBookItems = const <HomeQuickBookViewData>[],
    this.message = emptyString,
    this.isLoading = emptyBool,
    this.errorSnackbarMessageModel = SnackbarMessageModel.emptyValue,
  }) : super();

  final List<HomeHotDealViewData> hotDeals;
  final List<HomeQuickBookViewData> quickBookItems;
  final String message;
  final bool isLoading;
  final SnackbarMessageModel errorSnackbarMessageModel;

  HomeDataLoaded copyWith({
    List<HomeHotDealViewData>? hotDeals,
    List<HomeQuickBookViewData>? quickBookItems,
    String? message,
    bool? isLoading,
    SnackbarMessageModel? errorSnackbarMessageModel,
    bool clearError = false,
  }) {
    return HomeDataLoaded(
      message: message ?? this.message,
      isLoading: isLoading ?? this.isLoading,
      errorSnackbarMessageModel: clearError
          ? SnackbarMessageModel.emptyValue
          : (errorSnackbarMessageModel ?? this.errorSnackbarMessageModel),
      hotDeals: hotDeals ?? this.hotDeals,
      quickBookItems: quickBookItems ?? this.quickBookItems,
    );
  }

  static const initial = HomeDataLoaded();
}

// ------ UserIntent ------

sealed class HomeUserIntent implements UserIntent {
  const HomeUserIntent();
}

class OnInitHome extends HomeUserIntent {
  const OnInitHome();
}

class OnRefreshHome extends HomeUserIntent {
  const OnRefreshHome();
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

class OnQuickBookClick extends HomeUserIntent {
  const OnQuickBookClick(this.clubSlug);

  final String clubSlug;
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

class NavigateToQuickBook extends HomeNavEffect {
  const NavigateToQuickBook(this.clubSlug);

  final String clubSlug;
}
