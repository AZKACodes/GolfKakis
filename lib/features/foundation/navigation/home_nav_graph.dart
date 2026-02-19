import 'package:flutter/material.dart';

import '../../home/overview/home_overview_page.dart';

class HomeNavGraph extends StatelessWidget {
  const HomeNavGraph({super.key});

  static const String root = '/';

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case root:
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const HomeOverviewPage(),
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
