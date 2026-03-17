import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/activity/booking/detail/activity_booking_detail_page.dart';
import 'package:golf_kakis/features/activity/booking/list/activity_booking_list_page.dart';
import 'package:golf_kakis/features/booking/club/detail/golf_club_detail_page.dart';
import 'package:golf_kakis/features/booking/submission/slot/booking_submission_slot_page.dart';

import 'view/booking_overview_view.dart';
import 'viewmodel/booking_overview_view_contract.dart';
import 'viewmodel/booking_overview_view_model.dart';

class BookingOverviewPage extends StatefulWidget {
  const BookingOverviewPage({super.key});

  @override
  State<BookingOverviewPage> createState() => _BookingOverviewPageState();
}

class _BookingOverviewPageState extends State<BookingOverviewPage> {
  late final BookingOverviewViewModel _viewModel;
  StreamSubscription<BookingOverviewNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = BookingOverviewViewModel();
    _navEffectSubscription = _viewModel.navEffects.listen((effect) {
      if (effect is NavigateToBookingSubmission) {
        if (!mounted) {
          return;
        }
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(
            builder: (_) => const BookingSubmissionSlotPage(),
          ),
        );
      }

      if (effect is NavigateToGolfClubDetail) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => GolfClubDetailPage(club: effect.club),
          ),
        );
      }

      if (effect is NavigateToBookingList) {
        if (!mounted) {
          return;
        }
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(
            builder: (_) => const ActivityBookingListPage(),
          ),
        );
      }

      if (effect is NavigateToBookingDetail) {
        if (!mounted) {
          return;
        }
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(
            builder: (_) => ActivityBookingDetailPage(booking: effect.booking),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: BookingOverviewDashboardView(
        onBookingSubmissionClick: () =>
            _viewModel.onUserIntent(const OnBookingSubmissionClick()),
        onPopularClubClick: (club) =>
            _viewModel.onUserIntent(OnPopularClubClick(club)),
        onBookingListClick: () =>
            _viewModel.onUserIntent(const OnBookingListClick()),
        onUpcomingBookingDetailClick: () =>
            _viewModel.onUserIntent(const OnUpcomingBookingDetailClick()),
        onRecentRoundOneDetailClick: () =>
            _viewModel.onUserIntent(const OnRecentRoundOneDetailClick()),
        onRecentRoundTwoDetailClick: () =>
            _viewModel.onUserIntent(const OnRecentRoundTwoDetailClick()),
      ),
    );
  }
}
