import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'profile_notification_view_contract.dart';

class ProfileNotificationViewModel
    extends
        MviViewModel<
          ProfileNotificationUserIntent,
          ProfileNotificationViewState,
          ProfileNotificationNavEffect
        >
    implements ProfileNotificationViewContract {
  static const _pushNotificationsKey = 'profile_push_notifications_enabled';
  static const _bookingRemindersKey = 'profile_booking_reminders_enabled';
  static const _promotionsKey = 'profile_promotions_enabled';

  @override
  ProfileNotificationViewState createInitialState() {
    return ProfileNotificationViewState.initial;
  }

  @override
  Future<void> handleIntent(ProfileNotificationUserIntent intent) async {
    switch (intent) {
      case OnProfileNotificationInit():
        await _loadSettings();
      case OnProfileNotificationPushToggled():
        await _updatePushNotifications(intent.value);
      case OnProfileNotificationBookingRemindersToggled():
        await _updateBookingReminders(intent.value);
      case OnProfileNotificationPromotionsToggled():
        await _updatePromotions(intent.value);
      case OnProfileNotificationBackClick():
        sendNavEffect(() => const ProfileNotificationNavigateBack());
    }
  }

  Future<void> _loadSettings() async {
    final preferences = await SharedPreferences.getInstance();
    emitViewState(
      (state) => state.copyWith(
        isLoading: false,
        pushNotificationsEnabled:
            preferences.getBool(_pushNotificationsKey) ??
            ProfileNotificationViewState.initial.pushNotificationsEnabled,
        bookingRemindersEnabled:
            preferences.getBool(_bookingRemindersKey) ??
            ProfileNotificationViewState.initial.bookingRemindersEnabled,
        promotionsEnabled:
            preferences.getBool(_promotionsKey) ??
            ProfileNotificationViewState.initial.promotionsEnabled,
      ),
    );
  }

  Future<void> _updatePushNotifications(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_pushNotificationsKey, value);
    emitViewState((state) => state.copyWith(pushNotificationsEnabled: value));
  }

  Future<void> _updateBookingReminders(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_bookingRemindersKey, value);
    emitViewState((state) => state.copyWith(bookingRemindersEnabled: value));
  }

  Future<void> _updatePromotions(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_promotionsKey, value);
    emitViewState((state) => state.copyWith(promotionsEnabled: value));
  }
}
