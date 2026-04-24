import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/list/booking_list_page.dart';
import 'package:golf_kakis/features/booking/submission/slot/booking_submission_slot_page.dart';
import 'package:golf_kakis/features/home/golf_club_list/home_golf_club_list_page.dart';

import 'view/home_overview_view.dart';

class HomeOverviewPage extends StatelessWidget {
  const HomeOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeView(
      onNewBookingTap: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(
            builder: (_) => const BookingSubmissionSlotPage(),
          ),
        );
      },
      onCoursesTap: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(builder: (_) => const HomeGolfClubListPage()),
        );
      },
      onMyTeeTimesTap: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(builder: (_) => const BookingListPage()),
        );
      },
      onQuickBookTap: (clubSlug) {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                BookingSubmissionSlotPage(initialClubSlug: clubSlug),
          ),
        );
      },
    );
  }
}
