import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:three_of_spades_flutter/screens/home_screen.dart';
import 'package:three_of_spades_flutter/screens/avatar_selection_screen.dart';
import 'package:three_of_spades_flutter/widgets/game_table.dart';
import 'package:three_of_spades_flutter/widgets/player_hand_panel.dart';
import 'package:three_of_spades_flutter/models/game_state.dart';
import 'package:three_of_spades_flutter/models/player_model.dart';
import 'package:three_of_spades_flutter/models/card_model.dart';
import 'package:three_of_spades_flutter/providers/stats_provider.dart';
import 'package:three_of_spades_flutter/l10n/app_localizations.dart';

class _MockStatsNotifier extends StatsNotifier {
  final UserStats _initialStats;
  _MockStatsNotifier([UserStats? stats])
      : _initialStats = stats ?? UserStats(
          name: 'Test Player',
          coins: 5000,
          gamesPlayed: 10,
          gamesWon: 5,
          highestBidWon: 350,
          tableTheme: 'green',
        );
  
  @override
  Future<UserStats> build() async {
    return _initialStats;
  }
}

void main() {
  final dummyStats = UserStats(
    name: 'Test Player',
    coins: 5000,
    gamesPlayed: 10,
    gamesWon: 5,
    highestBidWon: 350,
    tableTheme: 'green',
  );

  final testPlayers4 = [
    const PlayerModel(id: 0, name: 'You', avatarPath: '', coins: 5000, isHuman: true),
    const PlayerModel(id: 1, name: 'Bot 1', avatarPath: '', coins: 5000, isHuman: false),
    const PlayerModel(id: 2, name: 'Bot 2', avatarPath: '', coins: 5000, isHuman: false),
    const PlayerModel(id: 3, name: 'Bot 3', avatarPath: '', coins: 5000, isHuman: false),
  ];

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'dr_last_claim': DateTime.now().toIso8601String().substring(0, 10),
      'dr_consecutive_days': 1,
    });
  });

  group('Layout Responsiveness Tests', () {
    testWidgets('HomeScreen renders in landscape phone mode without overflow', (WidgetTester tester) async {
      // Set landscape phone screen dimensions
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            statsProvider.overrideWith(() => _MockStatsNotifier(dummyStats)),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: HomeScreen(),
          ),
        ),
      );

      // Verify the widget tree resolves cleanly
      await tester.pumpAndSettle();

      // Dismiss daily reward if it is shown
      if (find.byIcon(Icons.close).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();
      }

      // Check statistics panel is rendered
      expect(find.text('STATISTICS'), findsWidgets);
      
      // Check play cards or modes
      expect(find.text('Play vs Intelligent Bots'), findsWidgets);

      // Assert that none of the stats or buttons overflow the height of 360
      final playBotsFinder = find.text('Play vs Intelligent Bots');
      expect(playBotsFinder, findsOneWidget);
    });

    testWidgets('AvatarSelectionScreen renders split-layout in landscape without overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            statsProvider.overrideWith(() => _MockStatsNotifier(dummyStats)),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AvatarSelectionScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // In landscape, we should see both columns: Preview + Default Personas
      expect(find.text('Default Personas'), findsOneWidget);
      expect(find.text('Upload Custom Picture'), findsOneWidget);

      // Verify the active persona and default grid exist
      expect(find.text('ACTIVE PERSONA'), findsOneWidget);
      
      // Verify no exceptions or bottom overflows occurred
      expect(tester.takeException(), isNull);
    });

    testWidgets('GameTable and PlayerHandPanel scale down on short height screens', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final humanPlayer = testPlayers4[0].copyWith(
        hand: [
          const CardModel(id: 1, suit: 'S', rank: 14, points: 50, assetPath: 'assets/cards/ace_of_spades.svg'),
          const CardModel(id: 2, suit: 'H', rank: 10, points: 10, assetPath: 'assets/cards/10_of_hearts.svg'),
          const CardModel(id: 3, suit: 'D', rank: 5, points: 5, assetPath: 'assets/cards/5_of_diamonds.svg'),
        ],
      );

      final gameState = GameState(
        phase: GamePhase.playing,
        players: [humanPlayer, testPlayers4[1], testPlayers4[2], testPlayers4[3]],
        activePlayerIndex: 0,
        dealerIndex: 0,
        roundNumber: 1,
        gameTurn: 1,
        trumpStart: 'S',
        trump: 'S',
        winningBid: 250,
        message: 'Your turn to play',
        playerCount: 4,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            statsProvider.overrideWith(() => _MockStatsNotifier(dummyStats)),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Column(
                children: [
                  Expanded(
                    child: GameTable(game: gameState),
                  ),
                  PlayerHandPanel(
                    game: gameState,
                    humanPlayer: humanPlayer,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Ensure no exceptions or overflows occurred
      expect(tester.takeException(), isNull);

      // Verify human hand is visible and cards are rendered
      expect(find.byType(PlayerHandPanel), findsOneWidget);
      expect(find.byType(GameTable), findsOneWidget);
    });
  });
}
