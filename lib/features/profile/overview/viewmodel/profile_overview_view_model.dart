import 'package:golf_kakis/features/foundation/session/session_state.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';
import 'package:golf_kakis/features/profile/overview/data/profile_overview_repository.dart';

import 'profile_overview_view_contract.dart';

class ProfileOverviewViewModel
    extends
        MviViewModel<
          ProfileOverviewUserIntent,
          ProfileOverviewViewState,
          ProfileOverviewNavEffect
        >
    implements ProfileOverviewViewContract {
  ProfileOverviewViewModel({required ProfileOverviewRepository repository})
    : _repository = repository;

  final ProfileOverviewRepository _repository;

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
      final result = await _repository.onFetchUserProfile(session: session);
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
          errorMessage: 'Unable to load profile right now.',
        ),
      );
    }
  }
}
