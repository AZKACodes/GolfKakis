import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:golf_kakis/features/booking/detail/domain/booking_detail_use_case_impl.dart';
import 'package:golf_kakis/features/booking/edit/booking_edit_page.dart';
import 'package:golf_kakis/features/foundation/model/booking_model.dart';
import 'package:golf_kakis/features/foundation/session/session_scope.dart';
import 'package:golf_kakis/features/foundation/util/debug_log.dart';
import 'package:printing/printing.dart';

import 'view/booking_detail_pdf_service.dart';
import 'view/booking_detail_view.dart';
import 'viewmodel/booking_detail_view_contract.dart';
import 'viewmodel/booking_detail_view_model.dart';

class BookingDetailPage extends StatefulWidget {
  const BookingDetailPage({required this.booking, super.key});

  final BookingModel booking;

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  BookingDetailViewModel? _viewModel;
  StreamSubscription<BookingDetailNavEffect>? _navEffectSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel != null) {
      return;
    }

    final accessToken =
        SessionScope.of(context).state.accessToken?.trim() ?? '';
    _viewModel = BookingDetailViewModel(
      initialBooking: widget.booking,
      useCase: const BookingDetailUseCaseImpl(),
      accessToken: accessToken,
    );
    _navEffectSubscription = _viewModel!.navEffects.listen((effect) async {
      if (effect is NavigateBack) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).pop(effect.updatedBooking);
      }

      if (effect is NavigateToBookingEdit) {
        if (!mounted) {
          return;
        }
        final updatedBooking = await Navigator.of(context).push<BookingModel>(
          MaterialPageRoute<BookingModel>(
            builder: (_) => BookingEditPage(booking: effect.booking),
          ),
        );
        if (updatedBooking != null) {
          _viewModel!.onUserIntent(OnBookingUpdated(updatedBooking));
        }
      }
    });
    _viewModel!.onUserIntent(const OnInit());
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _viewModel?.dispose();
    super.dispose();
  }

  Future<void> _handlePrintBookingReceipt(BookingModel booking) async {
    try {
      final pdfBytes = await BookingDetailPdfService.buildReceiptPdf(
        booking: booking,
      );
      final fileName = 'booking-receipt-${booking.bookingReference}.pdf';

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
        logDebug('Booking detail receipt PDF saved to: ${file.path}');
        if (!mounted) {
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
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Unable to print receipt: $error'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel;
    if (viewModel == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Booking Detail'),
            leading: IconButton(
              onPressed: () => viewModel.onUserIntent(const OnBackClick()),
              icon: const Icon(Icons.arrow_back),
            ),
            actions: [
              IconButton(
                tooltip: 'Print receipt',
                onPressed: viewModel.viewState.isLoading
                    ? null
                    : () => _handlePrintBookingReceipt(
                        viewModel.viewState.booking,
                      ),
                icon: const Icon(Icons.print_outlined),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: FilledButton.icon(
              onPressed: null,
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Check In'),
            ),
          ),
          body: SafeArea(
            child: BookingDetailView(
              state: viewModel.viewState,
              onRefresh: () async => viewModel.onUserIntent(const OnRefresh()),
            ),
          ),
        );
      },
    );
  }
}
