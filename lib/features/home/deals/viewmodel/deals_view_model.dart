import 'dart:async';

import 'package:golf_kakis/features/foundation/model/home_hot_deal_item.dart';
import 'package:golf_kakis/features/foundation/model/home_hot_deal_view_data.dart';
import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import '../domain/deals_use_case.dart';
import 'deals_view_contract.dart';

class DealsViewModel
    extends MviViewModel<DealsUserIntent, DealsViewState, DealsNavEffect>
    implements DealsViewContract {
  DealsViewModel({required DealsUseCase useCase}) : _useCase = useCase;

  final DealsUseCase _useCase;

  @override
  DealsViewState createInitialState() => DealsDataLoaded.initial;

  @override
  FutureOr<void> handleIntent(DealsUserIntent intent) {
    switch (intent) {
      case OnInitDeals():
        return _loadDeals();
      case OnRefreshDeals():
        return _loadDeals();
    }
  }

  DealsDataLoaded get _currentDataState {
    return switch (currentState) {
      DealsDataLoaded() => currentState as DealsDataLoaded,
    };
  }

  Future<void> _loadDeals() async {
    emitViewState(
      (_) =>
          _currentDataState.copyWith(isLoading: true, clearErrorMessage: true),
    );

    try {
      final result = await _useCase.onFetchDealsList();
      emitViewState(
        (_) => _currentDataState.copyWith(
          deals: result.deals.map(_mapDeal).toList(),
          isLoading: false,
          clearErrorMessage: true,
        ),
      );
    } catch (_) {
      emitViewState(
        (_) => _currentDataState.copyWith(
          deals: const <HomeHotDealViewData>[],
          isLoading: false,
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'Unable to load deals. Pull to refresh and try again.',
          ),
        ),
      );
    }
  }

  HomeHotDealViewData _mapDeal(HomeHotDealItem item) {
    return HomeHotDealViewData(
      dealId: item.dealId,
      slotId: item.slotId,
      title: item.title,
      description: item.description,
      price: item.price,
      discountedPrice: item.discountedPrice,
      currency: item.currency,
      golfClubSlug: item.golfClubSlug,
      slotDate: item.slotDate,
      slotTime: item.slotTime,
      noOfHoles: item.noOfHoles,
      imageUrl: item.imageUrl,
    );
  }
}
