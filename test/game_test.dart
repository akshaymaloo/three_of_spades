import 'package:flutter_test/flutter_test.dart';
import 'package:three_of_spades_flutter/models/card_model.dart';

void main() {
  group('Three of Spades Card Model Tests', () {
    test('Deck Generation yields 52 cards', () {
      final deck = CardModel.generateDeck();
      expect(deck.length, 52);
    });

    test('Three of Spades yields 30 points', () {
      final deck = CardModel.generateDeck();
      final spade3 = deck.firstWhere((c) => c.suit == 'S' && c.rank == 3);
      expect(spade3.points, 30);
    });

    test('Ace yields 20 points', () {
      final deck = CardModel.generateDeck();
      final aceOfHearts = deck.firstWhere((c) => c.suit == 'H' && c.rank == 14);
      expect(aceOfHearts.points, 20);
    });

    test('Tens yield 10 points', () {
      final deck = CardModel.generateDeck();
      final tenOfClubs = deck.firstWhere((c) => c.suit == 'C' && c.rank == 10);
      expect(tenOfClubs.points, 10);
    });

    test('Fives yield 5 points', () {
      final deck = CardModel.generateDeck();
      final fiveOfDiamonds = deck.firstWhere((c) => c.suit == 'D' && c.rank == 5);
      expect(fiveOfDiamonds.points, 5);
    });

    test('Total points in the deck equal 350', () {
      final deck = CardModel.generateDeck();
      int totalPoints = 0;
      for (var card in deck) {
        totalPoints += card.points;
      }
      expect(totalPoints, 350);
    });
  });
}
