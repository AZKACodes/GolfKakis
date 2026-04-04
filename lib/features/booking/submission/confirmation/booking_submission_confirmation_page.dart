import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/submission/slot/data/booking_submission_slot_repository_impl.dart';
import 'package:golf_kakis/features/booking/submission/slot/domain/booking_submission_slot_use_case_impl.dart';
import 'package:golf_kakis/features/booking/submission/confirmation/view/booking_submission_confirmation_view.dart';
import 'package:golf_kakis/features/booking/submission/confirmation/viewmodel/booking_submission_confirmation_view_contract.dart';
import 'package:golf_kakis/features/booking/submission/confirmation/viewmodel/booking_submission_confirmation_view_model.dart';
import 'package:golf_kakis/features/booking/submission/success/booking_submission_success_page.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_submission_player_model.dart';

class BookingSubmissionConfirmationPage extends StatefulWidget {
  const BookingSubmissionConfirmationPage({
    required this.bookingId,
    required this.golfClubName,
    required this.golfClubSlug,
    required this.selectedDate,
    required this.teeTimeSlot,
    required this.pricePerPerson,
    required this.currency,
    this.guestId,
    required this.hostName,
    required this.hostPhoneNumber,
    required this.playerCount,
    required this.caddieCount,
    required this.golfCartCount,
    required this.playerDetails,
    super.key,
  });

  final String bookingId;
  final String golfClubName;
  final String golfClubSlug;
  final DateTime selectedDate;
  final String teeTimeSlot;
  final double pricePerPerson;
  final String currency;
  final String? guestId;
  final String hostName;
  final String hostPhoneNumber;
  final int playerCount;
  final int caddieCount;
  final int golfCartCount;
  final List<BookingSubmissionPlayerModel> playerDetails;

  @override
  State<BookingSubmissionConfirmationPage> createState() =>
      _BookingSubmissionConfirmationPageState();
}

class _BookingSubmissionConfirmationPageState
    extends State<BookingSubmissionConfirmationPage> {
  late final BookingSubmissionConfirmationViewModel _viewModel;
  StreamSubscription<BookingSubmissionConfirmationNavEffect>?
  _navEffectSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = BookingSubmissionConfirmationViewModel(
      BookingSubmissionSlotUseCaseImpl(BookingSubmissionSlotRepositoryImpl()),
    );
    _navEffectSubscription = _viewModel.navEffects.listen(_handleNavEffect);
    _viewModel.performAction(
      OnInit(
        golfClubName: widget.golfClubName,
        golfClubSlug: widget.golfClubSlug,
        selectedDate: widget.selectedDate,
        teeTimeSlot: widget.teeTimeSlot,
        pricePerPerson: widget.pricePerPerson,
        currency: widget.currency,
        guestId: widget.guestId,
        hostName: widget.hostName,
        hostPhoneNumber: widget.hostPhoneNumber,
        playerCount: widget.playerCount,
        caddieCount: widget.caddieCount,
        golfCartCount: widget.golfCartCount,
        playerDetails: widget.playerDetails,
      ),
    );
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  void _handleNavEffect(BookingSubmissionConfirmationNavEffect effect) {
    switch (effect) {
      case NavigateBack():
        Navigator.of(context).maybePop();
      case NavigateToBookingSubmissionSuccess():
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BookingSubmissionSuccessPage(
              bookingId: effect.bookingId,
              bookingSlug: effect.bookingSlug,
              bookingDate: effect.bookingDate,
              golfClubName: effect.golfClubName,
              golfClubSlug: effect.golfClubSlug,
              teeTimeSlot: effect.teeTimeSlot,
              pricePerPerson: effect.pricePerPerson,
              currency: effect.currency,
              hostName: effect.hostName,
              hostPhoneNumber: effect.hostPhoneNumber,
              playerCount: effect.playerCount,
              caddieCount: effect.caddieCount,
              golfCartCount: effect.golfCartCount,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BookingSubmissionConfirmationView(viewModel: _viewModel);
  }
}
