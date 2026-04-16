import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:golf_kakis/features/booking/submission/success/view/booking_submission_success_content.dart';
import 'package:golf_kakis/features/booking/submission/success/view/booking_submission_success_pdf_service.dart';
import 'package:golf_kakis/features/booking/submission/success/viewmodel/booking_submission_success_view_contract.dart';
import 'package:golf_kakis/features/booking/submission/success/viewmodel/booking_submission_success_view_model.dart';
import 'package:printing/printing.dart';

class BookingSubmissionSuccessView extends StatelessWidget {
  const BookingSubmissionSuccessView({required this.viewModel, super.key});

  final BookingSubmissionSuccessViewModel viewModel;

  Future<void> _handleSavePdf(
    BuildContext context,
    BookingSubmissionSuccessDataLoaded state,
  ) async {
    try {
      final pdfBytes = await BookingSubmissionSuccessPdfService.buildReceiptPdf(
        state: state,
      );
      final fileName =
          'booking-receipt-${state.bookingRef.isEmpty ? 'receipt' : state.bookingRef}.pdf';

      try {
        await Printing.layoutPdf(
          name: fileName,
          onLayout: (_) async => pdfBytes,
        );
      } on MissingPluginException {
        if (kIsWeb) {
          rethrow;
        }
        final file = File('${Directory.systemTemp.path}/$fileName');
        await file.writeAsBytes(pdfBytes, flush: true);
        debugPrint('Receipt PDF saved to: ${file.path}');
        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Receipt PDF saved to ${file.path}'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
            ),
          );
      }
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Unable to save receipt as PDF: $error'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

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
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: state.isLoading
                          ? null
                          : () => _handleSavePdf(context, state),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        foregroundColor: const Color(0xFF0D7A3A),
                        side: const BorderSide(color: Color(0xFF0D7A3A)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Save PDF'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
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
                ],
              ),
            ),
          ),
        };
      },
    );
  }
}
