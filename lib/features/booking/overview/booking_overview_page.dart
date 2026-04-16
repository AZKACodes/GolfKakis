import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/detail/booking_detail_page.dart';
import 'package:golf_kakis/features/booking/list/booking_list_page.dart';
import 'package:golf_kakis/features/booking/club/detail/golf_club_detail_page.dart';
import 'package:golf_kakis/features/booking/submission/slot/booking_submission_slot_page.dart';
import 'package:golf_kakis/features/booking/submission/success/booking_submission_success_page.dart';
import 'package:golf_kakis/features/foundation/session/session_scope.dart';
import 'package:golf_kakis/features/profile/login/profile_login_page.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final accessToken = SessionScope.of(context).state.accessToken;
      _viewModel.onUserIntent(OnInit(accessToken: accessToken));
    });
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
        final session = SessionScope.of(context).state;
        final isLoggedIn =
            session.isLoggedIn &&
            (session.accessToken?.trim().isNotEmpty ?? false);
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                isLoggedIn ? const BookingListPage() : const ProfileLoginPage(),
          ),
        );
      }

      if (effect is NavigateToBookingDetail) {
        if (!mounted) {
          return;
        }
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(
            builder: (_) => BookingDetailPage(booking: effect.booking),
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
        state: _viewModel.viewState,
        onBookingSubmissionClick: () =>
            _viewModel.onUserIntent(const OnBookingSubmissionClick()),
        onReceiptSampleClick: _openSampleReceipt,
        onBookingListClick: () =>
            _viewModel.onUserIntent(const OnBookingListClick()),
        onUpcomingBookingDetailClick: () =>
            _viewModel.onUserIntent(const OnUpcomingBookingDetailClick()),
      ),
    );
  }

  void _openSampleReceipt() {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => const BookingSubmissionSuccessPage(
          bookingId: 'booking-uuid-sample-001',
          bookingRef: 'BK-8F3A2C91',
          bookingDate: '2026-03-27',
          golfClubName: 'Kinrara Golf Club',
          golfClubSlug: 'kinrara-golf-club',
          teeTimeSlot: '07:30 AM',
          pricePerPerson: 137,
          currency: 'MYR',
          hostName: 'Zack Green',
          hostPhoneNumber: '+60123104472',
          playerCount: 4,
          caddieCount: 4,
          golfCartCount: 2,
        ),
      ),
    );
  }
}
