import 'package:flutter_test/flutter_test.dart';
import 'package:three_of_spades_flutter/models/card_model.dart';

void main() {
  group('CardModel Tests', () {
    test('generateDeck creates 52 cards with correct properties', () {
      final deck = CardModel.generateDeck();
      expect(deck.length, 52);

      // Check unique IDs
      final ids = deck.map((c) => c.id).toSet();
      expect(ids.length, 52);

      // Check suits and ranks
      final suits = {'S', 'H', 'C', 'D'};
      for (var suit in suits) {
        final cardsInSuit = deck.where((c) => c.suit == suit).toList();
        expect(cardsInSuit.length, 13);
        for (int rank = 2; rank <= 14; rank++) {
          expect(cardsInSuit.any((c) => c.rank == rank), isTrue);
        }
      }

      // Check specific points
      final threeOfSpades = deck.firstWhere((c) => c.suit == 'S' && c.rank == 3);
      expect(threeOfSpades.points, 30);

      final fiveOfHearts = deck.firstWhere((c) => c.suit == 'H' && c.rank == 5);
      expect(fiveOfHearts.points, 5);

      final tenOfClubs = deck.firstWhere((c) => c.suit == 'C' && c.rank == 10);
      expect(tenOfClubs.points, 10);

      final kingOfDiamonds = deck.firstWhere((c) => c.suit == 'D' && c.rank == 13);
      expect(kingOfDiamonds.points, 15);

      final aceOfSpades = deck.firstWhere((c) => c.suit == 'S' && c.rank == 14);
      expect(aceOfSpades.points, 20);
    });

    test('generateDoubleDeck creates 104 cards', () {
      final doubleDeck = CardModel.generateDoubleDeck();
      expect(doubleDeck.length, 104);

      // Check unique IDs
      final ids = doubleDeck.map((c) => c.id).toSet();
      expect(ids.length, 104);

      // Check duplicates
      final threeOfSpades = doubleDeck.where((c) => c.suit == 'S' && c.rank == 3).toList();
      expect(threeOfSpades.length, 2);
      expect(threeOfSpades[0].id, isNot(equals(threeOfSpades[1].id)));
    });

    test('rankLabel and rankName return correct strings', () {
      final card5 = const CardModel(id: 1, suit: 'H', rank: 5, points: 5, assetPath: '');
      expect(card5.rankLabel, '5');
      expect(card5.rankName, '5');

      final cardJ = const CardModel(id: 2, suit: 'C', rank: 11, points: 15, assetPath: '');
      expect(cardJ.rankLabel, 'J');
      expect(cardJ.rankName, 'Jack');

      final cardQ = const CardModel(id: 3, suit: 'D', rank: 12, points: 15, assetPath: '');
      expect(cardQ.rankLabel, 'Q');
      expect(cardQ.rankName, 'Queen');

      final cardK = const CardModel(id: 4, suit: 'S', rank: 13, points: 15, assetPath: '');
      expect(cardK.rankLabel, 'K');
      expect(cardK.rankName, 'King');

      final cardA = const CardModel(id: 5, suit: 'H', rank: 14, points: 20, assetPath: '');
      expect(cardA.rankLabel, 'A');
      expect(cardA.rankName, 'Ace');
    });

    test('name returns correct readable name', () {
      final card = const CardModel(id: 1, suit: 'S', rank: 14, points: 20, assetPath: '');
      expect(card.name, 'Ace of Spades');
    });

    test('equality operator works correctly', () {
      final card1 = const CardModel(id: 1, suit: 'S', rank: 14, points: 20, assetPath: '');
      final card2 = const CardModel(id: 2, suit: 'S', rank: 14, points: 20, assetPath: ''); // Same suit/rank, different ID
      final card3 = const CardModel(id: 3, suit: 'H', rank: 14, points: 20, assetPath: ''); // Different suit

      expect(card1 == card2, isTrue);
      expect(card1 == card3, isFalse);
      expect(card1.hashCode == card2.hashCode, isTrue);
    });
  });
}
