import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/submission/slot/view/booking_submission_slot_content.dart';
import 'package:golf_kakis/features/booking/submission/slot/viewmodel/booking_submission_slot_view_contract.dart';
import 'package:golf_kakis/features/booking/submission/slot/viewmodel/booking_submission_slot_view_model.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_slot_model.dart';
import 'package:golf_kakis/features/foundation/widgets/app_nav_bar.dart';

class BookingSubmissionSlotView extends StatelessWidget {
  const BookingSubmissionSlotView({
    required this.viewModel,
    required this.isSubmittingHold,
    required this.onConfirmSlotPressed,
    super.key,
  });

  final BookingSubmissionSlotViewModel viewModel;
  final bool isSubmittingHold;
  final Future<void> Function(BookingSlotModel slot) onConfirmSlotPressed;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final state = viewModel.viewState;

        return switch (state) {
          BookingSubmissionSlotDataLoaded() => Scaffold(
            appBar: AppNavBar(
              title: 'Booking Slot',
              onBackPressed: () => viewModel.performAction(const OnBackClick()),
            ),
            body: BookingSubmissionSlotContent(
              viewModel: viewModel,
              state: state,
              isSubmittingHold: isSubmittingHold,
              onConfirmSlotPressed: onConfirmSlotPressed,
            ),
          ),
        };
      },
    );
  }
}
