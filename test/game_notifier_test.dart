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
    SharedPreferences.setMockInitialValues({
      'guest_name': 'CardMaster',
      'guest_coins': 5000,
    });
    SoundManager().setEnabled(false);
  });

  Future<ProviderContainer> createInitializedContainer() async {
    final container = ProviderContainer();
    container.read(statsProvider);
    // Let async shared prefs load
    await Future.delayed(const Duration(milliseconds: 50));
    return container;
  }

  group('Game Notifier Loop Tests', () {
    test('Initial game state is splash', () async {
      final container = await createInitializedContainer();
      addTearDown(container.dispose);

      final state = container.read(gameProvider);
      expect(state.phase, GamePhase.splash);
      expect(state.players.length, 4);
    });

    test('startNewGame initializes cards, hands and transitions to bidding', () async {
      final container = await createInitializedContainer();
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.startNewGame();

      var state = container.read(gameProvider);
      expect(state.phase, GamePhase.dealing);

      notifier.completeDealing();
      state = container.read(gameProvider);
      expect(state.phase, GamePhase.bidding);
      expect(state.roundNumber, 1);
      
      for (final player in state.players) {
        expect(player.hand.length, 13);
        // Hand must be sorted descending by rank within suits
        for (int i = 0; i < player.hand.length - 1; i++) {
          final c1 = player.hand[i];
          final c2 = player.hand[i + 1];
          if (c1.suit == c2.suit) {
            expect(c1.rank >= c2.rank, isTrue);
          }
        }
      }
    });

    test('Bidding process works and advances turns', () async {
      final container = await createInitializedContainer();
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.startNewGame();
      notifier.completeDealing();

      var state = container.read(gameProvider);
      final firstBidderIdx = state.activePlayerIndex;

      // Player bids 180
      notifier.placeBid(180);

      state = container.read(gameProvider);
      expect(state.winningBid, 180);
      expect(state.bidderIndex, firstBidderIdx);
      expect(state.activePlayerIndex, isNot(firstBidderIdx));
    });

    test('Bidding completes when 3 players pass', () async {
      final container = await createInitializedContainer();
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.startNewGame();
      notifier.completeDealing();

      // We will place bids and pass until one winner remains
      var state = container.read(gameProvider);
      final humanIdx = 0;
      
      for (int i = 0; i < 4; i++) {
        state = container.read(gameProvider);
        if (state.activePlayerIndex == humanIdx) {
          notifier.placeBid(180);
        } else {
          notifier.passBid();
        }
      }

      // Check if more passes are needed
      state = container.read(gameProvider);
      int attempts = 0;
      while (state.phase == GamePhase.bidding && attempts < 10) {
        if (state.activePlayerIndex == humanIdx) {
          notifier.placeBid(185);
        } else {
          notifier.passBid();
        }
        state = container.read(gameProvider);
        attempts++;
      }

      expect(state.phase, GamePhase.declaring);
      expect(state.bidderIndex, humanIdx);
      expect(state.winningBid, greaterThanOrEqualTo(180));
    });

    test('Declaring trump and partner transitions to playing and sets partner', () async {
      final container = await createInitializedContainer();
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.startNewGame();
      notifier.completeDealing();

      var state = container.read(gameProvider);
      
      // Directly transition the state to declaring phase with player 0 as bidder
      final updatedPlayers = state.players.map((p) => p.copyWith(hasPassed: p.id != 0, currentBid: p.id == 0 ? 180 : null)).toList();
      notifier.state = state.copyWith(
        phase: GamePhase.declaring,
        bidderIndex: const Nullable(0),
        winningBid: 180,
        players: updatedPlayers,
      );

      state = container.read(gameProvider);
      expect(state.phase, GamePhase.declaring);
      expect(state.bidderIndex, 0);

      // Bidder (player 0) declares Spade (S) as trump and King of Hearts (H-13) as partner card
      final kh = const CardModel(id: 99, suit: 'H', rank: 13, points: 0, assetPath: '');
      
      // Inject KH into player 2's hand for predictability
      final playersWithKH = state.players.map((p) {
        if (p.id == 2) {
          return p.copyWith(hand: [kh, ...p.hand.skip(1)]);
        } else {
          // ensure no one else has it
          return p.copyWith(hand: p.hand.where((c) => !(c.suit == 'H' && c.rank == 13)).toList());
        }
      }).toList();

      notifier.state = state.copyWith(players: playersWithKH);

      notifier.declareTrumpAndPartner('S', kh);

      state = container.read(gameProvider);
      expect(state.phase, GamePhase.playing);
      expect(state.trump, 'S');
      expect(state.partnerCard?.suit, 'H');
      expect(state.partnerCard?.rank, 13);
      expect(state.players[2].isPartner, isTrue);
      expect(state.players[0].isPartner, isFalse); // bidder is not partner
    });

    test('Follow suit validation and trick winning works', () async {
      final container = await createInitializedContainer();
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.startNewGame();
      notifier.completeDealing();

      // Setup state in playing phase
      // Player 0 leads Hearts (H)
      final c0 = const CardModel(id: 100, suit: 'H', rank: 10, points: 10, assetPath: '');
      final c1 = const CardModel(id: 101, suit: 'H', rank: 14, points: 20, assetPath: ''); // Higher Heart
      final c2 = const CardModel(id: 102, suit: 'D', rank: 8, points: 0, assetPath: '');  // Diamond (non-follow)
      final c3 = const CardModel(id: 103, suit: 'S', rank: 3, points: 30, assetPath: '');  // Spade (Trump, 3 of Spades)

      final players = [
        PlayerModel(id: 0, name: 'P0', avatarPath: '', coins: 5000, hand: [c0], isHuman: true),
        PlayerModel(id: 1, name: 'P1', avatarPath: '', coins: 5000, hand: [c1], isHuman: false),
        PlayerModel(id: 2, name: 'P2', avatarPath: '', coins: 5000, hand: [c2], isHuman: false),
        PlayerModel(id: 3, name: 'P3', avatarPath: '', coins: 5000, hand: [c3], isHuman: false),
      ];

      notifier.state = GameState(
        phase: GamePhase.playing,
        players: players,
        activePlayerIndex: 0,
        dealerIndex: 3,
        roundNumber: 1,
        gameTurn: 1,
        trumpStart: 'x',
        trump: 'S', // Spade is Trump
        winningBid: 180,
        bidderIndex: 0,
        message: 'Playing trick',
      );

      // Play P0 card (Heart 10)
      var success = notifier.playCard(c0);
      expect(success, isTrue);
      
      var state = container.read(gameProvider);
      expect(state.trumpStart, 'H');
      expect(state.gameTurn, 2);
      expect(state.activePlayerIndex, 1);

      final nonHeart = const CardModel(id: 105, suit: 'C', rank: 5, points: 0, assetPath: '');
      notifier.state = state.copyWith(
        players: state.players.map((p) {
          if (p.id == 1) {
            return p.copyWith(hand: [c1, nonHeart]);
          }
          return p;
        }).toList(),
      );

      // Play invalid (non-follow) card
      success = notifier.playCard(nonHeart);
      expect(success, isFalse);

      // Play valid card (Heart 14)
      success = notifier.playCard(c1);
      expect(success, isTrue);

      state = container.read(gameProvider);
      expect(state.gameTurn, 3);

      // Play P2 card (Diamond 8, valid because P2 has no Hearts in hand)
      success = notifier.playCard(c2);
      expect(success, isTrue);

      state = container.read(gameProvider);
      expect(state.gameTurn, 4);

      // Play P3 card (Spade 3, trump)
      success = notifier.playCard(c3);
      expect(success, isTrue);

      // After 4th play, trick is evaluated.
      state = container.read(gameProvider);
      // P3 played a trump card (Spade 3), which beats Heart 14. P3 should be the winner.
      expect(state.trickWinnerIndex, 3);
      // Check total trick points: c0(10) + c1(20) + c2(0) + c3(30) = 60 points
      expect(state.players[3].roundPoints, 60);
    });

    test('Bid-scaled scoring formula calculates and applies coin changes correctly', () async {
      final container = await createInitializedContainer();
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.startNewGame();
      notifier.completeDealing();

      // Case 1: Bidder wins the bid (total points >= bid)
      // Bidder (P0) bid 200, Partner (P1) is partner.
      // Target points: 200.
      final p0 = PlayerModel(id: 0, name: 'P0', avatarPath: '', coins: 5000, hand: [
        const CardModel(id: 500, suit: 'H', rank: 2, points: 0, assetPath: '')
      ], isHuman: true, roundPoints: 120);
      final p1 = PlayerModel(id: 1, name: 'P1', avatarPath: '', coins: 5000, hand: [
        const CardModel(id: 501, suit: 'H', rank: 3, points: 0, assetPath: '')
      ], isHuman: false, isPartner: true, roundPoints: 90);
      final p2 = PlayerModel(id: 2, name: 'P2', avatarPath: '', coins: 5000, hand: [
        const CardModel(id: 502, suit: 'H', rank: 4, points: 0, assetPath: '')
      ], isHuman: false, roundPoints: 70);
      final p3 = PlayerModel(id: 3, name: 'P3', avatarPath: '', coins: 5000, hand: [
        const CardModel(id: 503, suit: 'H', rank: 5, points: 0, assetPath: '')
      ], isHuman: false, roundPoints: 70);

      notifier.state = GameState(
        phase: GamePhase.playing,
        players: [p0, p1, p2, p3],
        activePlayerIndex: 0,
        dealerIndex: 3,
        roundNumber: 13, // last trick
        gameTurn: 1,
        trumpStart: 'x',
        trump: 'S',
        winningBid: 200,
        bidderIndex: 0,
        message: 'Playing last trick',
      );

      // Play trick
      notifier.playCard(p0.hand[0]);
      notifier.playCard(p1.hand[0]);
      notifier.playCard(p2.hand[0]);
      notifier.playCard(p3.hand[0]);

      var state = container.read(gameProvider);
      expect(state.phase, GamePhase.playing);
      expect(state.trickWinnerIndex, isNotNull);

      // Wait for trick evaluation timer (2.5s) to trigger _endGame
      await Future.delayed(const Duration(milliseconds: 2600));

      state = container.read(gameProvider);
      expect(state.phase, GamePhase.roundOver);

      // Winning bid is 200. Total bidder points = 120 + 90 = 210 >= 200 (isBidWon = true)
      // Bidder (P0) gets +400 (5000 + 400 = 5400)
      // Partner (P1) gets +200 (5000 + 200 = 5200)
      // Defenders (P2, P3) get -100 each (5000 - 100 = 4900)
      expect(state.players[0].coins, 5400);
      expect(state.players[1].coins, 5200);
      expect(state.players[2].coins, 4900);
      expect(state.players[3].coins, 4900);
    });
  });
}
