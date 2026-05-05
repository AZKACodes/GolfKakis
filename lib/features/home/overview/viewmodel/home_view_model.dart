import 'dart:async';
import 'package:golf_kakis/features/foundation/default_values.dart';
import 'package:golf_kakis/features/foundation/model/home/home_announcement_item.dart';
import 'package:golf_kakis/features/foundation/model/home/home_announcement_view_data.dart';
import 'package:golf_kakis/features/foundation/model/home/home_hot_deal_view_data.dart';
import 'package:golf_kakis/features/foundation/model/home/home_hot_deal_item.dart';
import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import '../domain/home_overview_use_case.dart';
import 'home_view_contract.dart';

class HomeViewModel
    extends MviViewModel<HomeUserIntent, HomeViewState, HomeNavEffect>
    implements HomeViewContract {
  HomeViewModel(this._useCase);
  final HomeOverviewUseCase _useCase;

  HomeDataLoaded get _currentDataState {
    return switch (currentState) {
      HomeDataLoaded() => currentState as HomeDataLoaded,
    };
  }

  @override
  HomeViewState createInitialState() => HomeDataLoaded.initial;

  @override
  FutureOr<void> handleIntent(HomeUserIntent intent) {
    switch (intent) {
      case OnHomeOverviewInit():
        return _loadData(
          isLoggedIn: intent.isLoggedIn,
          accessToken: intent.accessToken,
        );
      case OnRefreshHomeOverview():
        return _loadData(
          isLoggedIn: intent.isLoggedIn,
          accessToken: intent.accessToken,
        );
      case OnNewBookingClick():
        sendNavEffect(() => const NavigateToBookingSlotSubmission());
      case OnGolfClubListClick():
        sendNavEffect(() => const NavigateToGolfClubList());
      case OnBookingListClick():
        sendNavEffect(() => const NavigateToBookingOverview());
    }
  }

  Future<void> _loadData({
    required bool isLoggedIn,
    String? accessToken,
  }) async {
    final currentState = _currentDataState;
    emitViewState(
      (_) => currentState.copyWith(isLoading: true, clearError: true),
    );

    try {
      final result = await _useCase.onHomeOverviewInit(
        isLoggedIn: isLoggedIn,
        accessToken: accessToken,
      );

      emitViewState(
        (_) => currentState.copyWith(
          headerDisplayName: result.userDetails?.displayName ?? emptyString,
          headerAvatarIndex: result.userDetails?.avatarIndex ?? 0,
          headerAvatarUrl: result.userDetails?.avatarUrl,
          isLoading: false,
          announcements: result.announcements.map(_mapAnnouncement).toList(),
          deals: result.deals.map(_mapHotDeal).toList(),
          clearError: true,
        ),
      );
    } catch (_) {
      emitViewState(
        (_) => currentState.copyWith(
          isLoading: false,
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message: 'Failed to load home data',
          ),
          announcements: const <HomeAnnouncementViewData>[],
          deals: const <HomeHotDealViewData>[],
        ),
      );
    }
  }

  HomeAnnouncementViewData _mapAnnouncement(HomeAnnouncementItem item) {
    return HomeAnnouncementViewData(
      announcementId: item.announcementId,
      announcementType: item.announcementType,
      title: item.title,
      subtitle: item.subtitle,
      imageUrl: item.imageUrl,
    );
  }

  HomeHotDealViewData _mapHotDeal(HomeHotDealItem item) {
    return HomeHotDealViewData(
      dealId: item.dealId,
      slotId: item.slotId,
      title: item.title,
      description: item.description,
      price: item.price,
      discountedPrice: item.discountedPrice,
      currency: item.currency,
      golfClubSlug: item.golfClubSlug,
      slotDate: item.slotDate,
      slotTime: item.slotTime,
      noOfHoles: item.noOfHoles,
      imageUrl: item.imageUrl,
    );
  }
}
