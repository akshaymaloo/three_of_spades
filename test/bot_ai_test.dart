import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_of_spades_flutter/models/card_model.dart';
import 'package:three_of_spades_flutter/models/game_state.dart';
import 'package:three_of_spades_flutter/models/player_model.dart';
import 'package:three_of_spades_flutter/core/sound_manager.dart';
import 'package:three_of_spades_flutter/providers/game_notifier.dart';
import 'package:three_of_spades_flutter/providers/stats_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    SoundManager().setEnabled(false);
  });

  Future<ProviderContainer> createContainer() async {
    final container = ProviderContainer();
    container.read(statsProvider);
    await Future.delayed(const Duration(milliseconds: 50));
    return container;
  }

  group('Strategic Bot AI Tests', () {
    test('Bot declare chooses longest suit and highest partner card not held', () async {
      final container = await createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);

      // Bot Hand has 4 Hearts, 2 Clubs.
      // Longest suit: Hearts (H). It has Aces, Kings, but not Queen (H-12).
      final h14 = const CardModel(id: 1, suit: 'H', rank: 14, points: 20, assetPath: '');
      final h13 = const CardModel(id: 2, suit: 'H', rank: 13, points: 15, assetPath: '');
      final h10 = const CardModel(id: 3, suit: 'H', rank: 10, points: 10, assetPath: '');
      final h2 = const CardModel(id: 4, suit: 'H', rank: 2, points: 0, assetPath: '');
      final c5 = const CardModel(id: 5, suit: 'C', rank: 5, points: 5, assetPath: '');
      final c6 = const CardModel(id: 6, suit: 'C', rank: 6, points: 0, assetPath: '');

      final botHand = [h14, h13, h10, h2, c5, c6];

      final players = [
        const PlayerModel(id: 0, name: 'You', avatarPath: '', coins: 5000, isHuman: true),
        PlayerModel(id: 1, name: 'Alpha Bot', avatarPath: '', coins: 5000, hand: botHand, isHuman: false),
        const PlayerModel(id: 2, name: 'Beta Bot', avatarPath: '', coins: 5000, isHuman: false),
        const PlayerModel(id: 3, name: 'Gamma Bot', avatarPath: '', coins: 5000, isHuman: false),
      ];

      notifier.state = GameState(
        phase: GamePhase.declaring,
        players: players,
        activePlayerIndex: 1,
        dealerIndex: 0,
        roundNumber: 1,
        gameTurn: 1,
        trumpStart: 'x',
        trump: 'x',
        winningBid: 180,
        bidderIndex: 1, // Bot is the bidder
        message: 'Declaring...',
      );

      notifier.triggerBotAction();

      // Wait 1.6s for the bot declare timer to fire
      await Future.delayed(const Duration(milliseconds: 1650));

      final state = container.read(gameProvider);
      expect(state.phase, GamePhase.playing);
      expect(state.trump, 'H'); // Decided on longest suit: Hearts
      expect(state.partnerCard?.suit, 'H');
      expect(state.partnerCard?.rank, 12); // Highest Heart not held (Queen)
    });

    test('Bot playing follows suit with lowest card when ally is winning', () async {
      final container = await createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);

      // Player 0 (human bidder) played Heart 10. Partner is player 1 (bot).
      final h10 = const CardModel(id: 10, suit: 'H', rank: 10, points: 10, assetPath: '');
      
      // Bot has H-14 (Ace), H-12 (Queen), H-2.
      final h14 = const CardModel(id: 1, suit: 'H', rank: 14, points: 20, assetPath: '');
      final h12 = const CardModel(id: 2, suit: 'H', rank: 12, points: 15, assetPath: '');
      final h2 = const CardModel(id: 3, suit: 'H', rank: 2, points: 0, assetPath: '');

      final players = [
        PlayerModel(id: 0, name: 'You', avatarPath: '', coins: 5000, hand: const [], isHuman: true, playedCard: h10, isBidder: true),
        PlayerModel(id: 1, name: 'Alpha Bot', avatarPath: '', coins: 5000, hand: [h14, h12, h2], isHuman: false, isPartner: true, isPartnerRevealed: true),
        const PlayerModel(id: 2, name: 'Beta Bot', avatarPath: '', coins: 5000, hand: [], isHuman: false),
        const PlayerModel(id: 3, name: 'Gamma Bot', avatarPath: '', coins: 5000, hand: [], isHuman: false),
      ];

      notifier.state = GameState(
        phase: GamePhase.playing,
        players: players,
        activePlayerIndex: 1, // Bot turn
        dealerIndex: 3,
        roundNumber: 1,
        gameTurn: 2,
        trumpStart: 'H',
        trump: 'S',
        winningBid: 180,
        bidderIndex: 0,
        message: 'Bot playing...',
      );

      notifier.triggerBotAction();
      await Future.delayed(const Duration(milliseconds: 1300)); // Bot play timer is 1200ms

      final state = container.read(gameProvider);
      // Bot should have played Heart 2 (lowest rank matching)
      expect(state.players[1].playedCard?.rank, 2);
    });

    test('Bot playing follows suit with lowest winning card when opponent is winning', () async {
      final container = await createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);

      // Player 0 (human bidder) played Heart 10. Player 1 (bot) is defender (opponent).
      final h10 = const CardModel(id: 10, suit: 'H', rank: 10, points: 10, assetPath: '');
      
      // Bot has H-14 (Ace), H-12 (Queen), H-2.
      final h14 = const CardModel(id: 1, suit: 'H', rank: 14, points: 20, assetPath: '');
      final h12 = const CardModel(id: 2, suit: 'H', rank: 12, points: 15, assetPath: '');
      final h2 = const CardModel(id: 3, suit: 'H', rank: 2, points: 0, assetPath: '');

      final players = [
        PlayerModel(id: 0, name: 'You', avatarPath: '', coins: 5000, hand: const [], isHuman: true, playedCard: h10, isBidder: true),
        PlayerModel(id: 1, name: 'Alpha Bot', avatarPath: '', coins: 5000, hand: [h14, h12, h2], isHuman: false, isPartner: false),
        const PlayerModel(id: 2, name: 'Beta Bot', avatarPath: '', coins: 5000, hand: [], isHuman: false),
        const PlayerModel(id: 3, name: 'Gamma Bot', avatarPath: '', coins: 5000, hand: [], isHuman: false),
      ];

      notifier.state = GameState(
        phase: GamePhase.playing,
        players: players,
        activePlayerIndex: 1, // Bot turn
        dealerIndex: 3,
        roundNumber: 1,
        gameTurn: 2,
        trumpStart: 'H',
        trump: 'S',
        winningBid: 180,
        bidderIndex: 0,
        message: 'Bot playing...',
      );

      notifier.triggerBotAction();
      await Future.delayed(const Duration(milliseconds: 1300));

      final state = container.read(gameProvider);
      // Bot should play Heart 12 (lowest card that beats Heart 10)
      expect(state.players[1].playedCard?.rank, 12);
    });
  });
}
