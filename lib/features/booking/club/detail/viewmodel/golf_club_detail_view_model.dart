import 'package:golf_kakis/features/booking/club/detail/data/golf_club_detail_repository.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import 'golf_club_detail_view_contract.dart';

class GolfClubDetailViewModel
    extends
        MviViewModel<
          GolfClubDetailUserIntent,
          GolfClubDetailViewState,
          GolfClubDetailNavEffect
        >
    implements GolfClubDetailViewContract {
  GolfClubDetailViewModel({
    required GolfClubModel club,
    required GolfClubDetailRepository repository,
  }) : _club = club,
       _repository = repository;

  final GolfClubModel _club;
  final GolfClubDetailRepository _repository;

  @override
  GolfClubDetailViewState createInitialState() {
    return GolfClubDetailViewState.initial(_club);
  }

  @override
  Future<void> handleIntent(GolfClubDetailUserIntent intent) async {
    switch (intent) {
      case OnInit():
      case OnRefresh():
        await _loadDetail();
      case OnBackClick():
        sendNavEffect(() => const NavigateBack());
      case OnBookNowClick():
        sendNavEffect(() => const NavigateToBookingSubmission());
    }
  }

  Future<void> _loadDetail() async {
    emitViewState(
      (state) => state.copyWith(isLoading: true, clearErrorMessage: true),
    );

    try {
      final result = await _repository.onFetchGolfClubDetail(club: _club);
      emitViewState(
        (state) => state.copyWith(
          detail: result.detail,
          isLoading: false,
          isUsingFallback: result.isFallback,
          clearErrorMessage: true,
        ),
      );
    } catch (_) {
      emitViewState(
        (state) => state.copyWith(
          isLoading: false,
          isUsingFallback: false,
          errorMessage: 'Unable to load golf club details right now.',
        ),
      );
    }
  }
}
