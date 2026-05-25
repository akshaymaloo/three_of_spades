import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:three_of_spades_flutter/widgets/playing_card_widget.dart';
import 'package:three_of_spades_flutter/models/card_model.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  const testCard = CardModel(
    id: 1,
    suit: 'H',
    rank: 14,
    points: 20,
    assetPath: 'assets/cards/h14.svg',
  );

  group('PlayingCardWidget Tests', () {
    testWidgets('renders face up card with correct SvgPicture', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PlayingCardWidget(
                card: testCard,
                showBack: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PlayingCardWidget), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('renders back of the card when showBack is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PlayingCardWidget(
                card: testCard,
                showBack: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PlayingCardWidget), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('triggers onTap callback when tapped and isPlayable is true', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PlayingCardWidget(
                card: testCard,
                isPlayable: true,
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PlayingCardWidget));
      expect(tapped, isTrue);
    });

    testWidgets('does NOT trigger onTap callback when tapped and isPlayable is false', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PlayingCardWidget(
                card: testCard,
                isPlayable: false,
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PlayingCardWidget));
      expect(tapped, isFalse);
    });
    
    testWidgets('renders ColorFiltered when not playable', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PlayingCardWidget(
                card: testCard,
                isPlayable: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ColorFiltered), findsOneWidget);
    });
  });
}
