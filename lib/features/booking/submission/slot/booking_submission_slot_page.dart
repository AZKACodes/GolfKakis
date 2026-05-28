import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/submission/detail/booking_submission_detail_page.dart';
import 'package:golf_kakis/features/booking/submission/slot/domain/booking_submission_slot_use_case_impl.dart';
import 'package:golf_kakis/features/booking/submission/slot/view/booking_submission_slot_view.dart';
import 'package:golf_kakis/features/booking/submission/slot/view/widgets/bottomsheet/slot_details_bottom_sheet.dart';
import 'package:golf_kakis/features/booking/submission/slot/viewmodel/booking_submission_slot_view_contract.dart';
import 'package:golf_kakis/features/booking/submission/slot/viewmodel/booking_submission_slot_view_model.dart';
import 'package:golf_kakis/features/foundation/enums/session/session_status.dart';
import 'package:golf_kakis/features/foundation/model/golf_club_model.dart';
import 'package:golf_kakis/features/foundation/session/session_scope.dart';
import 'package:golf_kakis/features/foundation/util/user_util.dart';
import 'package:golf_kakis/features/profile/authentication/register/profile_register_page.dart';

class BookingSubmissionSlotPage extends StatefulWidget {
  const BookingSubmissionSlotPage({
    this.initialClubSlug,
    this.initialClub,
    this.initialPlayerCount,
    super.key,
  });

  final String? initialClubSlug;
  final GolfClubModel? initialClub;
  final int? initialPlayerCount;

  @override
  State<BookingSubmissionSlotPage> createState() =>
      _BookingSubmissionSlotPageState();
}

class _BookingSubmissionSlotPageState extends State<BookingSubmissionSlotPage> {
  late final BookingSubmissionSlotViewModel _viewModel;
  StreamSubscription<BookingSubmissionSlotNavEffect>? _navEffectSubscription;
  bool _isSlotDetailsSheetOpen = false;

  @override
  void initState() {
    super.initState();

    _viewModel = BookingSubmissionSlotViewModel(
      BookingSubmissionSlotUseCaseImpl.create(),
      initialClubSlug: widget.initialClubSlug,
      initialClub: widget.initialClub,
      initialPlayerCount: widget.initialPlayerCount,
    );

    _navEffectSubscription = _viewModel.navEffects.listen(_handleNavEffect);
    _viewModel.performAction(const OnInit());
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleNavEffect(BookingSubmissionSlotNavEffect effect) async {
    switch (effect) {
      case NavigateBack():
        Navigator.of(context).maybePop();
      case RequestBookingHoldPrefill():
        await _handleBookingHoldPrefillRequest(effect);
      case ShowSlotDetailsBottomSheet():
        _isSlotDetailsSheetOpen = true;
        try {
          await SlotDetailsBottomSheet.show(
            context: context,
            viewModel: _viewModel,
            onConfirmSlot: (details) {
              _viewModel.onUserIntent(OnConfirmSlotClick(details));
            },
            onDismissed: () {
              _viewModel.onUserIntent(const OnSlotDetailsDismissed());
            },
          );
        } finally {
          _isSlotDetailsSheetOpen = false;
        }
      case NavigateToBookingSubmissionDetail():
        if (_isSlotDetailsSheetOpen) {
          _isSlotDetailsSheetOpen = false;
          await Navigator.of(context, rootNavigator: true).maybePop();
        }
        if (!mounted) {
          return;
        }
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BookingSubmissionDetailPage(
              slotId: effect.slotId,
              bookingId: effect.bookingId,
              bookingRef: effect.bookingRef,
              holdDurationSeconds: effect.holdDurationSeconds,
              holdExpiresAt: effect.holdExpiresAt,
              playType: effect.playType,
              golfClubName: effect.golfClubName,
              golfClubSlug: effect.golfClubSlug,
              selectedDate: effect.selectedDate,
              teeTimeSlot: effect.teeTimeSlot,
              pricePerPerson: effect.pricePerPerson,
              currency: effect.currency,
              initialPlayerCount: effect.playerCount,
              initialCaddieCount: effect.initialCaddieCount,
              initialGolfCartCount: effect.initialGolfCartCount,
              selectedNine: effect.selectedNine,
              initialPlayerName: effect.initialPlayerName,
              initialPlayerPhoneNumber: effect.initialPlayerPhoneNumber,
              guestId: effect.guestId,
            ),
          ),
        );
      case ShowErrorMessage():
        _showMessage(effect.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BookingSubmissionSlotView(viewModel: _viewModel);
  }

  Future<void> _handleBookingHoldPrefillRequest(
    RequestBookingHoldPrefill effect,
  ) async {
    final prefill = await _resolveBookingPrefill();
    if (!mounted || prefill == null) {
      return;
    }

    final accessToken = SessionScope.of(context).state.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      _showMessage('Please sign in again before creating a booking hold.');
      return;
    }

    _viewModel.onUserIntent(
      OnCreateBookingHoldRequested(
        selectedSlotDetails: effect.selectedSlotDetails,
        accessToken: accessToken,
        hostName: prefill.name,
        hostPhoneNumber: prefill.phoneNumber,
        source: _bookingSource,
        idempotencyKey: prefill.bookingUuid,
      ),
    );
  }

  Future<_BookingContactPrefill?> _resolveBookingPrefill() async {
    final session = SessionScope.of(context).state;
    if (session.status == SessionStatus.loggedIn) {
      return _BookingContactPrefill(
        name: session.effectiveUsername,
        phoneNumber: session.profilePhoneNumber ?? '',
        bookingUuid: UserUtil.onGenerateBookingUUID(),
      );
    }

    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: _profileRegisterRouteName),
        builder: (_) => const ProfileRegisterPage(),
      ),
    );

    if (!mounted) {
      return null;
    }

    final refreshedSession = SessionScope.of(context).state;
    if (refreshedSession.status == SessionStatus.loggedIn) {
      return _BookingContactPrefill(
        name: refreshedSession.effectiveUsername,
        phoneNumber: refreshedSession.profilePhoneNumber ?? '',
        bookingUuid: UserUtil.onGenerateBookingUUID(),
      );
    }

    return null;
  }

  String get _bookingSource {
    if (kIsWeb) {
      return 'web';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return 'web';
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _BookingContactPrefill {
  const _BookingContactPrefill({
    required this.name,
    required this.phoneNumber,
    this.bookingUuid,
  });

  final String name;
  final String phoneNumber;
  final String? bookingUuid;
}

const String _profileRegisterRouteName = 'profile_register';
