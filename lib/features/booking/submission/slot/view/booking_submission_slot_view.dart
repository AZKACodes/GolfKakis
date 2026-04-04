import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/submission/slot/view/booking_submission_slot_content.dart';
import 'package:golf_kakis/features/booking/submission/slot/viewmodel/booking_submission_slot_view_contract.dart';
import 'package:golf_kakis/features/booking/submission/slot/viewmodel/booking_submission_slot_view_model.dart';
import 'package:golf_kakis/features/foundation/widgets/app_nav_bar.dart';

class BookingSubmissionSlotView extends StatelessWidget {
  const BookingSubmissionSlotView({
    required this.viewModel,
    required this.isSubmittingHold,
    required this.onContinuePressed,
    super.key,
  });

  final BookingSubmissionSlotViewModel viewModel;
  final bool isSubmittingHold;
  final Future<void> Function() onContinuePressed;

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
            ),
            bottomNavigationBar: SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: ElevatedButton(
                onPressed: state.canContinue && !isSubmittingHold
                    ? () => onContinuePressed()
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D7A3A),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  elevation: 6,
                  shadowColor: const Color(0x330D7A3A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: isSubmittingHold
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Continue'),
              ),
            ),
          ),
        };
      },
    );
  }
}
