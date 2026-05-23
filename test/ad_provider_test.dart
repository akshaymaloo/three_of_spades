import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:three_of_spades_flutter/providers/ad_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  test('AdState initial values', () {
    const state = AdState();
    expect(state.isInterstitialReady, isFalse);
    expect(state.isRewardedReady, isFalse);
    expect(state.gamesPlayedSinceLastAd, equals(0));
    expect(state.isShowingAd, isFalse);
  });

  test('AdNotifier increments game count and shows interstitial when ready', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(adProvider.notifier);

    // Initial game count is 0
    expect(container.read(adProvider).gamesPlayedSinceLastAd, equals(0));

    // Play 1 game
    notifier.incrementGameCount();
    expect(container.read(adProvider).gamesPlayedSinceLastAd, equals(1));

    // Try showing interstitial (should do nothing since count < 3)
    await notifier.showInterstitialIfReady();
    expect(container.read(adProvider).gamesPlayedSinceLastAd, equals(1));

    // Play 2 more games (total 3)
    notifier.incrementGameCount();
    notifier.incrementGameCount();
    expect(container.read(adProvider).gamesPlayedSinceLastAd, equals(3));

    // Try showing interstitial (should run and reset count to 0)
    await notifier.showInterstitialIfReady();
    expect(container.read(adProvider).gamesPlayedSinceLastAd, equals(0));
  });

  test('AdNotifier shows rewarded ad and yields reward coins', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(adProvider.notifier);

    final reward = await notifier.showRewardedAd();
    expect(reward, equals(500));
  });
}
