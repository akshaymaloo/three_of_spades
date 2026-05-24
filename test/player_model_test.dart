import 'package:flutter_test/flutter_test.dart';
import 'package:three_of_spades_flutter/models/player_model.dart';
import 'package:three_of_spades_flutter/models/card_model.dart';

void main() {
  group('PlayerModel Tests', () {
    test('copyWith preserves playedCard when not explicitly provided', () {
      const card = CardModel(id: 1, suit: 'H', rank: 14, points: 10, assetPath: '');
      final player = PlayerModel(
        id: 0,
        name: 'You',
        avatarPath: '',
        coins: 1000,
        isHuman: true,
        playedCard: card,
      );

      expect(player.playedCard, isNotNull);
      expect(player.playedCard!.id, 1);

      // Call copyWith without playedCard
      final updatedPlayer = player.copyWith(roundPoints: 50);

      // playedCard should be preserved
      expect(updatedPlayer.roundPoints, 50);
      expect(updatedPlayer.playedCard, isNotNull, reason: 'copyWith should preserve playedCard');
      expect(updatedPlayer.playedCard!.id, 1);
    });

    test('clearPlayedCard removes playedCard', () {
      const card = CardModel(id: 1, suit: 'H', rank: 14, points: 10, assetPath: '');
      final player = PlayerModel(
        id: 0,
        name: 'You',
        avatarPath: '',
        coins: 1000,
        isHuman: true,
        playedCard: card,
      );

      final updatedPlayer = player.clearPlayedCard();

      expect(updatedPlayer.playedCard, isNull);
    });

    test('copyWith explicitly updating playedCard works', () {
      const card1 = CardModel(id: 1, suit: 'H', rank: 14, points: 10, assetPath: '');
      const card2 = CardModel(id: 2, suit: 'S', rank: 10, points: 10, assetPath: '');
      
      final player = PlayerModel(
        id: 0,
        name: 'You',
        avatarPath: '',
        coins: 1000,
        isHuman: true,
        playedCard: card1,
      );

      final updatedPlayer = player.copyWith(playedCard: card2);

      expect(updatedPlayer.playedCard, isNotNull);
      expect(updatedPlayer.playedCard!.id, 2);
    });
  });
}
