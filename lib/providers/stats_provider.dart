import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserStats {
  final String name;
  final int coins;
  final int gamesPlayed;
  final int gamesWon;
  final int highestBidWon;

  const UserStats({
    required this.name,
    required this.coins,
    required this.gamesPlayed,
    required this.gamesWon,
    required this.highestBidWon,
  });

  UserStats copyWith({
    String? name,
    int? coins,
    int? gamesPlayed,
    int? gamesWon,
    int? highestBidWon,
  }) {
    return UserStats(
      name: name ?? this.name,
      coins: coins ?? this.coins,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      highestBidWon: highestBidWon ?? this.highestBidWon,
    );
  }
}

class StatsNotifier extends StateNotifier<UserStats> {
  StatsNotifier()
      : super(const UserStats(
          name: 'Guest Player',
          coins: 5000,
          gamesPlayed: 0,
          gamesWon: 0,
          highestBidWon: 0,
        )) {
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('guest_name') ?? 'Guest Player';
      final coins = prefs.getInt('guest_coins') ?? 5000;
      final gamesPlayed = prefs.getInt('guest_games_played') ?? 0;
      final gamesWon = prefs.getInt('guest_games_won') ?? 0;
      final highestBidWon = prefs.getInt('guest_highest_bid_won') ?? 0;

      state = UserStats(
        name: name,
        coins: coins,
        gamesPlayed: gamesPlayed,
        gamesWon: gamesWon,
        highestBidWon: highestBidWon,
      );
    } catch (e) {
      // Fallback in case of shared_preferences issue (e.g. on web startup delay)
    }
  }

  Future<void> updateCoins(int amount) async {
    final newCoins = state.coins + amount;
    state = state.copyWith(coins: newCoins);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('guest_coins', newCoins);
    } catch (_) {}
  }

  Future<void> recordGame(bool won, int bidValue) async {
    final newPlayed = state.gamesPlayed + 1;
    final newWon = state.gamesWon + (won ? 1 : 0);
    int newHighestBidWon = state.highestBidWon;
    if (won && bidValue > newHighestBidWon) {
      newHighestBidWon = bidValue;
    }
    state = state.copyWith(
      gamesPlayed: newPlayed,
      gamesWon: newWon,
      highestBidWon: newHighestBidWon,
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('guest_games_played', newPlayed);
      await prefs.setInt('guest_games_won', newWon);
      await prefs.setInt('guest_highest_bid_won', newHighestBidWon);
    } catch (_) {}
  }

  Future<void> resetStats() async {
    state = const UserStats(
      name: 'Guest Player',
      coins: 5000,
      gamesPlayed: 0,
      gamesWon: 0,
      highestBidWon: 0,
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('guest_name');
      await prefs.setInt('guest_coins', 5000);
      await prefs.setInt('guest_games_played', 0);
      await prefs.setInt('guest_games_won', 0);
      await prefs.setInt('guest_highest_bid_won', 0);
    } catch (_) {}
  }
}

final statsProvider = StateNotifierProvider<StatsNotifier, UserStats>((ref) {
  return StatsNotifier();
});
