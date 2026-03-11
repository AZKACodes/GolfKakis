import 'package:flutter/material.dart';
import 'dart:async';
import 'package:xxx_demo_app/features/foundation/session/session_scope.dart';
import 'package:xxx_demo_app/features/foundation/session/session_state.dart';
import 'package:xxx_demo_app/features/profile/login/profile_login_page.dart';
import 'package:xxx_demo_app/features/profile/overview/data/profile_overview_repository_impl.dart';
import 'package:xxx_demo_app/features/profile/overview/view/profile_overview_view.dart';
import 'package:xxx_demo_app/features/profile/overview/viewmodel/profile_overview_view_contract.dart';
import 'package:xxx_demo_app/features/profile/overview/viewmodel/profile_overview_view_model.dart';

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
      repository: ProfileOverviewRepositoryImpl(),
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
            builder: (_) => const ProfileLoginPage(),
            fullscreenDialog: true,
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
            onLogoutClick: () => _viewModel.onUserIntent(const OnLogoutClick()),
          ),
        );
      },
    );
  }
}
