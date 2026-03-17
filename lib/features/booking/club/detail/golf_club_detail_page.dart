import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/club/detail/data/golf_club_detail_repository_impl.dart';
import 'package:golf_kakis/features/booking/club/detail/view/golf_club_detail_view.dart';
import 'package:golf_kakis/features/booking/club/detail/viewmodel/golf_club_detail_view_contract.dart';
import 'package:golf_kakis/features/booking/club/detail/viewmodel/golf_club_detail_view_model.dart';
import 'package:golf_kakis/features/booking/submission/slot/booking_submission_slot_page.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';

class GolfClubDetailPage extends StatefulWidget {
  const GolfClubDetailPage({required this.club, super.key});

  final GolfClubModel club;

  @override
  State<GolfClubDetailPage> createState() => _GolfClubDetailPageState();
}

class _GolfClubDetailPageState extends State<GolfClubDetailPage> {
  late final GolfClubDetailViewModel _viewModel;
  StreamSubscription<GolfClubDetailNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = GolfClubDetailViewModel(
      club: widget.club,
      repository: GolfClubDetailRepositoryImpl(),
    );
    _navEffectSubscription = _viewModel.navEffects.listen((effect) {
      if (effect is NavigateBack) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).pop();
      }

      if (effect is NavigateToBookingSubmission) {
        if (!mounted) {
          return;
        }
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                BookingSubmissionSlotPage(initialClubSlug: widget.club.slug),
          ),
        );
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
            title: const Text('Golf Club Details'),
            leading: IconButton(
              onPressed: () => _viewModel.onUserIntent(const OnBackClick()),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: SafeArea(
            child: GolfClubDetailView(
              state: _viewModel.viewState,
              onRefresh: () async => _viewModel.onUserIntent(const OnRefresh()),
              onBookNowClick: () =>
                  _viewModel.onUserIntent(const OnBookNowClick()),
            ),
          ),
        );
      },
    );
  }
}
