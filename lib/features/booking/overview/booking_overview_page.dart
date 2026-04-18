import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/detail/booking_detail_page.dart';
import 'package:golf_kakis/features/booking/list/booking_list_page.dart';
import 'package:golf_kakis/features/booking/club/detail/golf_club_detail_page.dart';
import 'package:golf_kakis/features/booking/submission/slot/booking_submission_slot_page.dart';
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
  bool _hasSyncedSession = false;

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
            builder: (_) => GolfClubDetailPage(
              clubSlug: effect.club.slug,
              initialClub: effect.club,
            ),
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncSessionState();
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
        onBookingListClick: () =>
            _viewModel.onUserIntent(const OnBookingListClick()),
        onUpcomingBookingDetailClick: () =>
            _viewModel.onUserIntent(const OnUpcomingBookingDetailClick()),
      ),
    );
  }

  void _syncSessionState() {
    final session = SessionScope.of(context).state;
    final isLoggedIn = session.isLoggedIn;
    final accessToken = session.accessToken;

    if (!_hasSyncedSession) {
      _hasSyncedSession = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _viewModel.onUserIntent(
          OnInit(isLoggedIn: isLoggedIn, accessToken: accessToken),
        );
      });
      return;
    }

    _viewModel.onUserIntent(
      OnInit(isLoggedIn: isLoggedIn, accessToken: accessToken),
    );
  }
}
