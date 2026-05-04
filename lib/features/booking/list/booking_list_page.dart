import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/detail/booking_detail_page.dart';
import 'package:golf_kakis/features/booking/list/domain/booking_list_use_case_impl.dart';
import 'package:golf_kakis/features/foundation/session/session_scope.dart';

import 'view/booking_list_view.dart';
import 'viewmodel/booking_list_view_contract.dart';
import 'viewmodel/booking_list_view_model.dart';

class BookingListPage extends StatefulWidget {
  const BookingListPage({super.key});

  @override
  State<BookingListPage> createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage>
    with SingleTickerProviderStateMixin {
  BookingListViewModel? _viewModel;
  late final TabController _tabController;

  StreamSubscription<BookingListNavEffect>? _navEffectSubscription;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_handleTabChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel != null) {
      return;
    }

    final accessToken =
        SessionScope.of(context).state.accessToken?.trim() ?? '';
    _viewModel = BookingListViewModel(
      useCase: const BookingListUseCaseImpl(),
      accessToken: accessToken,
    );

    _navEffectSubscription = _viewModel!.navEffects.listen((effect) {
      if (effect is NavigateToBookingDetails) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BookingDetailPage(booking: effect.booking),
          ),
        );
      }

      if (effect is ShowBookingListError) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(effect.message),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    });

    _viewModel!.onUserIntent(const OnInit());
  }

  void _handleTabChanged() {
    if (_tabController.index == _currentTabIndex) {
      return;
    }

    _currentTabIndex = _tabController.index;

    final viewModel = _viewModel;
    if (viewModel == null) {
      return;
    }

    viewModel.onUserIntent(
      OnTabChanged(
        _currentTabIndex == 0 ? BookingListTab.upcoming : BookingListTab.past,
      ),
    );
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _tabController
      ..removeListener(_handleTabChanged)
      ..dispose();
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel;
    if (viewModel == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) => BookingListView(
            controller: _tabController,
            state: viewModel.viewState,
            onRefresh: viewModel.onRefresh,
            onViewBookingDetailClick: (booking) =>
                viewModel.onUserIntent(OnViewBookingDetailClick(booking)),
          ),
        ),
      ),
    );
  }
}
