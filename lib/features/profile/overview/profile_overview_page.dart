import 'package:flutter/material.dart';
import 'dart:async';
import 'package:golf_kakis/features/foundation/session/session_scope.dart';
import 'package:golf_kakis/features/foundation/session/session_state.dart';
import 'package:golf_kakis/features/profile/edit/profile_edit_page.dart';
import 'package:golf_kakis/features/profile/friends/profile_friends_page.dart';
import 'package:golf_kakis/features/profile/login/profile_login_page.dart';
import 'package:golf_kakis/features/profile/overview/domain/profile_overview_use_case_impl.dart';
import 'package:golf_kakis/features/profile/overview/view/profile_overview_view.dart';
import 'package:golf_kakis/features/profile/overview/viewmodel/profile_overview_view_contract.dart';
import 'package:golf_kakis/features/profile/overview/viewmodel/profile_overview_view_model.dart';

class ProfileOverviewPage extends StatefulWidget {
  const ProfileOverviewPage({super.key});

  @override
  State<ProfileOverviewPage> createState() => _ProfileOverviewPageState();
}

class _ProfileOverviewPageState extends State<ProfileOverviewPage> {
  late final ProfileOverviewViewModel _viewModel;
  SessionState? _lastSessionState;
  StreamSubscription<ProfileOverviewNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileOverviewViewModel(
      useCase: const ProfileOverviewUseCaseImpl(),
    );
    _navEffectSubscription = _viewModel.navEffects.listen((effect) {
      if (effect is LogoutRequested) {
        if (!mounted) {
          return;
        }
        SessionScope.of(context).logout();
      }

      if (effect is LoginRequested) {
        if (!mounted) {
          return;
        }
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: _profileLoginRouteName),
            builder: (_) => const ProfileLoginPage(),
            fullscreenDialog: true,
          ),
        );
      }

      if (effect is EditProfileRequested) {
        final profile = _viewModel.viewState.profile;
        if (!mounted || profile == null) {
          return;
        }
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(
            builder: (_) => ProfileEditPage(profile: profile),
          ),
        );
      }

      if (effect is MyGolfKakisRequested) {
        if (!mounted) {
          return;
        }
        final session = SessionScope.of(context).state;
        final ownerId = session.authUserId?.trim().isNotEmpty == true
            ? session.authUserId!.trim()
            : session.deviceId;
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(
            builder: (_) => ProfileFriendsPage(ownerId: ownerId),
          ),
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sessionState = SessionScope.of(context).state;
    if (_lastSessionState != sessionState) {
      _lastSessionState = sessionState;
      _viewModel.onUserIntent(OnInit(sessionState));
    }
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final sessionState = SessionScope.of(context).state;
        return SafeArea(
          child: ProfileOverviewView(
            state: _viewModel.viewState,
            onRefresh: () => _viewModel.refresh(sessionState),
            onPrimaryTouchpointClick: () =>
                _viewModel.onUserIntent(const OnPrimaryTouchpointClick()),
            onMyGolfKakisClick: () =>
                _viewModel.onUserIntent(const OnMyGolfKakisTouchpointClick()),
            onLogoutClick: () => _viewModel.onUserIntent(const OnLogoutClick()),
          ),
        );
      },
    );
  }
}

const String _profileLoginRouteName = 'profile_login';
