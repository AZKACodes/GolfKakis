import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/edit/domain/booking_edit_use_case_impl.dart';
import 'package:golf_kakis/features/foundation/model/booking/booking_model.dart';

import 'view/booking_edit_view.dart';
import 'viewmodel/booking_edit_view_contract.dart';
import 'viewmodel/booking_edit_view_model.dart';

class BookingEditPage extends StatefulWidget {
  const BookingEditPage({required this.booking, super.key});

  final BookingModel booking;

  @override
  State<BookingEditPage> createState() => _BookingEditPageState();
}

class _BookingEditPageState extends State<BookingEditPage> {
  late final BookingEditViewModel _viewModel;
  StreamSubscription<BookingEditNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = BookingEditViewModel(
      useCase: const BookingEditUseCaseImpl(),
      initialState: BookingEditViewState.initial(widget.booking),
    );
    _navEffectSubscription = _viewModel.navEffects.listen((effect) {
      if (effect is NavigateBack) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).pop(effect.updatedBooking);
      }
    });
    _viewModel.onUserIntent(const OnInit());
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Booking Details'),
            leading: IconButton(
              onPressed: () => _viewModel.onUserIntent(const OnBackClick()),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: SafeArea(
            child: BookingEditView(
              state: _viewModel.viewState,
              onPlayerNameChanged: (index, value) => _viewModel.onUserIntent(
                OnPlayerNameChanged(index: index, value: value),
              ),
              onPlayerPhoneChanged: (index, value) => _viewModel.onUserIntent(
                OnPlayerPhoneChanged(index: index, value: value),
              ),
              onSaveClick: () => _viewModel.onUserIntent(const OnSaveClick()),
            ),
          ),
        );
      },
    );
  }
}
