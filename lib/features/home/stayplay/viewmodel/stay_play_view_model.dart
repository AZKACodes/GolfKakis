import 'dart:async';

import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/model/stay_play_item.dart';
import 'package:golf_kakis/features/foundation/model/stay_play_view_data.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import '../domain/stay_play_use_case.dart';
import 'stay_play_view_contract.dart';

class StayPlayViewModel
    extends
        MviViewModel<StayPlayUserIntent, StayPlayViewState, StayPlayNavEffect>
    implements StayPlayViewContract {
  StayPlayViewModel({required StayPlayUseCase useCase}) : _useCase = useCase;

  final StayPlayUseCase _useCase;

  @override
  StayPlayViewState createInitialState() => StayPlayDataLoaded.initial;

  @override
  FutureOr<void> handleIntent(StayPlayUserIntent intent) {
    switch (intent) {
      case OnInitStayPlay():
        return _loadStayPlay();
      case OnRefreshStayPlay():
        return _loadStayPlay();
    }
  }

  StayPlayDataLoaded get _currentDataState {
    return switch (currentState) {
      StayPlayDataLoaded() => currentState as StayPlayDataLoaded,
    };
  }

  Future<void> _loadStayPlay() async {
    emitViewState(
      (_) =>
          _currentDataState.copyWith(isLoading: true, clearErrorMessage: true),
    );

    try {
      final result = await _useCase.onFetchStayPlay();
      emitViewState(
        (_) => _currentDataState.copyWith(
          items: result.items.map(_mapItem).toList(),
          isLoading: false,
          clearErrorMessage: true,
        ),
      );
    } catch (_) {
      emitViewState(
        (_) => _currentDataState.copyWith(
          items: const <StayPlayViewData>[],
          isLoading: false,
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message:
                'Unable to load Stay N Play. Pull to refresh and try again.',
          ),
        ),
      );
    }
  }

  StayPlayViewData _mapItem(StayPlayItem item) {
    return StayPlayViewData(
      id: item.id,
      title: item.title,
      description: item.description,
      price: item.price,
      currency: item.currency,
      location: item.location,
      imageUrl: item.imageUrl,
    );
  }
}
