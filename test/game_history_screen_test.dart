import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_of_spades_flutter/screens/game_history_screen.dart';
import 'package:three_of_spades_flutter/providers/stats_provider.dart';
import 'package:three_of_spades_flutter/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestApp(Widget child) => ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: child,
        ),
      );

  group('GameHistoryScreen Tests', () {
    testWidgets('renders empty state when no records exist', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(buildTestApp(const GameHistoryScreen()));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(GameHistoryScreen), findsOneWidget);
      // Should show empty state text
      expect(find.text('No games yet'), findsOneWidget);
    });

    testWidgets('renders list of records when history exists', (WidgetTester tester) async {
      final records = [
        GameRecord(
          dateTime: DateTime.now().toIso8601String(),
          won: true,
          coinsChange: 200,
          tricksTaken: 180,
          bid: 175,
          opponentNames: ['Bot 1', 'Bot 2', 'Bot 3'],
        ),
        GameRecord(
          dateTime: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
          won: false,
          coinsChange: -100,
          tricksTaken: 80,
          bid: 200,
          opponentNames: ['Alpha', 'Beta', 'Gamma'],
        ),
      ];

      final encoded = '[${records.map((r) => '{"dateTime":"${r.dateTime}","won":${r.won},"coinsChange":${r.coinsChange},"tricksTaken":${r.tricksTaken},"bid":${r.bid},"opponentNames":["Bot 1","Bot 2","Bot 3"]}').join(',')}]';
      SharedPreferences.setMockInitialValues({'game_history': encoded});

      await tester.pumpWidget(buildTestApp(const GameHistoryScreen()));
      await tester.pump();
      await tester.pumpAndSettle();

      // Should show at least one record card
      expect(find.text('Victory'), findsWidgets);
    });

    testWidgets('filter tabs are displayed', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(buildTestApp(const GameHistoryScreen()));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Wins'), findsOneWidget);
      expect(find.text('Losses'), findsOneWidget);
    });

    testWidgets('filter tabs switch correctly', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(buildTestApp(const GameHistoryScreen()));
      await tester.pump();
      await tester.pumpAndSettle();

      // Tap Wins filter
      await tester.tap(find.text('Wins'));
      await tester.pumpAndSettle();

      // Shows filtered empty state
      expect(find.text('No wins found'), findsOneWidget);

      // Tap Losses filter
      await tester.tap(find.text('Losses'));
      await tester.pumpAndSettle();

      expect(find.text('No losses found'), findsOneWidget);
    });

    testWidgets('header shows Match History title', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(buildTestApp(const GameHistoryScreen()));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Match History'), findsOneWidget);
    });
  });

  group('GameRecord Tests', () {
    test('GameRecord serializes to JSON correctly', () {
      const record = GameRecord(
        dateTime: '2026-05-26T10:00:00.000',
        won: true,
        coinsChange: 500,
        tricksTaken: 200,
        bid: 175,
        opponentNames: ['Bot 1', 'Bot 2'],
      );

      final json = record.toJson();
      expect(json['won'], isTrue);
      expect(json['coinsChange'], equals(500));
      expect(json['bid'], equals(175));
      expect(json['opponentNames'], equals(['Bot 1', 'Bot 2']));
    });

    test('GameRecord deserializes from JSON correctly', () {
      final json = {
        'dateTime': '2026-05-26T10:00:00.000',
        'won': false,
        'coinsChange': -200,
        'tricksTaken': 90,
        'bid': 200,
        'opponentNames': ['Alpha', 'Beta'],
      };

      final record = GameRecord.fromJson(json);
      expect(record.won, isFalse);
      expect(record.coinsChange, equals(-200));
      expect(record.opponentNames, contains('Alpha'));
    });

    test('GameRecord handles missing fields gracefully', () {
      final json = <String, dynamic>{};
      final record = GameRecord.fromJson(json);
      expect(record.won, isFalse);
      expect(record.coinsChange, equals(0));
      expect(record.opponentNames, isEmpty);
    });
  });

  group('AiDifficulty Tests', () {
    test('AiDifficulty enum values exist', () {
      expect(AiDifficulty.easy, isNotNull);
      expect(AiDifficulty.medium, isNotNull);
      expect(AiDifficulty.hard, isNotNull);
    });

    test('AiDifficulty persists and restores from name string', () {
      final difficulty = AiDifficulty.hard;
      final persisted = difficulty.name; // 'hard'
      final restored = AiDifficulty.values.firstWhere(
        (d) => d.name == persisted,
        orElse: () => AiDifficulty.medium,
      );
      expect(restored, equals(AiDifficulty.hard));
    });
  });
}
