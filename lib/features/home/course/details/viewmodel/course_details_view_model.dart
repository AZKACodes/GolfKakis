import 'package:golf_kakis/features/foundation/model/golf_club_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import '../domain/course_details_use_case.dart';
import 'course_details_view_contract.dart';

class CourseDetailsViewModel
    extends
        MviViewModel<
          CourseDetailsUserIntent,
          CourseDetailsViewState,
          CourseDetailsNavEffect
        >
    implements CourseDetailsViewContract {
  CourseDetailsViewModel({
    required String clubSlug,
    GolfClubModel? initialClub,
    required CourseDetailsUseCase useCase,
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
  final CourseDetailsUseCase _useCase;

  @override
  CourseDetailsViewState createInitialState() {
    return CourseDetailsViewState.initial(_initialClub);
  }

  @override
  Future<void> handleIntent(CourseDetailsUserIntent intent) async {
    switch (intent) {
      case OnInit():
      case OnRefresh():
        await _loadDetail();
      case OnBackClick():
        sendNavEffect(() => const NavigateBack());
      case OnBookNowClick():
      case OnQuickBookClick():
        sendNavEffect(() => const NavigateToBookingSubmission());
    }
  }

  Future<void> _loadDetail() async {
    emitViewState(
      (state) => state.copyWith(isLoading: true, clearErrorMessage: true),
    );

    try {
      final result = await _useCase.onInitCourseDetailInit(
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
