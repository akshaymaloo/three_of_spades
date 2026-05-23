import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_of_spades_flutter/providers/config_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('ConfigState initial values', () {
    final state = ConfigState.initial();
    expect(state.onlineMode, isFalse);
    expect(state.isFirebaseAvailable, isFalse);
    expect(state.effectiveOnlineMode, isFalse);
  });

  test('ConfigNotifier toggles online mode and persists', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Initial check
    expect(container.read(configProvider).onlineMode, isFalse);

    // Toggle once
    await container.read(configProvider.notifier).toggleOnlineMode();
    expect(container.read(configProvider).onlineMode, isTrue);

    // Toggle twice
    await container.read(configProvider.notifier).toggleOnlineMode();
    expect(container.read(configProvider).onlineMode, isFalse);
  });

  test('ConfigNotifier effectiveOnlineMode checks both flags', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(configProvider.notifier);

    // Both false -> effective false
    expect(container.read(configProvider).effectiveOnlineMode, isFalse);

    // Only firebase available -> effective false
    notifier.setFirebaseAvailable(true);
    expect(container.read(configProvider).effectiveOnlineMode, isFalse);

    // Both true -> effective true
    notifier.toggleOnlineMode();
    expect(container.read(configProvider).effectiveOnlineMode, isTrue);

    // Only online mode true -> effective false
    notifier.setFirebaseAvailable(false);
    expect(container.read(configProvider).effectiveOnlineMode, isFalse);
  });
}
