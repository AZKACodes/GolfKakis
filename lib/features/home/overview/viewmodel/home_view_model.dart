import 'dart:async';
import 'package:golf_kakis/features/foundation/model/home/home_hot_deal_view_data.dart';
import 'package:golf_kakis/features/foundation/model/home/home_quick_book_view_data.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import '../data/home_overview_models.dart';
import '../data/home_repository.dart';
import '../domain/get_home_message_use_case.dart';
import 'home_view_contract.dart';

class HomeViewModel
    extends MviViewModel<HomeUserIntent, HomeViewState, HomeNavEffect>
    implements HomeViewContract {
  HomeViewModel(this._getHomeMessage, this._repository);

  factory HomeViewModel.create() {
    final repository = HomeRepositoryImpl();
    return HomeViewModel(GetHomeMessageUseCase(repository), repository);
  }

  final GetHomeMessageUseCase _getHomeMessage;
  final HomeRepository _repository;

  @override
  HomeViewState createInitialState() => HomeDataLoaded.initial;

  @override
  FutureOr<void> handleIntent(HomeUserIntent intent) {
    switch (intent) {
      case OnInitHome():
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
      final message = await _getHomeMessage();
      final hotDeals = await _repository.fetchHotDeals();
      final quickBookItems = await _repository.fetchQuickBookItems();

      emitViewState(
        (_) => currentState.copyWith(
          message: message,
          isLoading: false,
          hotDeals: hotDeals.map(_mapHotDeal).toList(),
          quickBookItems: quickBookItems.map(_mapQuickBookItem).toList(),
          clearError: true,
        ),
      );
    } catch (_) {
      emitViewState(
        (_) => currentState.copyWith(
          isLoading: false,
          error: 'Failed to load home data',
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

  HomeDataLoaded get _currentDataState {
    return switch (currentState) {
      HomeDataLoaded() => currentState as HomeDataLoaded,
    };
  }
}
