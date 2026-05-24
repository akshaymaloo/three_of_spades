import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:three_of_spades_flutter/widgets/scoreboard_overlay.dart';
import 'package:three_of_spades_flutter/models/game_state.dart';
import 'package:three_of_spades_flutter/models/player_model.dart';
import 'package:three_of_spades_flutter/providers/game_notifier.dart';
import 'package:three_of_spades_flutter/providers/ad_provider.dart';

void main() {
  final testPlayers = [
    const PlayerModel(id: 0, name: 'You', avatarPath: '', coins: 1000, isHuman: true, isPartner: false, roundPoints: 120),
    const PlayerModel(id: 1, name: 'Bot 1', avatarPath: '', coins: 1000, isHuman: false, isPartner: true, roundPoints: 40),
    const PlayerModel(id: 2, name: 'Bot 2', avatarPath: '', coins: 1000, isHuman: false, isPartner: false, roundPoints: 50),
    const PlayerModel(id: 3, name: 'Bot 3', avatarPath: '', coins: 1000, isHuman: false, isPartner: false, roundPoints: 40),
  ];

  group('ScoreboardOverlay Tests', () {
    testWidgets('renders victory scoreboard correctly for human win', (WidgetTester tester) async {
      final gameState = GameState(
        phase: GamePhase.roundOver,
        players: testPlayers,
        activePlayerIndex: 0,
        dealerIndex: 0,
        roundNumber: 1,
        gameTurn: 1,
        trumpStart: 'S',
        trump: 'S',
        winningBid: 150,
        bidderIndex: 0,
        message: '',
        playerCount: 4,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ScoreboardOverlay(game: gameState),
            ),
          ),
        ),
      );

      expect(find.byType(ScoreboardOverlay), findsOneWidget);
      expect(find.text('VICTORY'), findsOneWidget); // Bid = 150. Bidder (120) + Partner (40) = 160. Bid won.
      expect(find.text('150 pts'), findsOneWidget);
      expect(find.text('160 pts'), findsOneWidget);
    });

    testWidgets('renders defeat scoreboard correctly for human loss', (WidgetTester tester) async {
      final losingPlayers = [
        const PlayerModel(id: 0, name: 'You', avatarPath: '', coins: 1000, isHuman: true, isPartner: false, roundPoints: 50),
        const PlayerModel(id: 1, name: 'Bot 1', avatarPath: '', coins: 1000, isHuman: false, isPartner: true, roundPoints: 40),
        const PlayerModel(id: 2, name: 'Bot 2', avatarPath: '', coins: 1000, isHuman: false, isPartner: false, roundPoints: 120),
        const PlayerModel(id: 3, name: 'Bot 3', avatarPath: '', coins: 1000, isHuman: false, isPartner: false, roundPoints: 40),
      ];

      final gameState = GameState(
        phase: GamePhase.roundOver,
        players: losingPlayers,
        activePlayerIndex: 0,
        dealerIndex: 0,
        roundNumber: 1,
        gameTurn: 1,
        trumpStart: 'S',
        trump: 'S',
        winningBid: 150,
        bidderIndex: 0,
        message: '',
        playerCount: 4,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ScoreboardOverlay(game: gameState),
            ),
          ),
        ),
      );

      expect(find.text('DEFEAT'), findsOneWidget); // Bid = 150. Bidder (50) + Partner (40) = 90. Bid lost.
      expect(find.text('90 pts'), findsOneWidget);
    });
  });
}
