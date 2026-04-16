import 'package:flutter/material.dart';
import 'dart:async';
import 'package:golf_kakis/features/booking/submission/confirmation/booking_submission_confirmation_page.dart';
import 'package:golf_kakis/features/booking/submission/detail/view/booking_submission_detail_view.dart';
import 'package:golf_kakis/features/booking/submission/detail/viewmodel/booking_submission_detail_view_contract.dart';
import 'package:golf_kakis/features/booking/submission/detail/viewmodel/booking_submission_detail_view_model.dart';
import 'package:golf_kakis/features/booking/submission/slot/booking_submission_slot_page.dart';

class BookingSubmissionDetailPage extends StatefulWidget {
  const BookingSubmissionDetailPage({
    required this.slotId,
    required this.bookingId,
    required this.bookingRef,
    required this.holdDurationSeconds,
    required this.holdExpiresAt,
    required this.playType,
    required this.golfClubName,
    required this.golfClubSlug,
    required this.selectedDate,
    required this.teeTimeSlot,
    required this.pricePerPerson,
    required this.currency,
    this.initialPlayerCount = 4,
    this.initialNormalPlayerCount = 4,
    this.initialSeniorPlayerCount = 0,
    this.caddiePreference = 'none',
    this.buggyType = 'normal',
    this.buggySharingPreference = 'shared',
    this.selectedNine,
    this.initialPlayerName = '',
    this.initialPlayerPhoneNumber = '',
    this.guestId,
    super.key,
  });

  final String slotId;
  final String bookingId;
  final String bookingRef;
  final int holdDurationSeconds;
  final DateTime holdExpiresAt;
  final String playType;
  final String golfClubName;
  final String golfClubSlug;
  final DateTime selectedDate;
  final String teeTimeSlot;
  final double pricePerPerson;
  final String currency;
  final int initialPlayerCount;
  final int initialNormalPlayerCount;
  final int initialSeniorPlayerCount;
  final String caddiePreference;
  final String buggyType;
  final String buggySharingPreference;
  final String? selectedNine;
  final String initialPlayerName;
  final String initialPlayerPhoneNumber;
  final String? guestId;

  @override
  State<BookingSubmissionDetailPage> createState() =>
      _BookingSubmissionDetailPageState();
}

class _BookingSubmissionDetailPageState
    extends State<BookingSubmissionDetailPage> {
  late final BookingSubmissionDetailViewModel _viewModel;
  StreamSubscription<BookingSubmissionDetailNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();

    _viewModel = BookingSubmissionDetailViewModel();

    _navEffectSubscription = _viewModel.navEffects.listen(_handleNavEffect);

    _viewModel.performAction(
      OnInit(
        slotId: widget.slotId,
        bookingId: widget.bookingId,
        bookingRef: widget.bookingRef,
        holdDurationSeconds: widget.holdDurationSeconds,
        holdExpiresAt: widget.holdExpiresAt,
        playType: widget.playType,
        golfClubName: widget.golfClubName,
        golfClubSlug: widget.golfClubSlug,
        selectedDate: widget.selectedDate,
        teeTimeSlot: widget.teeTimeSlot,
        pricePerPerson: widget.pricePerPerson,
        currency: widget.currency,
        initialPlayerCount: widget.initialPlayerCount,
        initialNormalPlayerCount: widget.initialNormalPlayerCount,
        initialSeniorPlayerCount: widget.initialSeniorPlayerCount,
        caddiePreference: widget.caddiePreference,
        buggyType: widget.buggyType,
        buggySharingPreference: widget.buggySharingPreference,
        selectedNine: widget.selectedNine,
        initialPlayerName: widget.initialPlayerName,
        initialPlayerPhoneNumber: widget.initialPlayerPhoneNumber,
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
              bookingId: effect.bookingId,
              bookingRef: effect.bookingRef,
              holdDurationSeconds: effect.holdDurationSeconds,
              holdExpiresAt: effect.holdExpiresAt,
              golfClubName: effect.golfClubName,
              golfClubSlug: effect.golfClubSlug,
              selectedDate: effect.selectedDate,
              teeTimeSlot: effect.teeTimeSlot,
              pricePerPerson: effect.pricePerPerson,
              currency: effect.currency,
              guestId: effect.guestId,
              hostName: effect.hostName,
              hostPhoneNumber: effect.hostPhoneNumber,
              playerCount: effect.playerCount,
              caddiePreference: effect.caddiePreference,
              buggyType: effect.buggyType,
              buggySharingPreference: effect.buggySharingPreference,
              caddieCount: effect.caddieCount,
              golfCartCount: effect.golfCartCount,
              playerDetails: effect.playerDetails,
            ),
          ),
        );
      case ShowBookingSessionExpired():
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Booking Session Expired'),
              content: const Text('Your booking session has been expired.'),
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
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      case ShowErrorMessage():
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(effect.message),
              behavior: SnackBarBehavior.floating,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BookingSubmissionDetailView(viewModel: _viewModel);
  }
}
