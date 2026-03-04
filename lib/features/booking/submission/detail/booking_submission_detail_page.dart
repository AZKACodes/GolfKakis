import 'package:flutter/material.dart';
import 'dart:async';
import 'package:xxx_demo_app/features/booking/submission/confirmation/booking_submission_confirmation_page.dart';
import 'package:xxx_demo_app/features/booking/submission/detail/view/booking_submission_detail_view.dart';
import 'package:xxx_demo_app/features/booking/submission/detail/viewmodel/booking_submission_detail_view_contract.dart';
import 'package:xxx_demo_app/features/booking/submission/detail/viewmodel/booking_submission_detail_view_model.dart';

class BookingSubmissionDetailPage extends StatefulWidget {
  const BookingSubmissionDetailPage({
    required this.golfClubSlug,
    required this.teeTimeSlot,
    this.guestId,
    super.key,
  });

  final String golfClubSlug;
  final String teeTimeSlot;
  final String? guestId;

  @override
  State<BookingSubmissionDetailPage> createState() => _BookingSubmissionDetailPageState();
}

class _BookingSubmissionDetailPageState extends State<BookingSubmissionDetailPage> {
  late final BookingSubmissionDetailViewModel _viewModel;
  StreamSubscription<BookingSubmissionDetailNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();

    _viewModel = BookingSubmissionDetailViewModel();

    _navEffectSubscription = _viewModel.navEffects.listen(_handleNavEffect);
    
    _viewModel.performAction(
      OnInit(
        golfClubSlug: widget.golfClubSlug,
        teeTimeSlot: widget.teeTimeSlot,
        guestId: widget.guestId,
      ),
    );
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  void _handleNavEffect(BookingSubmissionDetailNavEffect effect) {
    switch (effect) {
      case NavigateBack():
        Navigator.of(context).maybePop();
      case NavigateToBookingSubmissionConfirmation():
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BookingSubmissionConfirmationPage(
              golfClubSlug: effect.golfClubSlug,
              teeTimeSlot: effect.teeTimeSlot,
              guestId: effect.guestId,
              hostName: effect.hostName,
              hostPhoneNumber: effect.hostPhoneNumber,
              playerCount: effect.playerCount,
              caddieCount: effect.caddieCount,
              golfCartCount: effect.golfCartCount,
              playerDetails: effect.playerDetails,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BookingSubmissionDetailView(viewModel: _viewModel);
  }
}
