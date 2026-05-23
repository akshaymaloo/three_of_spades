import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/sound_manager.dart';
import 'config_provider.dart';
import 'service_providers.dart';

class UserStats {
  final String name;
  final int coins;
  final int gamesPlayed;
  final int gamesWon;
  final int highestBidWon;
  final bool soundEnabled;
  final bool musicEnabled;
  final bool hasSeenTutorial;

  const UserStats({
    required this.name,
    required this.coins,
    required this.gamesPlayed,
    required this.gamesWon,
    required this.highestBidWon,
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.hasSeenTutorial = false,
  });

  UserStats copyWith({
    String? name,
    int? coins,
    int? gamesPlayed,
    int? gamesWon,
    int? highestBidWon,
    bool? soundEnabled,
    bool? musicEnabled,
    bool? hasSeenTutorial,
  }) {
    return UserStats(
      name: name ?? this.name,
      coins: coins ?? this.coins,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      highestBidWon: highestBidWon ?? this.highestBidWon,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      hasSeenTutorial: hasSeenTutorial ?? this.hasSeenTutorial,
    );
  }
}

class StatsNotifier extends AsyncNotifier<UserStats> {
  @override
  Future<UserStats> build() async {
    return _loadStats();
  }

  Future<UserStats> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('guest_name') ?? 'Guest Player';
      final coins = prefs.getInt('guest_coins') ?? 5000;
      final gamesPlayed = prefs.getInt('guest_games_played') ?? 0;
      final gamesWon = prefs.getInt('guest_games_won') ?? 0;
      final highestBidWon = prefs.getInt('guest_highest_bid_won') ?? 0;
      final soundEnabled = prefs.getBool('sound_enabled') ?? true;
      final musicEnabled = prefs.getBool('music_enabled') ?? true;
      final hasSeenTutorial = prefs.getBool('has_seen_tutorial') ?? false;

      // Initialize SoundManager state
      SoundManager().setEnabled(soundEnabled);
      SoundManager().setMusicEnabled(musicEnabled);

      return UserStats(
        name: name,
        coins: coins,
        gamesPlayed: gamesPlayed,
        gamesWon: gamesWon,
        highestBidWon: highestBidWon,
        soundEnabled: soundEnabled,
        musicEnabled: musicEnabled,
        hasSeenTutorial: hasSeenTutorial,
      );
    } catch (e, stack) {
      debugPrint('Failed to load stats: $e\n$stack');
      return const UserStats(
        name: 'Guest Player',
        coins: 5000,
        gamesPlayed: 0,
        gamesWon: 0,
        highestBidWon: 0,
        soundEnabled: true,
        musicEnabled: true,
        hasSeenTutorial: false,
      );
    }
  }

  Future<void> updateName(String name) async {
    final current = state.value ?? const UserStats(
      name: 'Guest Player',
      coins: 5000,
      gamesPlayed: 0,
      gamesWon: 0,
      highestBidWon: 0,
    );
    final updated = current.copyWith(name: name);
    state = AsyncValue.data(updated);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('guest_name', name);

      final config = ref.read(configProvider);
      if (config.onlineMode) {
        final authService = ref.read(authServiceProvider);
        final user = authService.currentUser;
        if (user != null && user.uid != null) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid!).set({
            'name': name,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      }
    } catch (e, stack) {
      debugPrint('Failed to save name: $e\n$stack');
    }
  }

  Future<void> updateCoins(int amount) async {
    final current = state.value ?? const UserStats(
      name: 'Guest Player',
      coins: 5000,
      gamesPlayed: 0,
      gamesWon: 0,
      highestBidWon: 0,
    );
    final newCoins = current.coins + amount;
    final updated = current.copyWith(coins: newCoins);
    state = AsyncValue.data(updated);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('guest_coins', newCoins);

      final config = ref.read(configProvider);
      if (config.onlineMode) {
        final authService = ref.read(authServiceProvider);
        final user = authService.currentUser;
        if (user != null && user.uid != null) {
          await ref.read(leaderboardServiceProvider).submitScore(user.uid!, newCoins);
          await FirebaseFirestore.instance.collection('users').doc(user.uid!).set({
            'name': current.name,
          }, SetOptions(merge: true));
        }
      }
    } catch (e, stack) {
      debugPrint('Failed to save coins: $e\n$stack');
    }
  }

  Future<void> addCoins(int amount) => updateCoins(amount);

  Future<void> recordGame(bool won, int bidValue) async {
    final current = state.value ?? const UserStats(
      name: 'Guest Player',
      coins: 5000,
      gamesPlayed: 0,
      gamesWon: 0,
      highestBidWon: 0,
    );
    final newPlayed = current.gamesPlayed + 1;
    final newWon = current.gamesWon + (won ? 1 : 0);
    int newHighestBidWon = current.highestBidWon;
    if (won && bidValue > newHighestBidWon) {
      newHighestBidWon = bidValue;
    }
    final updated = current.copyWith(
      gamesPlayed: newPlayed,
      gamesWon: newWon,
      highestBidWon: newHighestBidWon,
    );
    state = AsyncValue.data(updated);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('guest_games_played', newPlayed);
      await prefs.setInt('guest_games_won', newWon);
      await prefs.setInt('guest_highest_bid_won', newHighestBidWon);
    } catch (e, stack) {
      debugPrint('Failed to save game record: $e\n$stack');
    }
  }

  Future<void> toggleSound(bool enabled) async {
    final current = state.value ?? const UserStats(
      name: 'Guest Player',
      coins: 5000,
      gamesPlayed: 0,
      gamesWon: 0,
      highestBidWon: 0,
    );
    SoundManager().setEnabled(enabled);
    final updated = current.copyWith(soundEnabled: enabled);
    state = AsyncValue.data(updated);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sound_enabled', enabled);
    } catch (e, stack) {
      debugPrint('Failed to save sound setting: $e\n$stack');
    }
  }

  Future<void> toggleMusic(bool enabled) async {
    final current = state.value ?? const UserStats(
      name: 'Guest Player',
      coins: 5000,
      gamesPlayed: 0,
      gamesWon: 0,
      highestBidWon: 0,
    );
    SoundManager().setMusicEnabled(enabled);
    final updated = current.copyWith(musicEnabled: enabled);
    state = AsyncValue.data(updated);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('music_enabled', enabled);
    } catch (e, stack) {
      debugPrint('Failed to save music setting: $e\n$stack');
    }
  }

  Future<void> completeTutorial() async {
    final current = state.value ?? const UserStats(
      name: 'Guest Player',
      coins: 5000,
      gamesPlayed: 0,
      gamesWon: 0,
      highestBidWon: 0,
    );
    final updated = current.copyWith(hasSeenTutorial: true);
    state = AsyncValue.data(updated);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_tutorial', true);
    } catch (e, stack) {
      debugPrint('Failed to save tutorial status: $e\n$stack');
    }
  }

  Future<void> resetStats() async {
    const reset = UserStats(
      name: 'Guest Player',
      coins: 5000,
      gamesPlayed: 0,
      gamesWon: 0,
      highestBidWon: 0,
      soundEnabled: true,
      musicEnabled: true,
      hasSeenTutorial: false,
    );
    state = const AsyncValue.data(reset);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('guest_name');
      await prefs.setInt('guest_coins', 5000);
      await prefs.setInt('guest_games_played', 0);
      await prefs.setInt('guest_games_won', 0);
      await prefs.setInt('guest_highest_bid_won', 0);
      await prefs.setBool('sound_enabled', true);
      await prefs.setBool('music_enabled', true);
      await prefs.setBool('has_seen_tutorial', false);
    } catch (e, stack) {
      debugPrint('Failed to reset stats: $e\n$stack');
    }
  }
}

final statsProvider = AsyncNotifierProvider<StatsNotifier, UserStats>(() {
  return StatsNotifier();
});
