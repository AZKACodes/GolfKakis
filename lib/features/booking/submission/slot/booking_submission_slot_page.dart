import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/submission/detail/booking_submission_detail_page.dart';
import 'package:golf_kakis/features/booking/submission/slot/data/booking_submission_slot_repository_impl.dart';
import 'package:golf_kakis/features/booking/submission/slot/domain/booking_submission_slot_use_case_impl.dart';
import 'package:golf_kakis/features/booking/submission/slot/view/booking_submission_slot_view.dart';
import 'package:golf_kakis/features/booking/submission/slot/viewmodel/booking_submission_slot_view_contract.dart';
import 'package:golf_kakis/features/booking/submission/slot/viewmodel/booking_submission_slot_view_model.dart';
import 'package:golf_kakis/features/foundation/enums/session/session_status.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_hold_request_model.dart';
import 'package:golf_kakis/features/foundation/model/data_status_model.dart';
import 'package:golf_kakis/features/foundation/session/session_scope.dart';
import 'package:golf_kakis/features/foundation/util/phone_util.dart';
import 'package:golf_kakis/features/foundation/util/user_util.dart';
import 'package:golf_kakis/features/profile/register/method/profile_register_method_page.dart';

class BookingSubmissionSlotPage extends StatefulWidget {
  const BookingSubmissionSlotPage({this.initialClubSlug, super.key});

  final String? initialClubSlug;

  @override
  State<BookingSubmissionSlotPage> createState() =>
      _BookingSubmissionSlotPageState();
}

class _BookingSubmissionSlotPageState extends State<BookingSubmissionSlotPage> {
  late final BookingSubmissionSlotUseCaseImpl _useCase;
  late final BookingSubmissionSlotViewModel _viewModel;
  StreamSubscription<BookingSubmissionSlotNavEffect>? _navEffectSubscription;
  bool _isSubmittingHold = false;

  @override
  void initState() {
    super.initState();

    _useCase = BookingSubmissionSlotUseCaseImpl(
      BookingSubmissionSlotRepositoryImpl(),
    );
    _viewModel = BookingSubmissionSlotViewModel(
      _useCase,
      initialClubSlug: widget.initialClubSlug,
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
      case NavigateToBookingSubmissionDetail():
        break;
      case ShowErrorMessage():
        _showMessage(effect.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BookingSubmissionSlotView(
      viewModel: _viewModel,
      isSubmittingHold: _isSubmittingHold,
      onContinuePressed: _handleContinuePressed,
    );
  }

  Future<void> _handleContinuePressed() async {
    final state = _viewModel.viewState;
    if (state is! BookingSubmissionSlotDataLoaded || !state.canContinue) {
      return;
    }

    final selectedSlot = state.selectedSlot;
    if (selectedSlot == null) {
      return;
    }

    final prefill = await _resolveBookingPrefill();
    if (!mounted || prefill == null) {
      return;
    }

    final accessToken = SessionScope.of(context).state.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      _showMessage('Please sign in again before creating a booking hold.');
      return;
    }

    setState(() {
      _isSubmittingHold = true;
    });

    try {
      final result = await _useCase
          .onCreateBookingHold(
            request: BookingHoldRequestModel(
              slotId: selectedSlot.slotId,
              accessToken: accessToken,
              idempotencyKey: prefill.bookingUuid,
              hostName: prefill.name,
              hostPhoneNumber: _normalizePhoneNumber(prefill.phoneNumber),
              source: _bookingSource,
              playType: state.playTypeValue,
              selectedNine: state.selectedSupportedNine.isEmpty
                  ? null
                  : state.selectedSupportedNine,
              golfClubName: state.selectedClubName,
              golfClubSlug: state.selectedClubSlug,
              bookingDate: state.selectedDate
                  .toIso8601String()
                  .split('T')
                  .first,
              teeTimeSlot: selectedSlot.time,
              playerCount: state.playerCount,
              normalPlayerCount: state.normalPlayerCount,
              seniorPlayerCount: state.seniorPlayerCount,
              caddieArrangement: state.caddiePreference.value,
              buggyType: state.buggyType.value,
              buggySharingPreference:
                  state.buggySharingPreference.value == 'mix'
                  ? 'mixed'
                  : state.buggySharingPreference.value,
              paymentMethod: 'pay_counter',
            ),
          )
          .first;

      if (!mounted) {
        return;
      }

      if (result.status != DataStatus.success ||
          result.data is! Map<String, dynamic>) {
        _showMessage(
          result.apiMessage.isEmpty
              ? 'Failed to hold booking. Please try again.'
              : result.apiMessage,
        );
        return;
      }

      await _navigateToBookingDetails(
        slotState: state,
        prefill: prefill,
        holdResponse: result.data as Map<String, dynamic>,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingHold = false;
        });
      }
    }
  }

  Future<void> _navigateToBookingDetails({
    required BookingSubmissionSlotDataLoaded slotState,
    required _BookingContactPrefill prefill,
    required Map<String, dynamic> holdResponse,
  }) async {
    final bookingSummary =
        holdResponse['bookingSummary'] is Map<String, dynamic>
        ? holdResponse['bookingSummary'] as Map<String, dynamic>
        : <String, dynamic>{};
    final hostUser = holdResponse['hostUser'] is Map<String, dynamic>
        ? holdResponse['hostUser'] as Map<String, dynamic>
        : <String, dynamic>{};
    final pricing = bookingSummary['pricing'] is Map<String, dynamic>
        ? bookingSummary['pricing'] as Map<String, dynamic>
        : <String, dynamic>{};

    final bookingDate =
        DateTime.tryParse(bookingSummary['bookingDate']?.toString() ?? '') ??
        slotState.selectedDate;
    final holdExpiresAt =
        DateTime.tryParse(holdResponse['holdExpiresAt']?.toString() ?? '') ??
        DateTime.now().add(
          Duration(
            seconds: _readInt(holdResponse['holdDurationSeconds']) ?? 300,
          ),
        );

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BookingSubmissionDetailPage(
          slotId: slotState.selectedSlot!.slotId,
          bookingId: holdResponse['bookingId']?.toString() ?? '',
          bookingRef: holdResponse['bookingRef']?.toString() ?? '',
          holdDurationSeconds:
              _readInt(holdResponse['holdDurationSeconds']) ?? 300,
          holdExpiresAt: holdExpiresAt,
          playType:
              bookingSummary['playType']?.toString() ?? slotState.playTypeValue,
          golfClubName:
              bookingSummary['golfClubName']?.toString() ??
              slotState.selectedClubName,
          golfClubSlug:
              bookingSummary['golfClubSlug']?.toString() ??
              slotState.selectedClubSlug,
          selectedDate: bookingDate,
          teeTimeSlot:
              bookingSummary['teeTimeSlot']?.toString() ??
              slotState.selectedSlot!.time,
          pricePerPerson: slotState.selectedSlot!.price,
          currency:
              pricing['currency']?.toString() ??
              slotState.selectedSlot!.currency,
          initialPlayerCount:
              _readInt(bookingSummary['playerCount']) ?? slotState.playerCount,
          initialNormalPlayerCount:
              _readInt(bookingSummary['normalPlayerCount']) ??
              slotState.normalPlayerCount,
          initialSeniorPlayerCount:
              _readInt(bookingSummary['seniorPlayerCount']) ??
              slotState.seniorPlayerCount,
          caddiePreference:
              bookingSummary['caddieArrangement']?.toString() ??
              slotState.caddiePreference.value,
          buggyType:
              bookingSummary['buggyType']?.toString() ??
              slotState.buggyType.value,
          buggySharingPreference:
              bookingSummary['buggySharingPreference']?.toString() == 'mixed'
              ? 'mix'
              : bookingSummary['buggySharingPreference']?.toString() ??
                    slotState.buggySharingPreference.value,
          selectedNine:
              bookingSummary['selectedNine']?.toString() ??
              slotState.selectedSupportedNine,
          initialPlayerName: hostUser['name']?.toString().isNotEmpty == true
              ? hostUser['name']!.toString()
              : prefill.name,
          initialPlayerPhoneNumber:
              hostUser['phoneNumber']?.toString().isNotEmpty == true
              ? _normalizePhoneNumber(hostUser['phoneNumber']!.toString())
              : _normalizePhoneNumber(prefill.phoneNumber),
          guestId: prefill.bookingUuid,
        ),
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
        settings: const RouteSettings(name: _registerMethodRouteName),
        builder: (_) =>
            const ProfileRegisterMethodPage(requiresOccupation: false),
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

  int? _readInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '');
  }

  String _normalizePhoneNumber(String value) {
    final parts = PhoneUtil.splitPhoneNumber(value);
    if (parts.localNumber.isEmpty) {
      return value.replaceAll(' ', '');
    }

    return PhoneUtil.normalizeFullPhoneNumber(
      countryCode: parts.countryCode,
      localNumber: parts.localNumber,
    );
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
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
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

const String _registerMethodRouteName = 'register_method';
