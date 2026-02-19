import 'package:flutter/material.dart';

import '../../booking/overview/booking_overview_page.dart';

class BookingNavGraph extends StatelessWidget {
  const BookingNavGraph({super.key});

  static const String root = '/';

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case root:
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const BookingOverviewPage(),
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
