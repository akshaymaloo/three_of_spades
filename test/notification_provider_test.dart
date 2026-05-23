import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_of_spades_flutter/providers/notification_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('NotificationState initial values', () {
    const state = NotificationState();
    expect(state.hasPermission, isFalse);
    expect(state.fcmToken, isNull);
    expect(state.notificationsEnabled, isTrue);
  });

  test('NotificationNotifier initialization and settings toggle', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(notificationProvider.notifier);

    // Initial check
    expect(container.read(notificationProvider).notificationsEnabled, isTrue);

    // Initialize mock service
    await notifier.initialize();
    expect(container.read(notificationProvider).hasPermission, isTrue);
    expect(container.read(notificationProvider).fcmToken, equals('mock-fcm-token-001'));

    // Toggle off
    await notifier.toggleNotifications();
    expect(container.read(notificationProvider).notificationsEnabled, isFalse);

    // Toggle on
    await notifier.toggleNotifications();
    expect(container.read(notificationProvider).notificationsEnabled, isTrue);
  });
}
