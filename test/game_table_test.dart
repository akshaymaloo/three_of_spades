import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:three_of_spades_flutter/widgets/game_table.dart';
import 'package:three_of_spades_flutter/models/game_state.dart';
import 'package:three_of_spades_flutter/models/player_model.dart';
import 'package:three_of_spades_flutter/models/card_model.dart';
import 'package:three_of_spades_flutter/providers/stats_provider.dart';

class _MockStatsNotifier extends StatsNotifier {
  final UserStats _initialStats;
  _MockStatsNotifier([UserStats? stats]) : _initialStats = stats ?? UserStats(name: 'Test', coins: 5000, gamesPlayed: 0, gamesWon: 0, highestBidWon: 0, tableTheme: 'green');
  
  @override
  Future<UserStats> build() async {
    return _initialStats;
  }
}

void main() {
  final testPlayers4 = [
    const PlayerModel(id: 0, name: 'You', avatarPath: '', coins: 1000, isHuman: true),
    const PlayerModel(id: 1, name: 'Bot 1', avatarPath: '', coins: 1000, isHuman: false),
    const PlayerModel(id: 2, name: 'Bot 2', avatarPath: '', coins: 1000, isHuman: false),
    const PlayerModel(id: 3, name: 'Bot 3', avatarPath: '', coins: 1000, isHuman: false),
  ];

  final testPlayers7 = [
    const PlayerModel(id: 0, name: 'You', avatarPath: '', coins: 1000, isHuman: true),
    const PlayerModel(id: 1, name: 'Bot 1', avatarPath: '', coins: 1000, isHuman: false),
    const PlayerModel(id: 2, name: 'Bot 2', avatarPath: '', coins: 1000, isHuman: false),
    const PlayerModel(id: 3, name: 'Bot 3', avatarPath: '', coins: 1000, isHuman: false),
    const PlayerModel(id: 4, name: 'Bot 4', avatarPath: '', coins: 1000, isHuman: false),
    const PlayerModel(id: 5, name: 'Bot 5', avatarPath: '', coins: 1000, isHuman: false),
    const PlayerModel(id: 6, name: 'Bot 6', avatarPath: '', coins: 1000, isHuman: false),
  ];

  final dummyStats = UserStats(
    name: 'You',
    coins: 5000,
    gamesPlayed: 0,
    gamesWon: 0,
    highestBidWon: 0,
    tableTheme: 'green',
  );


  group('GameTable Tests', () {
    testWidgets('renders 4 players correctly', (WidgetTester tester) async {
      final gameState = GameState(
        phase: GamePhase.bidding,
        players: testPlayers4,
        activePlayerIndex: 0,
        dealerIndex: 0,
        roundNumber: 1,
        gameTurn: 1,
        trumpStart: 'S',
        trump: 'S',
        winningBid: 0,
        message: '',
        playerCount: 4,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            statsProvider.overrideWith(() => _MockStatsNotifier(dummyStats)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: GameTable(game: gameState),
            ),
          ),
        ),
      );

      expect(find.byType(GameTable), findsOneWidget);
    });

    testWidgets('renders 7 players correctly', (WidgetTester tester) async {
      final gameState = GameState(
        phase: GamePhase.bidding,
        players: testPlayers7,
        activePlayerIndex: 0,
        dealerIndex: 0,
        roundNumber: 1,
        gameTurn: 1,
        trumpStart: 'S',
        trump: 'S',
        winningBid: 0,
        message: '',
        playerCount: 7,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            statsProvider.overrideWith(() => _MockStatsNotifier(dummyStats)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: GameTable(game: gameState),
            ),
          ),
        ),
      );

      expect(find.byType(GameTable), findsOneWidget);
    });

    testWidgets('renders circular turn timer when active', (WidgetTester tester) async {
      final gameState = GameState(
        phase: GamePhase.playing,
        players: testPlayers4,
        activePlayerIndex: 0,
        dealerIndex: 0,
        roundNumber: 1,
        gameTurn: 1,
        trumpStart: 'S',
        trump: 'S',
        winningBid: 200,
        message: '',
        playerCount: 4,
        turnTimer: 5,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            statsProvider.overrideWith(() => _MockStatsNotifier(dummyStats)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: GameTable(game: gameState),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('5s'), findsOneWidget);
    });

    testWidgets('renders current trick points total in center', (WidgetTester tester) async {
      final playersWithPlayedCards = [
        testPlayers4[0].copyWith(playedCard: const CardModel(id: 1, suit: 'C', rank: 11, points: 15, assetPath: '')),
        testPlayers4[1].copyWith(playedCard: const CardModel(id: 2, suit: 'C', rank: 12, points: 15, assetPath: '')),
        testPlayers4[2],
        testPlayers4[3],
      ];

      final gameState = GameState(
        phase: GamePhase.playing,
        players: playersWithPlayedCards,
        activePlayerIndex: 2,
        dealerIndex: 0,
        roundNumber: 1,
        gameTurn: 3,
        trumpStart: 'C',
        trump: 'S',
        winningBid: 200,
        message: '',
        playerCount: 4,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            statsProvider.overrideWith(() => _MockStatsNotifier(dummyStats)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: GameTable(game: gameState),
            ),
          ),
        ),
      );

      expect(find.text('30'), findsOneWidget);
    });
  });
}
