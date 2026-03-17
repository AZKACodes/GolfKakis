import 'package:golf_kakis/features/foundation/model/profile/user_profile_model.dart';
import 'package:golf_kakis/features/foundation/session/session_state.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

abstract class ProfileOverviewViewContract {
  ProfileOverviewViewState get viewState;
  Stream<ProfileOverviewNavEffect> get navEffects;
  void onUserIntent(ProfileOverviewUserIntent intent);
}

class ProfileOverviewViewState extends ViewState {
  const ProfileOverviewViewState({
    required this.isLoading,
    required this.isUsingFallback,
    this.profile,
    this.errorMessage,
  }) : super();

  static const initial = ProfileOverviewViewState(
    isLoading: false,
    isUsingFallback: false,
  );

  final bool isLoading;
  final bool isUsingFallback;
  final UserProfileModel? profile;
  final String? errorMessage;

  ProfileOverviewViewState copyWith({
    bool? isLoading,
    bool? isUsingFallback,
    UserProfileModel? profile,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ProfileOverviewViewState(
      isLoading: isLoading ?? this.isLoading,
      isUsingFallback: isUsingFallback ?? this.isUsingFallback,
      profile: profile ?? this.profile,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

sealed class ProfileOverviewUserIntent extends UserIntent {
  const ProfileOverviewUserIntent() : super();
}

class OnInit extends ProfileOverviewUserIntent {
  const OnInit(this.session);

  final SessionState session;
}

class OnRefresh extends ProfileOverviewUserIntent {
  const OnRefresh(this.session);

  final SessionState session;
}

class OnLogoutClick extends ProfileOverviewUserIntent {
  const OnLogoutClick();
}

class OnPrimaryTouchpointClick extends ProfileOverviewUserIntent {
  const OnPrimaryTouchpointClick();
}

sealed class ProfileOverviewNavEffect extends NavEffect {
  const ProfileOverviewNavEffect() : super();
}

class LogoutRequested extends ProfileOverviewNavEffect {
  const LogoutRequested();
}

class LoginRequested extends ProfileOverviewNavEffect {
  const LoginRequested();
}
