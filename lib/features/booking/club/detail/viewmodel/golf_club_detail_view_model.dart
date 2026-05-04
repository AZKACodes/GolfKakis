import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import '../domain/golf_club_detail_use_case.dart';
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
    required GolfClubDetailUseCase useCase,
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
       _useCase = useCase;

  final String _clubSlug;
  final GolfClubModel _initialClub;
  final GolfClubDetailUseCase _useCase;

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
      final result = await _useCase.fetchGolfClubDetail(
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
