import 'package:flutter/material.dart';
import 'package:xxx_demo_app/features/booking/submission/detail/view/booking_submission_detail_view.dart';
import 'package:xxx_demo_app/features/booking/submission/detail/viewmodel/booking_submission_detail_view_model.dart';
import 'package:xxx_demo_app/features/foundation/widgets/app_nav_bar.dart';

class BookingSubmissionDetailPage extends StatefulWidget {
  const BookingSubmissionDetailPage({
    required this.golfClubSlug,
    required this.teeTimeSlot,
    this.guestId,
    super.key,
  });

  final String golfClubSlug;
  final String teeTimeSlot;
  final String? guestId;

  @override
  State<BookingSubmissionDetailPage> createState() =>
      _BookingSubmissionDetailPageState();
}

class _BookingSubmissionDetailPageState
    extends State<BookingSubmissionDetailPage> {
  late final BookingSubmissionDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = BookingSubmissionDetailViewModel(
      golfClubSlug: widget.golfClubSlug,
      teeTimeSlot: widget.teeTimeSlot,
      guestId: widget.guestId,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(
        title: 'Booking Details',
        onBackPressed: () => Navigator.of(context).maybePop(),
      ),
      body: BookingSubmissionDetailView(viewModel: _viewModel),
    );
  }
}
