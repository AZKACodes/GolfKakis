import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/submission/slot/domain/booking_submission_slot_use_case_impl.dart';
import 'package:golf_kakis/features/booking/submission/slot/booking_submission_slot_page.dart';
import 'package:golf_kakis/features/booking/submission/confirmation/view/booking_submission_confirmation_view.dart';
import 'package:golf_kakis/features/booking/submission/confirmation/viewmodel/booking_submission_confirmation_view_contract.dart';
import 'package:golf_kakis/features/booking/submission/confirmation/viewmodel/booking_submission_confirmation_view_model.dart';
import 'package:golf_kakis/features/booking/submission/success/booking_submission_success_page.dart';
import 'package:golf_kakis/features/foundation/model/booking_submission_player_model.dart';
import 'package:golf_kakis/features/foundation/session/session_scope.dart';

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
    this.selectedNine,
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
  final String? selectedNine;
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
  bool _isExpiredDialogOpen = false;
  String? _syncedAccessToken;

  @override
  void initState() {
    super.initState();
    _viewModel = BookingSubmissionConfirmationViewModel(
      BookingSubmissionSlotUseCaseImpl.create(),
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
        selectedNine: widget.selectedNine,
        caddieCount: widget.caddieCount,
        golfCartCount: widget.golfCartCount,
        playerDetails: widget.playerDetails,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final accessToken = SessionScope.of(context).state.accessToken;
    if (accessToken == null ||
        accessToken.isEmpty ||
        accessToken == _syncedAccessToken) {
      return;
    }
    _syncedAccessToken = accessToken;
    _viewModel.performAction(OnAccessTokenAvailable(accessToken));
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
        if (!mounted) {
          return;
        }
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => BookingSubmissionSuccessPage(
              bookingId: effect.bookingId,
              bookingRef: effect.bookingRef,
              bookingStatus: effect.bookingStatus,
              bookingDate: effect.bookingDate,
              golfClubName: effect.golfClubName,
              golfClubSlug: effect.golfClubSlug,
              teeTimeSlot: effect.teeTimeSlot,
              pricePerPerson: effect.pricePerPerson,
              currency: effect.currency,
              paymentMethod: effect.paymentMethod,
              greenFeeTotal: effect.greenFeeTotal,
              buggyEstimatedTotal: effect.buggyEstimatedTotal,
              caddieTotal: effect.caddieTotal,
              insuranceTotal: effect.insuranceTotal,
              sstTotal: effect.sstTotal,
              discountAmount: effect.discountAmount,
              finalAmount: effect.finalAmount,
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
        _showBookingSessionExpiredDialog();
      case DismissBookingSessionExpired():
        if (_isExpiredDialogOpen) {
          _isExpiredDialogOpen = false;
          Navigator.of(context, rootNavigator: true).maybePop();
        }
      case ShowErrorMessage():
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(effect.message),
              behavior: SnackBarBehavior.floating,
            ),
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

  void _showBookingSessionExpiredDialog() {
    if (_isExpiredDialogOpen) {
      return;
    }
    _isExpiredDialogOpen = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            final state = _viewModel.viewState;
            final isExtending =
                state is BookingSubmissionConfirmationDataLoaded &&
                state.isExtendingHold;

            return AlertDialog(
              title: const Text('Do you need more time?'),
              content: const Text(
                'Your booking session is almost expired. Extend the hold to continue this booking.',
              ),
              actions: [
                TextButton(
                  onPressed: isExtending
                      ? null
                      : () {
                          _isExpiredDialogOpen = false;
                          Navigator.of(dialogContext).pop();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute<void>(
                              builder: (_) => const BookingSubmissionSlotPage(),
                            ),
                            (route) => route.isFirst,
                          );
                        },
                  child: const Text('No'),
                ),
                FilledButton(
                  onPressed: isExtending
                      ? null
                      : () {
                          final accessToken = SessionScope.of(
                            context,
                          ).state.accessToken;
                          if (accessToken == null || accessToken.isEmpty) {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please sign in again to extend this hold.',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            return;
                          }
                          _viewModel.onUserIntent(
                            OnExtendBookingHoldClick(accessToken: accessToken),
                          );
                        },
                  child: isExtending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Yes'),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      _isExpiredDialogOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BookingSubmissionConfirmationView(viewModel: _viewModel);
  }
}
