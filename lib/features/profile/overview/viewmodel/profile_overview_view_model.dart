import 'package:golf_kakis/features/foundation/session/session_state.dart';
import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import '../domain/profile_overview_use_case.dart';
import 'profile_overview_view_contract.dart';

class ProfileOverviewViewModel
    extends
        MviViewModel<
          ProfileOverviewUserIntent,
          ProfileOverviewViewState,
          ProfileOverviewNavEffect
        >
    implements ProfileOverviewViewContract {
  ProfileOverviewViewModel({required ProfileOverviewUseCase useCase})
    : _useCase = useCase;

  final ProfileOverviewUseCase _useCase;

  @override
  ProfileOverviewViewState createInitialState() {
    return ProfileOverviewViewState.initial;
  }

  @override
  Future<void> handleIntent(ProfileOverviewUserIntent intent) async {
    switch (intent) {
      case OnInit():
        await _loadProfile(intent.session);
      case OnRefresh():
        await _loadProfile(intent.session);
      case OnLogoutClick():
        sendNavEffect(() => const LogoutRequested());
      case OnPrimaryTouchpointClick():
        if (currentState.profile?.isLoggedIn == false) {
          sendNavEffect(() => const LoginRequested());
        } else if (currentState.profile?.isLoggedIn == true) {
          sendNavEffect(() => const EditProfileRequested());
        }
      case OnMyGolfKakisTouchpointClick():
        if (currentState.profile?.isLoggedIn == false) {
          sendNavEffect(() => const LoginRequested());
        } else if (currentState.profile?.isLoggedIn == true) {
          sendNavEffect(() => const MyGolfKakisRequested());
        }
    }
  }

  Future<void> refresh(SessionState session) {
    return _loadProfile(session);
  }

  Future<void> _loadProfile(SessionState session) async {
    emitViewState(
      (state) => state.copyWith(isLoading: true, clearErrorMessage: true),
    );

    try {
      final result = await _useCase.fetchUserProfile(session: session);
      emitViewState(
        (state) => state.copyWith(
          isLoading: false,
          isUsingFallback: result.isFallback,
          profile: result.profile,
          clearErrorMessage: true,
        ),
      );
    } catch (_) {
      emitViewState(
        (state) => state.copyWith(
          isLoading: false,
          isUsingFallback: false,
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'Unable to load profile right now.',
          ),
        ),
      );
    }
  }
}
