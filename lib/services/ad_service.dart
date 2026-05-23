import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// ---------------------------------------------------------------------------
// BaseAdService – abstract contract for interstitial & rewarded ads.
// ---------------------------------------------------------------------------

abstract class BaseAdService {
  Future<void> initialize();
  Future<void> loadInterstitialAd();
  Future<bool> showInterstitialAd();
  Future<void> loadRewardedAd();

  /// Shows a rewarded ad and returns the reward amount in coins.
  Future<int> showRewardedAd();

  void dispose();
}

// ---------------------------------------------------------------------------
// MockAdService – simulates ad lifecycle without a real ad SDK.
// ---------------------------------------------------------------------------

class MockAdService implements BaseAdService {
  @override
  Future<void> initialize() async {
    // No-op – no ad SDK to initialise in offline mode.
  }

  @override
  Future<void> loadInterstitialAd() async {
    // No-op – interstitial is always "ready" in mock.
  }

  @override
  Future<bool> showInterstitialAd() async {
    // Simulate the delay of a real interstitial ad.
    await Future<void>.delayed(const Duration(seconds: 1));
    return true;
  }

  @override
  Future<void> loadRewardedAd() async {
    // No-op – rewarded ad is always "ready" in mock.
  }

  @override
  Future<int> showRewardedAd() async {
    // Simulate the delay of watching a rewarded video.
    await Future<void>.delayed(const Duration(seconds: 2));
    return 500; // reward coins
  }

  @override
  void dispose() {
    // No-op – nothing to clean up.
  }
}



// ---------------------------------------------------------------------------
// LiveAdService – Google Mobile Ads SDK integration.
// ---------------------------------------------------------------------------

class LiveAdService implements BaseAdService {
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  String get _interstitialAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712' // Android test ad unit ID
          : 'ca-app-pub-3940256099942544/4411468910'; // iOS test ad unit ID
    }
    // Replace with real production unit IDs
    return Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/1033173712'
        : 'ca-app-pub-3940256099942544/4411468910';
  }

  String get _rewardedAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917' // Android test ad unit ID
          : 'ca-app-pub-3940256099942544/1712485313'; // iOS test ad unit ID
    }
    // Replace with real production unit IDs
    return Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/5224354917'
        : 'ca-app-pub-3940256099942544/1712485313';
  }

  @override
  Future<void> initialize() async {
    // Initialized at app startup in main.dart
  }

  @override
  Future<void> loadInterstitialAd() async {
    final completer = Completer<void>();
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          completer.complete();
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          completer.completeError(error);
        },
      ),
    );
    return completer.future;
  }

  @override
  Future<bool> showInterstitialAd() async {
    if (_interstitialAd == null) return false;
    final completer = Completer<bool>();
    
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        completer.complete(false);
      },
    );

    await _interstitialAd!.show();
    return completer.future;
  }

  @override
  Future<void> loadRewardedAd() async {
    final completer = Completer<void>();
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          completer.complete();
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          completer.completeError(error);
        },
      ),
    );
    return completer.future;
  }

  @override
  Future<int> showRewardedAd() async {
    if (_rewardedAd == null) return 0;
    final completer = Completer<int>();
    int rewardAmount = 0;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        completer.complete(rewardAmount);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        completer.complete(0);
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        rewardAmount = reward.amount.toInt();
        if (rewardAmount == 0) {
          rewardAmount = 500; // default backup reward
        }
      },
    );

    return completer.future;
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
