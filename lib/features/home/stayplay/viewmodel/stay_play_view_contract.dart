import 'package:golf_kakis/features/foundation/default_values.dart';
import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/model/stay_play_view_data.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

abstract class StayPlayViewContract {
  StayPlayViewState get viewState;
  Stream<StayPlayNavEffect> get navEffects;
  void onUserIntent(StayPlayUserIntent intent);
}

sealed class StayPlayViewState implements ViewState {
  const StayPlayViewState();
}

class StayPlayDataLoaded extends StayPlayViewState {
  const StayPlayDataLoaded({
    this.items = const <StayPlayViewData>[],
    this.isLoading = emptyBool,
    this.errorSnackbarMessageModel = SnackbarMessageModel.emptyValue,
  }) : super();

  static const initial = StayPlayDataLoaded(isLoading: true);

  final List<StayPlayViewData> items;
  final bool isLoading;
  final SnackbarMessageModel errorSnackbarMessageModel;

  String? get errorMessage => errorSnackbarMessageModel.hasMessage
      ? errorSnackbarMessageModel.message
      : null;

  StayPlayDataLoaded copyWith({
    List<StayPlayViewData>? items,
    bool? isLoading,
    SnackbarMessageModel? errorSnackbarMessageModel,
    bool clearErrorMessage = false,
  }) {
    return StayPlayDataLoaded(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorSnackbarMessageModel: clearErrorMessage
          ? SnackbarMessageModel.emptyValue
          : (errorSnackbarMessageModel ?? this.errorSnackbarMessageModel),
    );
  }
}

sealed class StayPlayUserIntent implements UserIntent {
  const StayPlayUserIntent();
}

class OnInitStayPlay extends StayPlayUserIntent {
  const OnInitStayPlay();
}

class OnRefreshStayPlay extends StayPlayUserIntent {
  const OnRefreshStayPlay();
}

sealed class StayPlayNavEffect implements NavEffect {
  const StayPlayNavEffect();
}
