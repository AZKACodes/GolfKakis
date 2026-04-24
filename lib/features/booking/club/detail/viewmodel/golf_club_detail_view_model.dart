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
    required String clubSlug,
    GolfClubModel? initialClub,
    required GolfClubDetailRepository repository,
  }) : _clubSlug = clubSlug,
       _initialClub =
           initialClub ??
           GolfClubModel(
             id: '',
             slug: clubSlug,
             name: 'Golf Club',
             address: '',
             noOfHoles: 18,
           ),
       _repository = repository;

  final String _clubSlug;
  final GolfClubModel _initialClub;
  final GolfClubDetailRepository _repository;

  @override
  GolfClubDetailViewState createInitialState() {
    return GolfClubDetailViewState.initial(_initialClub);
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
      final result = await _repository.onFetchGolfClubDetail(
        slug: _clubSlug,
        initialClub: _initialClub,
      );
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
          clearErrorMessage: true,
        ),
      );
    }
  }
}
