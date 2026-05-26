import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/detail/booking_detail_page.dart';
import 'package:golf_kakis/features/booking/overview/domain/booking_overview_use_case_impl.dart';
import 'package:golf_kakis/features/booking/submission/slot/booking_submission_slot_page.dart';
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
  late final TabController _tabController;
  StreamSubscription<BookingOverviewNavEffect>? _navEffectSubscription;
  bool _hasSyncedSession = false;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _viewModel = BookingOverviewViewModel(BookingOverviewUseCaseImpl.create());
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_handleTabChanged);
    _navEffectSubscription = _viewModel.navEffects.listen(_handleNavEffect);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncSessionState();
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _tabController
      ..removeListener(_handleTabChanged)
      ..dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _handleNavEffect(BookingOverviewNavEffect effect) {
    if (!mounted) {
      return;
    }

    switch (effect) {
      case NavigateToBookingDetail():
        Navigator.of(context).push(
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

  @override
  Widget build(BuildContext context) {
    final hasBookings =
        _viewModel.viewState.upcomingBookings.isNotEmpty ||
        _viewModel.viewState.pastBookings.isNotEmpty;

    return Scaffold(
      appBar: widget.showAppBar || hasBookings
          ? AppBar(
              title: const Text('My Bookings'),
              actions: hasBookings
                  ? [
                      IconButton(
                        onPressed: _openNewBooking,
                        icon: const Icon(Icons.add),
                        tooltip: 'Start A New Booking',
                      ),
                    ]
                  : null,
            )
          : null,
      body: SafeArea(
        top: !(widget.showAppBar || hasBookings),
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) => BookingOverviewView(
            controller: _tabController,
            state: _viewModel.viewState,
            onRefresh: _viewModel.onRefresh,
            onStartBookingPressed: _openNewBooking,
            onViewBookingDetailClick: (booking) =>
                _viewModel.onUserIntent(OnViewBookingDetailClick(booking)),
          ),
        ),
      ),
    );
  }

  void _openNewBooking() {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => const BookingSubmissionSlotPage(),
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
