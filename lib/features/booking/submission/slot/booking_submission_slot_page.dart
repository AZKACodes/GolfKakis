import 'package:flutter/material.dart';
import 'package:xxx_demo_app/features/booking/submission/slot/data/booking_submission_slot_repository_impl.dart';
import 'package:xxx_demo_app/features/booking/submission/slot/domain/booking_submission_slot_use_case_impl.dart';
import 'package:xxx_demo_app/features/booking/submission/slot/view/booking_submission_slot_view.dart';
import 'package:xxx_demo_app/features/booking/submission/slot/viewmodel/booking_submission_slot_view_model.dart';
import 'package:xxx_demo_app/features/foundation/widgets/app_nav_bar.dart';

class BookingSubmissionSlotPage extends StatefulWidget {
  const BookingSubmissionSlotPage({super.key});

  @override
  State<BookingSubmissionSlotPage> createState() =>
      _BookingSubmissionSlotPageState();
}

class _BookingSubmissionSlotPageState extends State<BookingSubmissionSlotPage> {
  late final BookingSubmissionSlotViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = BookingSubmissionSlotViewModel(
      BookingSubmissionSlotUseCaseImpl(BookingSubmissionSlotRepositoryImpl()),
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
        title: 'Booking Slot',
        onBackPressed: () => Navigator.of(context).maybePop(),
      ),
      body: BookingSubmissionSlotView(viewModel: _viewModel),
    );
  }
}
