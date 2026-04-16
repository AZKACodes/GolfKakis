import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/submission/slot/data/booking_submission_slot_repository_impl.dart';
import 'package:golf_kakis/features/booking/submission/slot/domain/booking_submission_slot_use_case_impl.dart';
import 'package:golf_kakis/features/booking/submission/slot/booking_submission_slot_page.dart';
import 'package:golf_kakis/features/booking/submission/confirmation/view/booking_submission_confirmation_view.dart';
import 'package:golf_kakis/features/booking/submission/confirmation/viewmodel/booking_submission_confirmation_view_contract.dart';
import 'package:golf_kakis/features/booking/submission/confirmation/viewmodel/booking_submission_confirmation_view_model.dart';
import 'package:golf_kakis/features/booking/submission/success/booking_submission_success_page.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_submission_player_model.dart';

class BookingSubmissionConfirmationPage extends StatefulWidget {
  const BookingSubmissionConfirmationPage({
    required this.bookingId,
    required this.bookingRef,
    required this.holdDurationSeconds,
    required this.holdExpiresAt,
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
    required this.caddiePreference,
    required this.buggyType,
    required this.buggySharingPreference,
    required this.caddieCount,
    required this.golfCartCount,
    required this.playerDetails,
    super.key,
  });

  final String bookingId;
  final String bookingRef;
  final int holdDurationSeconds;
  final DateTime holdExpiresAt;
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
  final String caddiePreference;
  final String buggyType;
  final String buggySharingPreference;
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
        bookingRef: widget.bookingRef,
        holdDurationSeconds: widget.holdDurationSeconds,
        holdExpiresAt: widget.holdExpiresAt,
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
        caddiePreference: widget.caddiePreference,
        buggyType: widget.buggyType,
        buggySharingPreference: widget.buggySharingPreference,
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
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => BookingSubmissionSuccessPage(
              bookingId: effect.bookingId,
              bookingRef: effect.bookingRef,
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
          (route) => route.isFirst,
        );
      case ShowBookingSessionExpired():
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Booking Session Expired'),
              content: const Text('Your booking session has expired.'),
              actions: [
                FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute<void>(
                        builder: (_) => const BookingSubmissionSlotPage(),
                      ),
                      (route) => route.isFirst,
                    );
                  },
                  child: const Text('Back to Slots'),
                ),
              ],
            );
          },
        );
      case NavigateToBookingSubmissionStart():
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => const BookingSubmissionSlotPage(),
          ),
          (route) => route.isFirst,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BookingSubmissionConfirmationView(viewModel: _viewModel);
  }
}
