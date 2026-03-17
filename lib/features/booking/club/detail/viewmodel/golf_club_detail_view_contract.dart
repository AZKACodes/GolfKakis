import 'package:golf_kakis/features/booking/club/detail/data/golf_club_detail_repository.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

abstract class GolfClubDetailViewContract {
  GolfClubDetailViewState get viewState;
  Stream<GolfClubDetailNavEffect> get navEffects;
  void onUserIntent(GolfClubDetailUserIntent intent);
}

class GolfClubDetailViewState extends ViewState {
  const GolfClubDetailViewState({
    required this.detail,
    required this.isLoading,
    required this.isUsingFallback,
    this.errorMessage,
  }) : super();

  factory GolfClubDetailViewState.initial(GolfClubModel club) {
    return GolfClubDetailViewState(
      detail: GolfClubDetailData(
        club: club,
        distanceLabel: '',
        openSlotsLabel: '',
        greenFeeLabel: '',
        peakLabel: '',
        description: '',
        bestForLabel: '',
        facilityLabels: const <String>[],
      ),
      isLoading: false,
      isUsingFallback: false,
    );
  }

  final GolfClubDetailData detail;
  final bool isLoading;
  final bool isUsingFallback;
  final String? errorMessage;

  GolfClubDetailViewState copyWith({
    GolfClubDetailData? detail,
    bool? isLoading,
    bool? isUsingFallback,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return GolfClubDetailViewState(
      detail: detail ?? this.detail,
      isLoading: isLoading ?? this.isLoading,
      isUsingFallback: isUsingFallback ?? this.isUsingFallback,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

sealed class GolfClubDetailUserIntent extends UserIntent {
  const GolfClubDetailUserIntent() : super();
}

class OnInit extends GolfClubDetailUserIntent {
  const OnInit();
}

class OnRefresh extends GolfClubDetailUserIntent {
  const OnRefresh();
}

class OnBackClick extends GolfClubDetailUserIntent {
  const OnBackClick();
}

class OnBookNowClick extends GolfClubDetailUserIntent {
  const OnBookNowClick();
}

sealed class GolfClubDetailNavEffect extends NavEffect {
  const GolfClubDetailNavEffect() : super();
}

class NavigateBack extends GolfClubDetailNavEffect {
  const NavigateBack();
}

class NavigateToBookingSubmission extends GolfClubDetailNavEffect {
  const NavigateToBookingSubmission();
}
