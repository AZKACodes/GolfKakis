import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/submission/slot/booking_submission_slot_page.dart';
import 'package:golf_kakis/features/booking/submission/slot/domain/booking_submission_slot_use_case_impl.dart';

import 'view/booking_submission_start_view.dart';
import 'viewmodel/booking_submission_start_view_contract.dart';
import 'viewmodel/booking_submission_start_view_model.dart';

class BookingSubmissionStartPage extends StatefulWidget {
  const BookingSubmissionStartPage({super.key});

  @override
  State<BookingSubmissionStartPage> createState() =>
      _BookingSubmissionStartPageState();
}

class _BookingSubmissionStartPageState
    extends State<BookingSubmissionStartPage> {
  late final BookingSubmissionStartViewModel _viewModel;
  StreamSubscription<BookingSubmissionStartNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = BookingSubmissionStartViewModel(
      useCase: BookingSubmissionSlotUseCaseImpl.create(),
    );
    _navEffectSubscription = _viewModel.navEffects.listen(_handleNavEffect);
    _viewModel.onUserIntent(const OnInitBookingSubmissionStart());
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  void _handleNavEffect(BookingSubmissionStartNavEffect effect) {
    if (!mounted) {
      return;
    }

    switch (effect) {
      case NavigateBack():
        Navigator.of(context).maybePop();
      case NavigateToBookingSubmissionSlotSelection():
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BookingSubmissionSlotPage(
              initialClubSlug: effect.club.slug,
              initialClub: effect.club,
              initialPlayerCount: effect.playerCount,
            ),
          ),
        );
      case ShowBookingSubmissionStartError():
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(effect.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BookingSubmissionStartView(viewModel: _viewModel);
  }
}
