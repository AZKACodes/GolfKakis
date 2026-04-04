import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/submission/detail/view/booking_submission_detail_content.dart';
import 'package:golf_kakis/features/booking/submission/detail/viewmodel/booking_submission_detail_view_contract.dart';
import 'package:golf_kakis/features/booking/submission/detail/viewmodel/booking_submission_detail_view_model.dart';
import 'package:golf_kakis/features/foundation/widgets/app_nav_bar.dart';

class BookingSubmissionDetailView extends StatelessWidget {
  const BookingSubmissionDetailView({required this.viewModel, super.key});

  final BookingSubmissionDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final state = viewModel.viewState;

        return switch (state) {
          BookingSubmissionDetailDataLoaded() => Scaffold(
            appBar: AppNavBar(
              title: 'Booking Details',
              onBackPressed: () => viewModel.performAction(const OnBackClick()),
            ),
            body: BookingSubmissionDetailContent(
              viewModel: viewModel,
              state: state,
            ),
            bottomNavigationBar: SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: ElevatedButton(
                onPressed: state.canContinue && !state.isSubmitting
                    ? () => viewModel.performAction(const OnContinueClick())
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
                child: state.isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : Text('Continue • ${state.totalCostLabel}'),
              ),
            ),
          ),
        };
      },
    );
  }
}
