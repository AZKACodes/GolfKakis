import 'package:flutter/foundation.dart';

import 'activity_booking_list_view_contract.dart';

class ActivityBookingListViewModel extends ChangeNotifier
    implements ActivityBookingListViewContract {
  final ActivityBookingListViewState _viewState =
      ActivityBookingListViewState.initial;

  @override
  ActivityBookingListViewState get viewState => _viewState;

  @override
  void onUserIntent(ActivityBookingListUserIntent intent) {}
}
