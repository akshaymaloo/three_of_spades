import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/sound_manager.dart';
import 'config_provider.dart';
import 'service_providers.dart';

/// Represents a single completed match in the game history log.
class GameRecord {
  final String dateTime;
  final bool won;
  final int coinsChange;
  final int tricksTaken;
  final int bid;
  final List<String> opponentNames;

  const GameRecord({
    required this.dateTime,
    required this.won,
    required this.coinsChange,
    required this.tricksTaken,
    required this.bid,
    required this.opponentNames,
  });

  Map<String, dynamic> toJson() => {
        'dateTime': dateTime,
        'won': won,
        'coinsChange': coinsChange,
        'tricksTaken': tricksTaken,
        'bid': bid,
        'opponentNames': opponentNames,
      };

  factory GameRecord.fromJson(Map<String, dynamic> json) => GameRecord(
        dateTime: json['dateTime'] as String? ?? '',
        won: json['won'] as bool? ?? false,
        coinsChange: json['coinsChange'] as int? ?? 0,
        tricksTaken: json['tricksTaken'] as int? ?? 0,
        bid: json['bid'] as int? ?? 0,
        opponentNames: List<String>.from(json['opponentNames'] as List? ?? []),
      );
}

/// AI bot difficulty level.
enum AiDifficulty { easy, medium, hard }

class UserStats {
  final String name;
  final int coins;
  final int gamesPlayed;
  final int gamesWon;
  final int highestBidWon;
  final bool soundEnabled;
  final bool musicEnabled;
  final bool hasSeenTutorial;
  final String languageCode;
  final bool vibrationEnabled;
  final bool ttsEnabled;
  final String tableTheme;
  final String cardBack;
  final AiDifficulty aiDifficulty;

  const UserStats({
    required this.name,
    required this.coins,
    required this.gamesPlayed,
    required this.gamesWon,
    required this.highestBidWon,
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.hasSeenTutorial = false,
    this.languageCode = 'en',
    this.vibrationEnabled = true,
    this.ttsEnabled = false,
    this.tableTheme = 'green',
    this.cardBack = 'classic_blue',
    this.aiDifficulty = AiDifficulty.medium,
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
    String? languageCode,
    bool? vibrationEnabled,
    bool? ttsEnabled,
    String? tableTheme,
    String? cardBack,
    AiDifficulty? aiDifficulty,
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
      languageCode: languageCode ?? this.languageCode,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      ttsEnabled: ttsEnabled ?? this.ttsEnabled,
      tableTheme: tableTheme ?? this.tableTheme,
      cardBack: cardBack ?? this.cardBack,
      aiDifficulty: aiDifficulty ?? this.aiDifficulty,
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
      final languageCode = prefs.getString('language_code') ?? 'en';
      final vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      final ttsEnabled = prefs.getBool('tts_enabled') ?? false;
      final tableTheme = prefs.getString('table_theme') ?? 'green';
      final cardBack = prefs.getString('card_back') ?? 'classic_blue';
      final aiDifficultyStr = prefs.getString('ai_difficulty') ?? 'medium';
      final aiDifficulty = AiDifficulty.values.firstWhere(
        (d) => d.name == aiDifficultyStr,
        orElse: () => AiDifficulty.medium,
      );

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
        languageCode: languageCode,
        vibrationEnabled: vibrationEnabled,
        ttsEnabled: ttsEnabled,
        tableTheme: tableTheme,
        cardBack: cardBack,
        aiDifficulty: aiDifficulty,
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
        vibrationEnabled: true,
        ttsEnabled: false,
        tableTheme: 'green',
        cardBack: 'classic_blue',
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

  Future<void> updateLanguage(String code) async {
    final current = state.value ?? const UserStats(
      name: 'Guest Player',
      coins: 5000,
      gamesPlayed: 0,
      gamesWon: 0,
      highestBidWon: 0,
    );
    final updated = current.copyWith(languageCode: code);
    state = AsyncValue.data(updated);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', code);
    } catch (e, stack) {
      debugPrint('Failed to save language setting: $e\n$stack');
    }
  }

  Future<void> toggleVibration(bool enabled) async {
    final current = state.value ?? const UserStats(
      name: 'Guest Player',
      coins: 5000,
      gamesPlayed: 0,
      gamesWon: 0,
      highestBidWon: 0,
    );
    final updated = current.copyWith(vibrationEnabled: enabled);
    state = AsyncValue.data(updated);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('vibration_enabled', enabled);
    } catch (e, stack) {
      debugPrint('Failed to save vibration setting: $e\n$stack');
    }
  }

  Future<void> toggleTts(bool enabled) async {
    final current = state.value ?? const UserStats(
      name: 'Guest Player',
      coins: 5000,
      gamesPlayed: 0,
      gamesWon: 0,
      highestBidWon: 0,
    );
    final updated = current.copyWith(ttsEnabled: enabled);
    state = AsyncValue.data(updated);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('tts_enabled', enabled);
    } catch (e, stack) {
      debugPrint('Failed to save TTS setting: $e\n$stack');
    }
  }

  Future<void> setTableTheme(String theme) async {
    final current = state.value ?? const UserStats(
      name: 'Guest Player',
      coins: 5000,
      gamesPlayed: 0,
      gamesWon: 0,
      highestBidWon: 0,
    );
    final updated = current.copyWith(tableTheme: theme);
    state = AsyncValue.data(updated);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('table_theme', theme);
    } catch (e, stack) {
      debugPrint('Failed to save table theme: $e\n$stack');
    }
  }

  Future<void> setCardBack(String design) async {
    final current = state.value ?? const UserStats(
      name: 'Guest Player',
      coins: 5000,
      gamesPlayed: 0,
      gamesWon: 0,
      highestBidWon: 0,
    );
    final updated = current.copyWith(cardBack: design);
    state = AsyncValue.data(updated);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('card_back', design);
    } catch (e, stack) {
      debugPrint('Failed to save card back: $e\n$stack');
    }
  }

  Future<void> setAiDifficulty(AiDifficulty difficulty) async {
    final current = state.value ?? const UserStats(
      name: 'Guest Player',
      coins: 5000,
      gamesPlayed: 0,
      gamesWon: 0,
      highestBidWon: 0,
    );
    final updated = current.copyWith(aiDifficulty: difficulty);
    state = AsyncValue.data(updated);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ai_difficulty', difficulty.name);
    } catch (e, stack) {
      debugPrint('Failed to save AI difficulty: $e\n$stack');
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
      vibrationEnabled: true,
      ttsEnabled: false,
      tableTheme: 'green',
      cardBack: 'classic_blue',
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
      await prefs.setBool('vibration_enabled', true);
      await prefs.setBool('tts_enabled', false);
      await prefs.setString('table_theme', 'green');
      await prefs.setString('card_back', 'classic_blue');
      await prefs.remove('game_history');
    } catch (e, stack) {
      debugPrint('Failed to reset stats: $e\n$stack');
    }
  }
}

final statsProvider = AsyncNotifierProvider<StatsNotifier, UserStats>(() {
  return StatsNotifier();
});

// ---------------------------------------------------------------------------
// Separate provider for game history (list of last 50 GameRecords)
// ---------------------------------------------------------------------------

class GameHistoryNotifier extends AsyncNotifier<List<GameRecord>> {
  static const _historyKey = 'game_history';
  static const _maxRecords = 50;

  @override
  Future<List<GameRecord>> build() async {
    return _loadHistory();
  }

  Future<List<GameRecord>> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_historyKey);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => GameRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      debugPrint('Failed to load game history: $e\n$stack');
      return [];
    }
  }

  Future<void> addRecord(GameRecord record) async {
    final current = state.value ?? [];
    final updated = [record, ...current].take(_maxRecords).toList();
    state = AsyncValue.data(updated);
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(updated.map((r) => r.toJson()).toList());
      await prefs.setString(_historyKey, encoded);
    } catch (e, stack) {
      debugPrint('Failed to save game history: $e\n$stack');
    }
  }
}

final gameHistoryProvider =
    AsyncNotifierProvider<GameHistoryNotifier, List<GameRecord>>(
  () => GameHistoryNotifier(),
);

