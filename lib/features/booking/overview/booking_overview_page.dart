import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/detail/booking_detail_page.dart';
import 'package:golf_kakis/features/booking/overview/domain/booking_overview_use_case_impl.dart';
import 'package:golf_kakis/features/booking/submission/slot/booking_submission_slot_page.dart';
import 'package:golf_kakis/features/booking/submission/slot/domain/booking_submission_slot_use_case_impl.dart';
import 'package:golf_kakis/features/booking/submission/start/viewmodel/booking_submission_start_view_contract.dart'
    as start;
import 'package:golf_kakis/features/booking/submission/start/viewmodel/booking_submission_start_view_model.dart';
import 'package:golf_kakis/features/foundation/navigation/booking_nav_graph.dart';
import 'package:golf_kakis/features/foundation/session/session_scope.dart';

import 'view/booking_overview_view.dart';
import 'viewmodel/booking_overview_view_contract.dart';
import 'viewmodel/booking_overview_view_model.dart';

class BookingOverviewPage extends StatefulWidget {
  const BookingOverviewPage({this.showAppBar = false, super.key});

  final bool showAppBar;

  @override
  State<BookingOverviewPage> createState() => _BookingOverviewPageState();
}

class _BookingOverviewPageState extends State<BookingOverviewPage>
    with SingleTickerProviderStateMixin {
  late final BookingOverviewViewModel _viewModel;
  late final BookingSubmissionStartViewModel _startBookingViewModel;
  late final TabController _tabController;
  StreamSubscription<BookingOverviewNavEffect>? _navEffectSubscription;
  StreamSubscription<start.BookingSubmissionStartNavEffect>?
  _startBookingNavEffectSubscription;
  StreamSubscription<void>? _overviewRefreshRequestSubscription;
  bool _hasSyncedSession = false;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _viewModel = BookingOverviewViewModel(BookingOverviewUseCaseImpl.create());
    _startBookingViewModel = BookingSubmissionStartViewModel(
      useCase: BookingSubmissionSlotUseCaseImpl.create(),
    );
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_handleTabChanged);
    _navEffectSubscription = _viewModel.navEffects.listen(_handleNavEffect);
    _startBookingNavEffectSubscription = _startBookingViewModel.navEffects
        .listen(_handleStartBookingNavEffect);
    _overviewRefreshRequestSubscription = BookingNavGraph
        .overviewRefreshRequests
        .listen((_) => _refreshUpcomingBookings());
    _startBookingViewModel.onUserIntent(
      const start.OnInitBookingSubmissionStart(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncSessionState();
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _startBookingNavEffectSubscription?.cancel();
    _overviewRefreshRequestSubscription?.cancel();
    _tabController
      ..removeListener(_handleTabChanged)
      ..dispose();
    _viewModel.dispose();
    _startBookingViewModel.dispose();
    super.dispose();
  }

  void _handleNavEffect(BookingOverviewNavEffect effect) {
    if (!mounted) {
      return;
    }

    switch (effect) {
      case NavigateToBookingDetail():
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(
            builder: (_) => BookingDetailPage(booking: effect.booking),
          ),
        );
      case ShowBookingOverviewError():
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(effect.message),
              behavior: SnackBarBehavior.floating,
            ),
          );
    }
  }

  void _handleStartBookingNavEffect(
    start.BookingSubmissionStartNavEffect effect,
  ) {
    if (!mounted) {
      return;
    }

    switch (effect) {
      case start.NavigateBack():
        Navigator.of(context).maybePop();
      case start.NavigateToBookingSubmissionSlotSelection():
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(
            builder: (_) => BookingSubmissionSlotPage(
              initialClubSlug: effect.club.slug,
              initialClub: effect.club,
              initialPlayerCount: effect.playerCount,
            ),
          ),
        );
      case start.ShowBookingSubmissionStartError():
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(effect.message)));
    }
  }

  void _handleTabChanged() {
    if (_tabController.index == _currentTabIndex) {
      return;
    }

    _currentTabIndex = _tabController.index;
    _viewModel.onUserIntent(
      OnTabChanged(
        _currentTabIndex == 0
            ? BookingOverviewTab.upcoming
            : BookingOverviewTab.past,
      ),
    );
  }

  void _refreshUpcomingBookings() {
    if (!mounted) {
      return;
    }

    if (_tabController.index != 0) {
      _tabController.animateTo(0);
    }
    _viewModel.onRefresh(BookingOverviewTab.upcoming);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: const Text('My Bookings'))
          : null,
      body: SafeArea(
        top: !widget.showAppBar,
        child: ListenableBuilder(
          listenable: Listenable.merge([_viewModel, _startBookingViewModel]),
          builder: (context, _) => BookingOverviewView(
            controller: _tabController,
            state: _viewModel.viewState,
            startBookingState: _startBookingViewModel.viewState,
            onLoadStartGolfClubs: () async {
              await _startBookingViewModel.onFetchGolfClubList();
              return _startBookingViewModel.currentDataState;
            },
            onRefresh: _viewModel.onRefresh,
            onRefreshCalendar: _viewModel.onRefreshCalendar,
            onStartBookingIntent: _startBookingViewModel.onUserIntent,
            onViewModeChanged: (viewMode) => _viewModel.onUserIntent(
              OnBookingOverviewViewModeChanged(viewMode),
            ),
            onViewBookingDetailClick: (booking) =>
                _viewModel.onUserIntent(OnViewBookingDetailClick(booking)),
          ),
        ),
      ),
    );
  }

  void _syncSessionState() {
    final session = SessionScope.of(context).state;
    final isLoggedIn = session.isLoggedIn;
    final accessToken = session.accessToken?.trim() ?? '';

    if (!_hasSyncedSession) {
      _hasSyncedSession = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _viewModel.onUserIntent(
          OnInitBookingOverview(
            isLoggedIn: isLoggedIn,
            accessToken: accessToken,
          ),
        );
      });
      return;
    }

    _viewModel.onUserIntent(
      OnInitBookingOverview(isLoggedIn: isLoggedIn, accessToken: accessToken),
    );
  }
}
