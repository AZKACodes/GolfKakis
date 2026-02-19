import 'package:flutter/material.dart';

import '../../activity/overview/activity_overview_page.dart';

class ActivityNavGraph extends StatelessWidget {
  const ActivityNavGraph({super.key});

  static const String root = '/';

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case root:
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ActivityOverviewPage(),
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
