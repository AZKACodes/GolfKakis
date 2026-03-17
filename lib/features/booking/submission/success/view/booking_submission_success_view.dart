import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/submission/success/view/booking_submission_success_content.dart';
import 'package:golf_kakis/features/booking/submission/success/viewmodel/booking_submission_success_view_contract.dart';
import 'package:golf_kakis/features/booking/submission/success/viewmodel/booking_submission_success_view_model.dart';

class BookingSubmissionSuccessView extends StatelessWidget {
  const BookingSubmissionSuccessView({required this.viewModel, super.key});

  final BookingSubmissionSuccessViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final state = viewModel.viewState;

        return switch (state) {
          BookingSubmissionSuccessDataLoaded() => Scaffold(
            body: BookingSubmissionSuccessContent(state: state),
            bottomNavigationBar: SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () => viewModel.performAction(const OnDoneClick()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D7A3A),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  elevation: 6,
                  shadowColor: const Color(0x330D7A3A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Done'),
              ),
            ),
          ),
        };
      },
    );
  }
}
