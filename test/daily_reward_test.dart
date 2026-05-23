import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_of_spades_flutter/providers/daily_reward_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('DailyRewardState initial values', () {
    final state = DailyRewardState.initial();
    expect(state.lastClaimDate, isEmpty);
    expect(state.consecutiveDays, equals(0));
    expect(state.todayClaimed, isFalse);
    expect(state.rewardAmount, equals(0));
  });

  test('DailyRewardNotifier claims rewards successfully', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(dailyRewardProvider.notifier);
    await notifier.initialized;

    // First claim should give Day 1 reward (500)
    final reward = await notifier.claimReward();
    expect(reward, equals(500));
    expect(container.read(dailyRewardProvider).todayClaimed, isTrue);
    expect(container.read(dailyRewardProvider).consecutiveDays, equals(1));

    // Try claiming again on the same day -> should return 0
    final secondClaim = await notifier.claimReward();
    expect(secondClaim, equals(0));
  });

  test('DailyRewardNotifier reward schedule lookup', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(dailyRewardProvider.notifier);

    expect(notifier.rewardForDay(1), equals(500));
    expect(notifier.rewardForDay(2), equals(1000));
    expect(notifier.rewardForDay(3), equals(2000));
    expect(notifier.rewardForDay(4), equals(3000));
    expect(notifier.rewardForDay(5), equals(4000));
    expect(notifier.rewardForDay(6), equals(5000));
    expect(notifier.rewardForDay(7), equals(5000));
    expect(notifier.rewardForDay(8), equals(5000)); // cap at day 7
  });
}
