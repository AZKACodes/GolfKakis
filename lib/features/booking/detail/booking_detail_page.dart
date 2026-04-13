import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/detail/data/booking_detail_repository_impl.dart';
import 'package:golf_kakis/features/booking/edit/booking_edit_page.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';

import 'view/booking_detail_view.dart';
import 'viewmodel/booking_detail_view_contract.dart';
import 'viewmodel/booking_detail_view_model.dart';

class BookingDetailPage extends StatefulWidget {
  const BookingDetailPage({required this.booking, super.key});

  final BookingModel booking;

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  late final BookingDetailViewModel _viewModel;
  StreamSubscription<BookingDetailNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = BookingDetailViewModel(
      initialBooking: widget.booking,
      repository: BookingDetailRepositoryImpl(),
    );
    _navEffectSubscription = _viewModel.navEffects.listen((effect) async {
      if (effect is NavigateBack) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).pop(effect.updatedBooking);
      }

      if (effect is NavigateToBookingEdit) {
        if (!mounted) {
          return;
        }
        final updatedBooking = await Navigator.of(context).push<BookingModel>(
          MaterialPageRoute<BookingModel>(
            builder: (_) => BookingEditPage(booking: effect.booking),
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
            child: BookingDetailView(
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
