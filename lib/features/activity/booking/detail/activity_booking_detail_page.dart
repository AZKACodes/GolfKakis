import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/activity/booking/detail/data/activity_booking_detail_repository_impl.dart';
import 'package:golf_kakis/features/activity/booking/edit/activity_booking_edit_page.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';

import 'view/activity_booking_detail_view.dart';
import 'viewmodel/activity_booking_detail_view_contract.dart';
import 'viewmodel/activity_booking_detail_view_model.dart';

class ActivityBookingDetailPage extends StatefulWidget {
  const ActivityBookingDetailPage({required this.booking, super.key});

  final BookingModel booking;

  @override
  State<ActivityBookingDetailPage> createState() =>
      _ActivityBookingDetailPageState();
}

class _ActivityBookingDetailPageState extends State<ActivityBookingDetailPage> {
  late final ActivityBookingDetailViewModel _viewModel;
  StreamSubscription<ActivityBookingDetailNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = ActivityBookingDetailViewModel(
      initialBooking: widget.booking,
      repository: ActivityBookingDetailRepositoryImpl(),
    );
    _navEffectSubscription = _viewModel.navEffects.listen((effect) async {
      if (effect is NavigateBack) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).pop(effect.updatedBooking);
      }

      if (effect is NavigateToActivityBookingEdit) {
        if (!mounted) {
          return;
        }
        final updatedBooking = await Navigator.of(context).push<BookingModel>(
          MaterialPageRoute<BookingModel>(
            builder: (_) => ActivityBookingEditPage(booking: effect.booking),
          ),
        );
        if (updatedBooking != null) {
          _viewModel.onUserIntent(OnBookingUpdated(updatedBooking));
        }
      }
    });
    _viewModel.onUserIntent(const OnInit());
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Booking Detail'),
            leading: IconButton(
              onPressed: () => _viewModel.onUserIntent(const OnBackClick()),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: SafeArea(
            child: ActivityBookingDetailView(
              state: _viewModel.viewState,
              onRefresh: () async => _viewModel.onUserIntent(const OnRefresh()),
              onDeleteClick: () =>
                  _viewModel.onUserIntent(const OnDeleteClick()),
              onEditDetailsClick: () =>
                  _viewModel.onUserIntent(const OnEditDetailsClick()),
            ),
          ),
        );
      },
    );
  }
}
