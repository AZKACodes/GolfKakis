import 'package:flutter/material.dart';

import '../../profile/overview/profile_overview_page.dart';

class ProfileNavGraph extends StatelessWidget {
  const ProfileNavGraph({super.key});

  static const String root = '/';

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case root:
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ProfileOverviewPage(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: _onGenerateRoute,
    );
  }
}
