import 'dart:async';

import 'package:flutter/material.dart';
import 'package:xxx_demo_app/features/booking/submission/slot/data/booking_submission_slot_repository_impl.dart';
import 'package:xxx_demo_app/features/booking/submission/slot/domain/booking_submission_slot_use_case_impl.dart';
import 'package:xxx_demo_app/features/booking/submission/success/view/booking_submission_success_view.dart';
import 'package:xxx_demo_app/features/booking/submission/success/viewmodel/booking_submission_success_view_contract.dart';
import 'package:xxx_demo_app/features/booking/submission/success/viewmodel/booking_submission_success_view_model.dart';

class BookingSubmissionSuccessPage extends StatefulWidget {
  const BookingSubmissionSuccessPage({
    required this.bookingId,
    required this.bookingSlug,
    required this.bookingDate,
    required this.golfClubName,
    required this.golfClubSlug,
    required this.teeTimeSlot,
    required this.pricePerPerson,
    required this.currency,
    required this.hostName,
    required this.hostPhoneNumber,
    required this.playerCount,
    required this.caddieCount,
    required this.golfCartCount,
    super.key,
  });

  final String bookingId;
  final String bookingSlug;
  final String bookingDate;
  final String golfClubName;
  final String golfClubSlug;
  final String teeTimeSlot;
  final double pricePerPerson;
  final String currency;
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
    _viewModel = BookingSubmissionSuccessViewModel(
      BookingSubmissionSlotUseCaseImpl(BookingSubmissionSlotRepositoryImpl()),
    );
    _navEffectSubscription = _viewModel.navEffects.listen(_handleNavEffect);
    _viewModel.performAction(
      OnInit(
        bookingId: widget.bookingId,
        bookingSlug: widget.bookingSlug,
        bookingDate: widget.bookingDate,
        golfClubName: widget.golfClubName,
        golfClubSlug: widget.golfClubSlug,
        teeTimeSlot: widget.teeTimeSlot,
        pricePerPerson: widget.pricePerPerson,
        currency: widget.currency,
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
