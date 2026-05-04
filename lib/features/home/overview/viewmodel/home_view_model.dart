import 'dart:async';
import 'package:golf_kakis/features/foundation/model/home/home_hot_deal_view_data.dart';
import 'package:golf_kakis/features/foundation/model/home/home_hot_deal_item.dart';
import 'package:golf_kakis/features/foundation/model/home/home_quick_book_item.dart';
import 'package:golf_kakis/features/foundation/model/home/home_quick_book_view_data.dart';
import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import '../domain/home_overview_use_case.dart';
import 'home_view_contract.dart';

class HomeViewModel
    extends MviViewModel<HomeUserIntent, HomeViewState, HomeNavEffect>
    implements HomeViewContract {
  HomeViewModel(this._useCase);
  final HomeOverviewUseCase _useCase;

  HomeDataLoaded get _currentDataState {
    return switch (currentState) {
      HomeDataLoaded() => currentState as HomeDataLoaded,
    };
  }

  @override
  HomeViewState createInitialState() => HomeDataLoaded.initial;

  @override
  FutureOr<void> handleIntent(HomeUserIntent intent) {
    switch (intent) {
      case OnInitHome():
      case OnRefreshHome():
        return _loadData();
      case OnNewBookingClick():
        sendNavEffect(() => const NavigateToBookingSlotSubmission());
      case OnGolfClubListClick():
        sendNavEffect(() => const NavigateToGolfClubList());
      case OnBookingListClick():
        sendNavEffect(() => const NavigateToBookingOverview());
      case OnQuickBookClick():
        sendNavEffect(() => NavigateToQuickBook(intent.clubSlug));
    }
  }

  Future<void> _loadData() async {
    final currentState = _currentDataState;
    emitViewState(
      (_) => currentState.copyWith(isLoading: true, clearError: true),
    );

    try {
      final result = await _useCase.onFetchHomeOverviewDetails();

      emitViewState(
        (_) => currentState.copyWith(
          message: result.message,
          isLoading: false,
          hotDeals: result.hotDeals.map(_mapHotDeal).toList(),
          quickBookItems: result.quickBookItems.map(_mapQuickBookItem).toList(),
          clearError: true,
        ),
      );
    } catch (_) {
      emitViewState(
        (_) => currentState.copyWith(
          isLoading: false,
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'Failed to load home data',
          ),
          hotDeals: const <HomeHotDealViewData>[],
          quickBookItems: const <HomeQuickBookViewData>[],
        ),
      );
    }
  }

  HomeHotDealViewData _mapHotDeal(HomeHotDealItem item) {
    return HomeHotDealViewData(
      title: item.title,
      subtitle: item.subtitle,
      priceLabel: item.priceLabel,
      badge: item.badge,
    );
  }

  HomeQuickBookViewData _mapQuickBookItem(HomeQuickBookItem item) {
    return HomeQuickBookViewData(
      clubSlug: item.clubSlug,
      title: item.title,
      subtitle: item.subtitle,
      priceLabel: item.priceLabel,
      badge: item.badge,
    );
  }
}
