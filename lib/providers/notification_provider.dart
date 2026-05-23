import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import 'service_providers.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class NotificationState {
  final bool hasPermission;
  final String? fcmToken;
  final bool notificationsEnabled;

  const NotificationState({
    this.hasPermission = false,
    this.fcmToken,
    this.notificationsEnabled = true,
  });

  NotificationState copyWith({
    bool? hasPermission,
    String? fcmToken,
    bool? notificationsEnabled,
  }) {
    return NotificationState(
      hasPermission: hasPermission ?? this.hasPermission,
      fcmToken: fcmToken ?? this.fcmToken,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class NotificationNotifier extends Notifier<NotificationState> {
  @override
  NotificationState build() {
    _loadFromPrefs();
    return const NotificationState();
  }

  BaseNotificationService _getService() => ref.read(notificationServiceProvider);

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('notifications_enabled') ?? true;
      state = state.copyWith(notificationsEnabled: enabled);
    } catch (e, stack) {
      debugPrint('Failed to load notification prefs: $e\n$stack');
    }
  }

  /// Initializes the notification service and requests permission.
  Future<void> initialize() async {
    final service = _getService();
    try {
      await service.initialize();
      final granted = await service.requestPermission();
      final token = await service.getToken();
      state = state.copyWith(
        hasPermission: granted,
        fcmToken: token,
      );
    } catch (e, stack) {
      debugPrint('Failed to initialize notifications: $e\n$stack');
    }
  }

  /// Toggles notifications on/off and persists the preference.
  Future<void> toggleNotifications() async {
    final newValue = !state.notificationsEnabled;
    state = state.copyWith(notificationsEnabled: newValue);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', newValue);
      
      final service = _getService();
      if (newValue) {
        await service.subscribeToTopic('daily_rewards');
        await service.subscribeToTopic('game_updates');
      } else {
        await service.unsubscribeFromTopic('daily_rewards');
        await service.unsubscribeFromTopic('game_updates');
      }
    } catch (e, stack) {
      debugPrint('Failed to save notification setting: $e\n$stack');
    }
  }
}

final notificationProvider =
    NotifierProvider<NotificationNotifier, NotificationState>(() {
  return NotificationNotifier();
});
