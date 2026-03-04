import 'dart:async';

import 'package:flutter/material.dart';
import 'package:xxx_demo_app/features/booking/submission/success/view/booking_submission_success_view.dart';
import 'package:xxx_demo_app/features/booking/submission/success/viewmodel/booking_submission_success_view_contract.dart';
import 'package:xxx_demo_app/features/booking/submission/success/viewmodel/booking_submission_success_view_model.dart';

class BookingSubmissionSuccessPage extends StatefulWidget {
  const BookingSubmissionSuccessPage({
    required this.bookingId,
    required this.bookingDate,
    required this.golfClubSlug,
    required this.teeTimeSlot,
    required this.hostName,
    required this.hostPhoneNumber,
    required this.playerCount,
    required this.caddieCount,
    required this.golfCartCount,
    super.key,
  });

  final String bookingId;
  final String bookingDate;
  final String golfClubSlug;
  final String teeTimeSlot;
  final String hostName;
  final String hostPhoneNumber;
  final int playerCount;
  final int caddieCount;
  final int golfCartCount;

  @override
  State<BookingSubmissionSuccessPage> createState() =>
      _BookingSubmissionSuccessPageState();
}

class _BookingSubmissionSuccessPageState
    extends State<BookingSubmissionSuccessPage> {
  late final BookingSubmissionSuccessViewModel _viewModel;
  StreamSubscription<BookingSubmissionSuccessNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = BookingSubmissionSuccessViewModel();
    _navEffectSubscription = _viewModel.navEffects.listen(_handleNavEffect);
    _viewModel.performAction(
      OnInit(
        bookingId: widget.bookingId,
        bookingDate: widget.bookingDate,
        golfClubSlug: widget.golfClubSlug,
        teeTimeSlot: widget.teeTimeSlot,
        hostName: widget.hostName,
        hostPhoneNumber: widget.hostPhoneNumber,
        playerCount: widget.playerCount,
        caddieCount: widget.caddieCount,
        golfCartCount: widget.golfCartCount,
      ),
    );
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  void _handleNavEffect(BookingSubmissionSuccessNavEffect effect) {
    switch (effect) {
      case NavigateToSubmissionStart():
        Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BookingSubmissionSuccessView(viewModel: _viewModel);
  }
}
