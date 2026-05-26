import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

abstract class ProfileNotificationViewContract {
  ProfileNotificationViewState get viewState;
  Stream<ProfileNotificationNavEffect> get navEffects;
  void onUserIntent(ProfileNotificationUserIntent intent);
}

class ProfileNotificationViewState extends ViewState {
  const ProfileNotificationViewState({
    required this.isLoading,
    required this.pushNotificationsEnabled,
    required this.bookingRemindersEnabled,
    required this.promotionsEnabled,
  }) : super();

  static const initial = ProfileNotificationViewState(
    isLoading: true,
    pushNotificationsEnabled: true,
    bookingRemindersEnabled: true,
    promotionsEnabled: false,
  );

  final bool isLoading;
  final bool pushNotificationsEnabled;
  final bool bookingRemindersEnabled;
  final bool promotionsEnabled;

  ProfileNotificationViewState copyWith({
    bool? isLoading,
    bool? pushNotificationsEnabled,
    bool? bookingRemindersEnabled,
    bool? promotionsEnabled,
  }) {
    return ProfileNotificationViewState(
      isLoading: isLoading ?? this.isLoading,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      bookingRemindersEnabled:
          bookingRemindersEnabled ?? this.bookingRemindersEnabled,
      promotionsEnabled: promotionsEnabled ?? this.promotionsEnabled,
    );
  }
}

sealed class ProfileNotificationUserIntent extends UserIntent {
  const ProfileNotificationUserIntent() : super();
}

class OnProfileNotificationInit extends ProfileNotificationUserIntent {
  const OnProfileNotificationInit();
}

class OnProfileNotificationPushToggled extends ProfileNotificationUserIntent {
  const OnProfileNotificationPushToggled(this.value);

  final bool value;
}

class OnProfileNotificationBookingRemindersToggled
    extends ProfileNotificationUserIntent {
  const OnProfileNotificationBookingRemindersToggled(this.value);

  final bool value;
}

class OnProfileNotificationPromotionsToggled
    extends ProfileNotificationUserIntent {
  const OnProfileNotificationPromotionsToggled(this.value);

  final bool value;
}

class OnProfileNotificationBackClick extends ProfileNotificationUserIntent {
  const OnProfileNotificationBackClick();
}

sealed class ProfileNotificationNavEffect extends NavEffect {
  const ProfileNotificationNavEffect() : super();
}

class ProfileNotificationNavigateBack extends ProfileNotificationNavEffect {
  const ProfileNotificationNavigateBack();
}
