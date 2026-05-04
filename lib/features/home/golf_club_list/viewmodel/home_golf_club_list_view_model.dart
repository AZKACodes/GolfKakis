import 'dart:async';

import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import '../domain/home_golf_club_list_use_case.dart';
import 'home_golf_club_list_view_contract.dart';

class HomeGolfClubListViewModel
    extends
        MviViewModel<
          HomeGolfClubListUserIntent,
          HomeGolfClubListViewState,
          HomeGolfClubListNavEffect
        >
    implements HomeGolfClubListViewContract {
  HomeGolfClubListViewModel({required HomeGolfClubListUseCase useCase})
    : _useCase = useCase;

  final HomeGolfClubListUseCase _useCase;

  @override
  HomeGolfClubListViewState createInitialState() =>
      HomeGolfClubListDataLoaded.initial;

  @override
  FutureOr<void> handleIntent(HomeGolfClubListUserIntent intent) {
    switch (intent) {
      case OnInitHomeGolfClubList():
        return _loadGolfClubs();
      case OnRefreshHomeGolfClubList():
        return _loadGolfClubs();
      case OnGolfClubDetailClick():
        sendNavEffect(() => NavigateToHomeGolfClubDetail(intent.club));
    }
  }

  HomeGolfClubListDataLoaded get _currentDataState {
    return switch (currentState) {
      HomeGolfClubListDataLoaded() =>
        currentState as HomeGolfClubListDataLoaded,
    };
  }

  Future<void> _loadGolfClubs() async {
    emitViewState(
      (_) =>
          _currentDataState.copyWith(isLoading: true, clearErrorMessage: true),
    );

    try {
      final clubs = await _useCase.onFetchGolfClubList();
      emitViewState(
        (_) => _currentDataState.copyWith(
          golfClubList: clubs,
          isLoading: false,
          clearErrorMessage: true,
        ),
      );
    } catch (_) {
      emitViewState(
        (_) => _currentDataState.copyWith(
          isLoading: false,
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message:
                'Unable to load golf clubs. Pull to refresh and try again.',
          ),
        ),
      );
    }
  }
}
