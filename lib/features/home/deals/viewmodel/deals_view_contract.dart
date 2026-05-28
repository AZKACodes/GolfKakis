import 'package:golf_kakis/features/foundation/default_values.dart';
import 'package:golf_kakis/features/foundation/model/home_hot_deal_view_data.dart';
import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

abstract class DealsViewContract {
  DealsViewState get viewState;
  Stream<DealsNavEffect> get navEffects;
  void onUserIntent(DealsUserIntent intent);
}

sealed class DealsViewState implements ViewState {
  const DealsViewState();
}

class DealsDataLoaded extends DealsViewState {
  const DealsDataLoaded({
    this.deals = const <HomeHotDealViewData>[],
    this.isLoading = emptyBool,
    this.errorSnackbarMessageModel = SnackbarMessageModel.emptyValue,
  }) : super();

  static const initial = DealsDataLoaded(isLoading: true);

  final List<HomeHotDealViewData> deals;
  final bool isLoading;
  final SnackbarMessageModel errorSnackbarMessageModel;

  String? get errorMessage => errorSnackbarMessageModel.hasMessage
      ? errorSnackbarMessageModel.message
      : null;

  DealsDataLoaded copyWith({
    List<HomeHotDealViewData>? deals,
    bool? isLoading,
    SnackbarMessageModel? errorSnackbarMessageModel,
    bool clearErrorMessage = false,
  }) {
    return DealsDataLoaded(
      deals: deals ?? this.deals,
      isLoading: isLoading ?? this.isLoading,
      errorSnackbarMessageModel: clearErrorMessage
          ? SnackbarMessageModel.emptyValue
          : (errorSnackbarMessageModel ?? this.errorSnackbarMessageModel),
    );
  }
}

sealed class DealsUserIntent implements UserIntent {
  const DealsUserIntent();
}

class OnInitDeals extends DealsUserIntent {
  const OnInitDeals();
}

class OnRefreshDeals extends DealsUserIntent {
  const OnRefreshDeals();
}

sealed class DealsNavEffect implements NavEffect {
  const DealsNavEffect();
}
