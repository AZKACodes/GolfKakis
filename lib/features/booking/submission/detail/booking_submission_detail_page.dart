import 'package:flutter/material.dart';
import 'dart:async';
import 'package:golf_kakis/features/booking/submission/confirmation/booking_submission_confirmation_page.dart';
import 'package:golf_kakis/features/booking/submission/detail/view/booking_submission_detail_view.dart';
import 'package:golf_kakis/features/booking/submission/detail/viewmodel/booking_submission_detail_view_contract.dart';
import 'package:golf_kakis/features/booking/submission/detail/viewmodel/booking_submission_detail_view_model.dart';
import 'package:golf_kakis/features/booking/submission/slot/booking_submission_slot_page.dart';
import 'package:golf_kakis/features/foundation/model/profile/profile_friend_model.dart';
import 'package:golf_kakis/features/foundation/session/session_scope.dart';
import 'package:golf_kakis/features/profile/friends/domain/profile_friends_use_case_impl.dart';

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
    this.initialCaddieCount = 0,
    this.initialGolfCartCount = 0,
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
  final int initialCaddieCount;
  final int initialGolfCartCount;
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
  late final ProfileFriendsUseCaseImpl _friendsUseCase;
  StreamSubscription<BookingSubmissionDetailNavEffect>? _navEffectSubscription;
  List<ProfileFriendModel> _savedFriends = const <ProfileFriendModel>[];
  bool _isLoadingFriends = false;
  String? _friendsOwnerId;
  bool _didLoadFriends = false;

  @override
  void initState() {
    super.initState();

    _viewModel = BookingSubmissionDetailViewModel();
    _friendsUseCase = ProfileFriendsUseCaseImpl.create();

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
        initialCaddieCount: widget.initialCaddieCount,
        initialGolfCartCount: widget.initialGolfCartCount,
        selectedNine: widget.selectedNine,
        initialPlayerName: widget.initialPlayerName,
        initialPlayerPhoneNumber: widget.initialPlayerPhoneNumber,
        guestId: widget.guestId,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadFriends) {
      return;
    }
    _didLoadFriends = true;
    final session = SessionScope.of(context).state;
    _friendsOwnerId = session.authUserId?.trim().isNotEmpty == true
        ? session.authUserId!.trim()
        : session.deviceId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _loadSavedFriends();
    });
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
              selectedNine: effect.selectedNine,
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
    return BookingSubmissionDetailView(
      viewModel: _viewModel,
      savedFriends: _savedFriends,
      isLoadingFriends: _isLoadingFriends,
      onSaveFriend: _saveFriendFromBooking,
    );
  }

  Future<void> _loadSavedFriends() async {
    final ownerId = _friendsOwnerId;
    if (ownerId == null || ownerId.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingFriends = true;
    });

    try {
      final result = await _friendsUseCase.fetchFriends(ownerId: ownerId);
      if (!mounted) {
        return;
      }
      setState(() {
        _savedFriends = result.friends;
        _isLoadingFriends = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingFriends = false;
      });
    }
  }

  Future<void> _saveFriendFromBooking(ProfileFriendModel friend) async {
    final ownerId = _friendsOwnerId;
    if (ownerId == null || ownerId.isEmpty) {
      return;
    }

    await _friendsUseCase.addFriend(ownerId: ownerId, friend: friend);
    if (!mounted) {
      return;
    }

    setState(() {
      final nextFriends = [..._savedFriends];
      final existingIndex = nextFriends.indexWhere(
        (item) => item.contactKey == friend.contactKey,
      );
      if (existingIndex == -1) {
        nextFriends.add(friend);
      } else {
        nextFriends[existingIndex] = friend;
      }
      nextFriends.sort(
        (left, right) => left.effectiveDisplayName.toLowerCase().compareTo(
          right.effectiveDisplayName.toLowerCase(),
        ),
      );
      _savedFriends = nextFriends;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${friend.displayName} added to My Golf Kakis.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
