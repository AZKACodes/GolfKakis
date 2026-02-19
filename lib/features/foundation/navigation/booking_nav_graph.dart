import 'package:flutter/material.dart';

import '../../booking/overview/booking_overview_page.dart';
import '../../booking/submission/booking_submission_page.dart';

class BookingNavGraph extends StatelessWidget {
  const BookingNavGraph({super.key});

  static const String root = '/';
  static const String submission = '/submission';

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case submission:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const BookingSubmissionPage(),
        );
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
