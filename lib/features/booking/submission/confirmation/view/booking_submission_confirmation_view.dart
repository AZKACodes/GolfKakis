import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/submission/confirmation/view/booking_submission_confirmation_content.dart';
import 'package:golf_kakis/features/booking/submission/confirmation/viewmodel/booking_submission_confirmation_view_contract.dart';
import 'package:golf_kakis/features/booking/submission/confirmation/viewmodel/booking_submission_confirmation_view_model.dart';
import 'package:golf_kakis/features/foundation/widgets/app_nav_bar.dart';

class BookingSubmissionConfirmationView extends StatelessWidget {
  const BookingSubmissionConfirmationView({required this.viewModel, super.key});

  final BookingSubmissionConfirmationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final state = viewModel.viewState;

        return switch (state) {
          BookingSubmissionConfirmationDataLoaded() => Scaffold(
            appBar: AppNavBar(
              title: 'Booking Confirmation',
              onBackPressed: () => viewModel.performAction(const OnBackClick()),
            ),
            body: state.isSubmitting
                ? const _BookingConfirmationLoadingView()
                : BookingSubmissionConfirmationContent(state: state),
            bottomNavigationBar: state.isSubmitting
                ? null
                : SafeArea(
                    minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: ElevatedButton(
                      onPressed: state.isHoldExpired
                          ? null
                          : () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) {
                                  return AlertDialog(
                                    title: const Text('Confirm Booking'),
                                    content: const Text(
                                      'Please ensure all booking details are correct before proceeding.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(
                                          dialogContext,
                                        ).pop(false),
                                        child: const Text('Review Again'),
                                      ),
                                      FilledButton(
                                        onPressed: () => Navigator.of(
                                          dialogContext,
                                        ).pop(true),
                                        child: const Text('Proceed'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirmed == true) {
                                viewModel.performAction(const OnConfirmClick());
                              }
                            },
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
                      child: Text(
                        state.isHoldExpired
                            ? 'Booking Session Expired'
                            : 'Confirm Booking • ${state.totalCostLabel}',
                      ),
                    ),
                  ),
          ),
        };
      },
    );
  }
}

class _BookingConfirmationLoadingView extends StatelessWidget {
  const _BookingConfirmationLoadingView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 16),
            Text(
              'Submitting your booking...',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
