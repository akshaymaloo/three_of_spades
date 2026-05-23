import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyRewardState {
  final String lastClaimDate;
  final int consecutiveDays;
  final bool todayClaimed;
  final int rewardAmount;

  const DailyRewardState({
    required this.lastClaimDate,
    required this.consecutiveDays,
    required this.todayClaimed,
    required this.rewardAmount,
  });

  factory DailyRewardState.initial() {
    return const DailyRewardState(
      lastClaimDate: '',
      consecutiveDays: 0,
      todayClaimed: false,
      rewardAmount: 0,
    );
  }

  DailyRewardState copyWith({
    String? lastClaimDate,
    int? consecutiveDays,
    bool? todayClaimed,
    int? rewardAmount,
  }) {
    return DailyRewardState(
      lastClaimDate: lastClaimDate ?? this.lastClaimDate,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      todayClaimed: todayClaimed ?? this.todayClaimed,
      rewardAmount: rewardAmount ?? this.rewardAmount,
    );
  }
}

class DailyRewardNotifier extends Notifier<DailyRewardState> {
  static const List<int> rewardSchedule = [500, 1000, 2000, 3000, 4000, 5000, 5000];

  Completer<void>? _initCompleter;
  Future<void> get initialized => _initCompleter?.future ?? Future.value();

  @override
  DailyRewardState build() {
    _initCompleter = Completer<void>();
    _loadFromPrefs().then((_) {
      if (_initCompleter != null && !_initCompleter!.isCompleted) {
        _initCompleter!.complete();
      }
    });
    return DailyRewardState.initial();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastClaim = prefs.getString('dr_last_claim') ?? '';
      final consecutive = prefs.getInt('dr_consecutive_days') ?? 0;

      final today = _todayDateString();
      final claimed = lastClaim == today;

      int adjustedConsecutive = consecutive;
      if (lastClaim.isNotEmpty && lastClaim != today) {
        final lastDate = DateTime.tryParse(lastClaim);
        final todayDate = DateTime.tryParse(today);
        if (lastDate != null && todayDate != null) {
          final difference = todayDate.difference(lastDate).inDays;
          if (difference != 1) {
            // Streak broken – reset
            adjustedConsecutive = 0;
          }
        }
      }

      final rewardDay = adjustedConsecutive < rewardSchedule.length
          ? adjustedConsecutive
          : rewardSchedule.length - 1;

      state = DailyRewardState(
        lastClaimDate: lastClaim,
        consecutiveDays: adjustedConsecutive,
        todayClaimed: claimed,
        rewardAmount: rewardSchedule[rewardDay],
      );
    } catch (e, stack) {
      debugPrint('Failed to load daily reward state: $e\n$stack');
    }
  }

  /// Claims today's reward. Returns the reward amount, or 0 if already claimed.
  Future<int> claimReward() async {
    if (state.todayClaimed) return 0;

    final today = _todayDateString();
    int newConsecutive = state.consecutiveDays + 1;
    final rewardIndex = newConsecutive <= rewardSchedule.length
        ? newConsecutive - 1
        : rewardSchedule.length - 1;
    final reward = rewardSchedule[rewardIndex];

    state = state.copyWith(
      lastClaimDate: today,
      consecutiveDays: newConsecutive,
      todayClaimed: true,
      rewardAmount: reward,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('dr_last_claim', today);
      await prefs.setInt('dr_consecutive_days', newConsecutive);
    } catch (e, stack) {
      debugPrint('Failed to persist daily reward: $e\n$stack');
    }

    return reward;
  }

  /// Returns the reward for a given day number (1-indexed).
  int rewardForDay(int day) {
    if (day <= 0) return rewardSchedule[0];
    return rewardSchedule[day - 1 < rewardSchedule.length ? day - 1 : rewardSchedule.length - 1];
  }

  String _todayDateString() {
    return DateTime.now().toIso8601String().substring(0, 10);
  }
}

final dailyRewardProvider =
    NotifierProvider<DailyRewardNotifier, DailyRewardState>(() {
  return DailyRewardNotifier();
});
