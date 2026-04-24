import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/detail/data/booking_detail_repository_impl.dart';
import 'package:golf_kakis/features/booking/edit/booking_edit_page.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';
import 'package:golf_kakis/features/foundation/session/session_scope.dart';

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
  BookingDetailViewModel? _viewModel;
  StreamSubscription<BookingDetailNavEffect>? _navEffectSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel != null) {
      return;
    }

    final accessToken =
        SessionScope.of(context).state.accessToken?.trim() ?? '';
    _viewModel = BookingDetailViewModel(
      initialBooking: widget.booking,
      repository: BookingDetailRepositoryImpl(accessToken: accessToken),
    );
    _navEffectSubscription = _viewModel!.navEffects.listen((effect) async {
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
          _viewModel!.onUserIntent(OnBookingUpdated(updatedBooking));
        }
      }
    });
    _viewModel!.onUserIntent(const OnInit());
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel;
    if (viewModel == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Booking Detail'),
            leading: IconButton(
              onPressed: () => viewModel.onUserIntent(const OnBackClick()),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: FilledButton.icon(
              onPressed: null,
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Check In'),
            ),
          ),
          body: SafeArea(
            child: BookingDetailView(
              state: viewModel.viewState,
              onRefresh: () async => viewModel.onUserIntent(const OnRefresh()),
            ),
          ),
        );
      },
    );
  }
}
