import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ad_service.dart';
import 'service_providers.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class AdState {
  final bool isInterstitialReady;
  final bool isRewardedReady;
  final int gamesPlayedSinceLastAd;
  final bool isShowingAd;

  const AdState({
    this.isInterstitialReady = false,
    this.isRewardedReady = false,
    this.gamesPlayedSinceLastAd = 0,
    this.isShowingAd = false,
  });

  AdState copyWith({
    bool? isInterstitialReady,
    bool? isRewardedReady,
    int? gamesPlayedSinceLastAd,
    bool? isShowingAd,
  }) {
    return AdState(
      isInterstitialReady: isInterstitialReady ?? this.isInterstitialReady,
      isRewardedReady: isRewardedReady ?? this.isRewardedReady,
      gamesPlayedSinceLastAd:
          gamesPlayedSinceLastAd ?? this.gamesPlayedSinceLastAd,
      isShowingAd: isShowingAd ?? this.isShowingAd,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class AdNotifier extends Notifier<AdState> {
  @override
  AdState build() {
    return const AdState();
  }

  BaseAdService _getService() => ref.read(adServiceProvider);

  void incrementGameCount() {
    state = state.copyWith(
      gamesPlayedSinceLastAd: state.gamesPlayedSinceLastAd + 1,
    );
  }

  /// Shows an interstitial ad if the player has played ≥ 3 games since the
  /// last ad. Resets the counter after showing.
  Future<void> showInterstitialIfReady() async {
    if (state.gamesPlayedSinceLastAd < 3) return;

    final service = _getService();
    try {
      state = state.copyWith(isShowingAd: true);
      await service.loadInterstitialAd();
      await service.showInterstitialAd();
      state = state.copyWith(
        gamesPlayedSinceLastAd: 0,
        isShowingAd: false,
      );
    } catch (e, stack) {
      debugPrint('Failed to show interstitial: $e\n$stack');
      state = state.copyWith(isShowingAd: false);
    }
  }

  /// Shows a rewarded ad and returns the coin reward amount (0 on failure).
  Future<int> showRewardedAd() async {
    final service = _getService();
    try {
      state = state.copyWith(isShowingAd: true);
      await service.loadRewardedAd();
      final reward = await service.showRewardedAd();
      state = state.copyWith(isShowingAd: false);
      return reward;
    } catch (e, stack) {
      debugPrint('Failed to show rewarded ad: $e\n$stack');
      state = state.copyWith(isShowingAd: false);
      return 0;
    }
  }
}

final adProvider = NotifierProvider<AdNotifier, AdState>(() {
  return AdNotifier();
});
