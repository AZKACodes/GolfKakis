import 'dart:async';

import 'package:flutter/material.dart';

import 'view/booking_submission_view.dart';
import 'viewmodel/booking_submission_view_contract.dart';
import 'viewmodel/booking_submission_view_model.dart';

class BookingSubmissionPage extends StatefulWidget {
  const BookingSubmissionPage({super.key});

  @override
  State<BookingSubmissionPage> createState() => _BookingSubmissionPageState();
}

class _BookingSubmissionPageState extends State<BookingSubmissionPage> {
  late final BookingSubmissionViewModel _viewModel;
  StreamSubscription<BookingSubmissionNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = BookingSubmissionViewModel();
    _navEffectSubscription = _viewModel.navEffects.listen((effect) {
      if (effect is BookingSubmissionPopNavEffect) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).maybePop();
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
    return BookingSubmissionView(
      canPop: Navigator.of(context).canPop(),
      onBackToOverview: () =>
          _viewModel.onUserIntent(const BookingSubmissionBackTappedIntent()),
    );
  }
}
