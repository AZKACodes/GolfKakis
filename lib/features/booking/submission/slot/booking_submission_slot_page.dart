import 'package:flutter/material.dart';
import 'dart:async';
import 'package:xxx_demo_app/features/booking/submission/detail/booking_submission_detail_page.dart';
import 'package:xxx_demo_app/features/booking/submission/slot/data/booking_submission_slot_repository_impl.dart';
import 'package:xxx_demo_app/features/booking/submission/slot/domain/booking_submission_slot_use_case_impl.dart';
import 'package:xxx_demo_app/features/booking/submission/slot/view/booking_submission_slot_view.dart';
import 'package:xxx_demo_app/features/booking/submission/slot/viewmodel/booking_submission_slot_view_contract.dart';
import 'package:xxx_demo_app/features/booking/submission/slot/viewmodel/booking_submission_slot_view_model.dart';

class BookingSubmissionSlotPage extends StatefulWidget {
  const BookingSubmissionSlotPage({super.key});

  @override
  State<BookingSubmissionSlotPage> createState() =>
      _BookingSubmissionSlotPageState();
}

class _BookingSubmissionSlotPageState extends State<BookingSubmissionSlotPage> {
  late final BookingSubmissionSlotViewModel _viewModel;
  StreamSubscription<BookingSubmissionSlotNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();

    _viewModel = BookingSubmissionSlotViewModel(
      BookingSubmissionSlotUseCaseImpl(BookingSubmissionSlotRepositoryImpl()),
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

  void _handleNavEffect(BookingSubmissionSlotNavEffect effect) {
    switch (effect) {
      case NavigateBack():
        Navigator.of(context).maybePop();
      case NavigateToBookingSubmissionDetail():
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BookingSubmissionDetailPage(
              golfClubName: effect.golfClubName,
              golfClubSlug: effect.golfClubSlug,
              selectedDate: effect.selectedDate,
              teeTimeSlot: effect.teeTimeSlot,
              pricePerPerson: effect.pricePerPerson,
              currency: effect.currency,
              guestId: effect.guestId,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BookingSubmissionSlotView(viewModel: _viewModel);
  }
}
