import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card_model.dart';
import '../models/player_model.dart';
import '../models/game_state.dart';
import '../core/sound_manager.dart';
import 'stats_provider.dart';
import 'multiplayer_notifier.dart';

class GameNotifier extends StateNotifier<GameState> {
  final Ref ref;

  GameNotifier(this.ref) : super(_createInitialState());

  static GameState _createInitialState() {
    return GameState(
      phase: GamePhase.splash,
      players: [
        const PlayerModel(id: 0, name: 'You', avatarPath: 'assets/images/guest_avatar.png', coins: 5000, isHuman: true),
        const PlayerModel(id: 1, name: 'Alpha Bot', avatarPath: 'assets/images/guest_avatar.png', coins: 5000, isHuman: false),
        const PlayerModel(id: 2, name: 'Beta Bot', avatarPath: 'assets/images/guest_avatar.png', coins: 5000, isHuman: false),
        const PlayerModel(id: 3, name: 'Gamma Bot', avatarPath: 'assets/images/guest_avatar.png', coins: 5000, isHuman: false),
      ],
      activePlayerIndex: 0,
      dealerIndex: 0,
      roundNumber: 0,
      gameTurn: 1,
      trumpStart: 'x',
      trump: 'x',
      winningBid: 0,
      message: 'Welcome to Three of Spades!',
    );
  }

  void toggleSound() {
    final enabled = !state.soundEnabled;
    SoundManager().setEnabled(enabled);
    state = state.copyWith(soundEnabled: enabled);
  }

  void goToHome() {
    final userCoins = ref.read(statsProvider).coins;
    // Update player 0 coins from stats
    final updatedPlayers = List<PlayerModel>.from(state.players);
    updatedPlayers[0] = updatedPlayers[0].copyWith(coins: userCoins);

    state = state.copyWith(
      phase: GamePhase.home,
      players: updatedPlayers,
      message: 'Select a mode to play',
    );

    // Cancel any active matchmaking / room state
    ref.read(multiplayerProvider.notifier).cancelMatchmaking();
  }

  void updatePlayersCoins() {
    state = state.copyWith(phase: GamePhase.start);
  }

  void startNewGame() {
    final userCoins = ref.read(statsProvider).coins;
    final preserveMultiplayer = state.isMultiplayer;
    
    // Generate fresh deck and shuffle
    final deck = CardModel.generateDeck();
    deck.shuffle(Random());

    // Play shuffle sound
    SoundManager().playSound('sounds/card_shuffle.mp3');

    // Distribute 13 cards to 4 players
    final List<List<CardModel>> hands = [[], [], [], []];
    for (int i = 0; i < 52; i++) {
      hands[i % 4].add(deck[i]);
    }

    // Sort each hand by suit and rank
    // Suit priority: Spades (S), Hearts (H), Clubs (C), Diamonds (D)
    final suitOrder = {'S': 0, 'H': 1, 'C': 2, 'D': 3};
    for (int i = 0; i < 4; i++) {
      hands[i].sort((a, b) {
        if (a.suit != b.suit) {
          return suitOrder[a.suit]!.compareTo(suitOrder[b.suit]!);
        }
        return b.rank.compareTo(a.rank); // Descending rank
      });
    }

    // Update player models
    final updatedPlayers = <PlayerModel>[];
    for (int i = 0; i < 4; i++) {
      final p = state.players[i];
      updatedPlayers.add(PlayerModel(
        id: p.id,
        name: p.id == 0 ? ref.read(statsProvider).name : p.name,
        avatarPath: p.avatarPath,
        coins: p.id == 0 ? userCoins : p.coins,
        isHuman: p.isHuman,
        hand: hands[i],
        currentBid: null,
        hasPassed: false,
        playedCard: null,
        roundPoints: 0,
        isBidder: false,
        isPartner: false,
        isPartnerRevealed: false,
      ));
    }

    // Bidding starts with the player next to the dealer
    final int nextDealer = (state.dealerIndex + 1) % 4;
    final int firstBidder = (nextDealer + 1) % 4;

    state = state.copyWith(
      phase: GamePhase.bidding,
      players: updatedPlayers,
      activePlayerIndex: firstBidder,
      dealerIndex: nextDealer,
      roundNumber: 1,
      gameTurn: 1,
      trumpStart: 'x',
      trump: 'x',
      partnerCard: null,
      winningBid: 0,
      bidderIndex: null,
      trickWinnerIndex: null,
      isMultiplayer: preserveMultiplayer,
      message: preserveMultiplayer 
          ? 'Match restarted! Bidding begins. Minimum bid is 175.'
          : 'Bidding started. Minimum bid is 175.',
    );

    // If active player is bot, trigger bot bidding
    _triggerBotActionIfNeeded();
  }

  void startNewMultiplayerGame(List<String> names) {
    final userCoins = ref.read(statsProvider).coins;
    
    // Generate fresh deck and shuffle
    final deck = CardModel.generateDeck();
    deck.shuffle(Random());

    // Play shuffle sound
    SoundManager().playSound('sounds/card_shuffle.mp3');

    // Distribute 13 cards to 4 players
    final List<List<CardModel>> hands = [[], [], [], []];
    for (int i = 0; i < 52; i++) {
      hands[i % 4].add(deck[i]);
    }

    // Sort each hand by suit and rank
    final suitOrder = {'S': 0, 'H': 1, 'C': 2, 'D': 3};
    for (int i = 0; i < 4; i++) {
      hands[i].sort((a, b) {
        if (a.suit != b.suit) {
          return suitOrder[a.suit]!.compareTo(suitOrder[b.suit]!);
        }
        return b.rank.compareTo(a.rank);
      });
    }

    // Update player models with multiplayer names
    final updatedPlayers = <PlayerModel>[];
    for (int i = 0; i < 4; i++) {
      final name = names.length > i ? names[i] : 'Player $i';
      updatedPlayers.add(PlayerModel(
        id: i,
        name: name,
        avatarPath: 'assets/images/guest_avatar.png',
        coins: i == 0 ? userCoins : 5000,
        isHuman: i == 0,
        hand: hands[i],
        currentBid: null,
        hasPassed: false,
        playedCard: null,
        roundPoints: 0,
        isBidder: false,
        isPartner: false,
        isPartnerRevealed: false,
      ));
    }

    // Bidding starts with the player next to the dealer
    final int nextDealer = (state.dealerIndex + 1) % 4;
    final int firstBidder = (nextDealer + 1) % 4;

    state = state.copyWith(
      phase: GamePhase.bidding,
      players: updatedPlayers,
      activePlayerIndex: firstBidder,
      dealerIndex: nextDealer,
      roundNumber: 1,
      gameTurn: 1,
      trumpStart: 'x',
      trump: 'x',
      partnerCard: null,
      winningBid: 0,
      bidderIndex: null,
      trickWinnerIndex: null,
      isMultiplayer: true,
      message: 'Match started! Bidding begins. Minimum bid is 175.',
    );

    _triggerBotActionIfNeeded();
  }

  void placeBid(int amount) {
    if (state.phase != GamePhase.bidding) return;
    
    final player = state.players[state.activePlayerIndex];
    
    // Update player bid
    final updatedPlayers = state.players.map((p) {
      if (p.id == player.id) {
        return p.copyWith(currentBid: amount);
      }
      return p;
    }).toList();

    state = state.copyWith(
      players: updatedPlayers,
      winningBid: amount,
      bidderIndex: player.id,
      message: '${player.name} bid $amount points.',
    );

    SoundManager().playSound('sounds/update.mp3');
    _advanceBiddingTurn();
  }

  void passBid() {
    if (state.phase != GamePhase.bidding) return;

    final player = state.players[state.activePlayerIndex];

    final updatedPlayers = state.players.map((p) {
      if (p.id == player.id) {
        return p.copyWith(hasPassed: true);
      }
      return p;
    }).toList();

    state = state.copyWith(
      players: updatedPlayers,
      message: '${player.name} passed.',
    );

    SoundManager().playSound('sounds/update.mp3');
    _advanceBiddingTurn();
  }

  void _advanceBiddingTurn() {
    final activeBidders = state.players.where((p) => !p.hasPassed).toList();

    // If 3 players passed
    if (activeBidders.length == 1) {
      final winner = activeBidders.first;
      
      // If winner hasn't bid yet (e.g., everyone passed before them)
      if (winner.currentBid == null) {
        // They must bid at least 175
        if (winner.isHuman) {
          state = state.copyWith(
            activePlayerIndex: winner.id,
            message: 'All players passed before you. You must bid at least 175 or Pass.',
          );
          return;
        } else {
          // Bot force bid 175
          final updatedPlayers = state.players.map((p) {
            if (p.id == winner.id) {
              return p.copyWith(currentBid: 175);
            }
            return p;
          }).toList();

          state = state.copyWith(
            players: updatedPlayers,
            winningBid: 175,
            bidderIndex: winner.id,
            message: '${winner.name} is forced to bid 175.',
          );
        }
      }

      // Bidding complete! The winner declares Trump and Partner card
      final finalPlayers = state.players.map((p) {
        if (p.id == state.bidderIndex) {
          return p.copyWith(isBidder: true);
        }
        return p;
      }).toList();

      state = state.copyWith(
        phase: GamePhase.declaring,
        players: finalPlayers,
        activePlayerIndex: state.bidderIndex!,
        message: '${state.players[state.bidderIndex!].name} won the bid with ${state.winningBid}! Declaring Trump & Partner...',
      );

      SoundManager().playSound('sounds/success.mp3');
      _triggerBotActionIfNeeded();
      return;
    }

    // If all 4 players passed without any bid
    if (activeBidders.isEmpty) {
      state = state.copyWith(
        message: 'All players passed. Redealing...',
      );
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) startNewGame();
      });
      return;
    }

    // Find next player who has not passed
    int nextIndex = state.activePlayerIndex;
    do {
      nextIndex = (nextIndex + 1) % 4;
    } while (state.players[nextIndex].hasPassed);

    state = state.copyWith(activePlayerIndex: nextIndex);
    _triggerBotActionIfNeeded();
  }

  void declareTrumpAndPartner(String trumpSuit, CardModel partnerCard) {
    if (state.phase != GamePhase.declaring) return;

    // Set partner on the player holding this card
    final updatedPlayers = state.players.map((p) {
      final hasCard = p.hand.any((c) => c.suit == partnerCard.suit && c.rank == partnerCard.rank);
      if (hasCard) {
        return p.copyWith(isPartner: true);
      }
      return p;
    }).toList();

    state = state.copyWith(
      phase: GamePhase.playing,
      players: updatedPlayers,
      trump: trumpSuit,
      partnerCard: partnerCard,
      activePlayerIndex: state.bidderIndex!, // Bidder leads first trick
      roundNumber: 1,
      gameTurn: 1,
      trumpStart: 'x',
      message: 'Trump is ${CardModel.getSuitName(trumpSuit)}s. Partner Card is ${partnerCard.name}. ${state.players[state.bidderIndex!].name} leads.',
    );

    SoundManager().playSound('sounds/success.mp3');
    _triggerBotActionIfNeeded();
  }

  bool playCard(CardModel card) {
    if (state.phase != GamePhase.playing) return false;
    if (state.trickWinnerIndex != null) return false; // In between tricks evaluation

    final player = state.players[state.activePlayerIndex];

    // Validate if turn follows suit
    if (state.gameTurn > 1) {
      final hasLedSuit = player.hand.any((c) => c.suit == state.trumpStart);
      if (hasLedSuit && card.suit != state.trumpStart) {
        state = state.copyWith(
          message: 'Invalid play! You must follow suit (${CardModel.getSuitName(state.trumpStart)}s).',
        );
        SoundManager().playSound('sounds/error.mp3');
        return false;
      }
    }

    // Valid card played. Remove card from player hand and set playedCard
    final updatedHand = player.hand.where((c) => c.id != card.id).toList();
    
    // Check if player played the partner card
    bool partnerRevealedThisTurn = false;
    final bool isPartnerCard = state.partnerCard != null && 
        card.suit == state.partnerCard!.suit && 
        card.rank == state.partnerCard!.rank;

    final updatedPlayers = state.players.map((p) {
      if (p.id == player.id) {
        return p.copyWith(
          hand: updatedHand,
          playedCard: card,
          isPartnerRevealed: p.isPartnerRevealed || isPartnerCard,
        );
      }
      return p;
    }).toList();

    String ledSuit = state.trumpStart;
    if (state.gameTurn == 1) {
      ledSuit = card.suit;
    }

    String msg = '${player.name} played ${card.name}.';
    if (isPartnerCard) {
      partnerRevealedThisTurn = true;
      msg = '${player.name} played the Partner Card (${card.name}) and is revealed!';
    }

    state = state.copyWith(
      players: updatedPlayers,
      trumpStart: ledSuit,
      message: msg,
    );

    SoundManager().playSound('sounds/card_played.mp3');

    if (partnerRevealedThisTurn) {
      SoundManager().playSound('sounds/player_success_chime.mp3');
    }

    if (state.isMultiplayer && Random().nextDouble() < 0.3) {
      ref.read(multiplayerProvider.notifier).triggerPeerReaction();
    }

    // Advance turn
    if (state.gameTurn < 4) {
      final nextIndex = (state.activePlayerIndex + 1) % 4;
      state = state.copyWith(
        gameTurn: state.gameTurn + 1,
        activePlayerIndex: nextIndex,
      );
      _triggerBotActionIfNeeded();
    } else {
      // Evaluate trick
      _evaluateTrick();
    }

    return true;
  }

  int _determineTrickWinnerIndex() {
    int bestIndex = state.activePlayerIndex; // Last active player, but we trace starting leader
    // Wait, the leader index is (activePlayerIndex - 3) % 4
    final int leaderIndex = (state.activePlayerIndex - 3 + 4) % 4;
    
    bestIndex = leaderIndex;
    CardModel bestCard = state.players[leaderIndex].playedCard!;

    for (int i = 0; i < 4; i++) {
      final card = state.players[i].playedCard;
      if (card == null || i == leaderIndex) continue;

      bool isNewBetter = false;

      // If new card is Trump
      if (card.suit == state.trump) {
        if (bestCard.suit != state.trump) {
          isNewBetter = true;
        } else {
          // Both are trump. Compare ranks.
          // Note: Spade 3 is 30 points, but does rank change?
          // In standard Kaali Ki Teeggi, Spade 3 rank is standard (3), but holds point values.
          // Highest rank wins.
          if (card.rank > bestCard.rank) {
            isNewBetter = true;
          }
        }
      }
      // If new card is NOT Trump
      else {
        // Can only win if best card is NOT trump and new card matches trumpStart (led suit)
        if (bestCard.suit != state.trump && card.suit == state.trumpStart) {
          if (bestCard.suit != state.trumpStart) {
            isNewBetter = true;
          } else {
            // Both led suit, higher rank wins
            if (card.rank > bestCard.rank) {
              isNewBetter = true;
            }
          }
        }
      }

      if (isNewBetter) {
        bestIndex = i;
        bestCard = card;
      }
    }

    return bestIndex;
  }

  Future<void> _evaluateTrick() async {
    final winnerIndex = _determineTrickWinnerIndex();
    final winner = state.players[winnerIndex];

    int trickPoints = 0;
    for (var p in state.players) {
      if (p.playedCard != null) {
        trickPoints += p.playedCard!.points;
      }
    }

    final updatedPlayers = state.players.map((p) {
      if (p.id == winnerIndex) {
        return p.copyWith(roundPoints: p.roundPoints + trickPoints);
      }
      return p;
    }).toList();

    state = state.copyWith(
      players: updatedPlayers,
      trickWinnerIndex: winnerIndex,
      message: '${winner.name} wins the trick with ${state.players[winnerIndex].playedCard!.name} (+$trickPoints pts)!',
    );

    // Play collect sound
    SoundManager().playSound('sounds/card_collect.mp3');

    // Wait 2.5 seconds so player can inspect
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    // Clear played cards
    final clearedPlayers = state.players.map((p) => p.clearPlayedCard()).toList();

    if (state.roundNumber < 13) {
      state = state.copyWith(
        players: clearedPlayers,
        roundNumber: state.roundNumber + 1,
        gameTurn: 1,
        trumpStart: 'x',
        activePlayerIndex: winnerIndex,
        trickWinnerIndex: null,
        message: '${state.players[winnerIndex].name}\'s turn to lead.',
      );
      _triggerBotActionIfNeeded();
    } else {
      _endGame(clearedPlayers);
    }
  }

  void _endGame(List<PlayerModel> finalPlayers) {
    final bidderIndex = state.bidderIndex!;
    
    // Find partner index
    int partnerIndex = bidderIndex;
    for (int i = 0; i < 4; i++) {
      if (finalPlayers[i].isPartner) {
        partnerIndex = i;
        break;
      }
    }

    final bidderPoints = finalPlayers[bidderIndex].roundPoints;
    final partnerPoints = finalPlayers[partnerIndex].roundPoints;
    final totalBidderPoints = bidderIndex == partnerIndex 
        ? bidderPoints 
        : bidderPoints + partnerPoints;

    final isBidWon = totalBidderPoints >= state.winningBid;

    // Determine coin changes
    // Bidder won: Bidder gets +300, Partner gets +150, Defenders get -150 each
    // Bidder lost: Bidder gets -300, Partner gets -150, Defenders get +150 each
    final coinDelta = List<int>.filled(4, 0);
    if (isBidWon) {
      coinDelta[bidderIndex] = 300;
      coinDelta[partnerIndex] = bidderIndex == partnerIndex ? 300 : 150;
      for (int i = 0; i < 4; i++) {
        if (i != bidderIndex && i != partnerIndex) {
          coinDelta[i] = -150;
        }
      }
    } else {
      coinDelta[bidderIndex] = -300;
      coinDelta[partnerIndex] = bidderIndex == partnerIndex ? -300 : -150;
      for (int i = 0; i < 4; i++) {
        if (i != bidderIndex && i != partnerIndex) {
          coinDelta[i] = 150;
        }
      }
    }

    // Apply coin delta and update stats
    final updatedPlayers = <PlayerModel>[];
    for (int i = 0; i < 4; i++) {
      final p = finalPlayers[i];
      int newCoins = p.coins + coinDelta[i];
      if (newCoins < 0) newCoins = 0; // Prevent negative coins
      updatedPlayers.add(p.copyWith(coins: newCoins));
    }

    final isHumanBidder = bidderIndex == 0;
    final isHumanPartner = partnerIndex == 0;
    final isHumanBidderOrPartner = isHumanBidder || isHumanPartner;

    final bool humanWon = isBidWon ? isHumanBidderOrPartner : !isHumanBidderOrPartner;

    // Persist stats for the human guest player
    final statsNotifier = ref.read(statsProvider.notifier);
    statsNotifier.updateCoins(coinDelta[0]);
    statsNotifier.recordGame(humanWon, isHumanBidderOrPartner ? state.winningBid : 0);

    // Play final sound
    if (humanWon) {
      SoundManager().playSound('sounds/game_win.mp3');
    } else {
      SoundManager().playSound('sounds/game_lose.mp3');
    }

    // Create a final message summary
    final String partnerName = bidderIndex == partnerIndex ? "themselves" : finalPlayers[partnerIndex].name;
    final String resultMsg = isBidWon 
        ? 'Bidder & Partner won! Got $totalBidderPoints / ${state.winningBid} points.'
        : 'Defenders won! Bidder & Partner only got $totalBidderPoints / ${state.winningBid} points.';

    state = state.copyWith(
      phase: GamePhase.roundOver,
      players: updatedPlayers,
      message: 'Game Over! Bidder was ${finalPlayers[bidderIndex].name}, Partner was $partnerName. $resultMsg',
    );
  }

  void _triggerBotActionIfNeeded() {
    if (!mounted) return;
    
    if (state.phase == GamePhase.bidding) {
      final activePlayer = state.players[state.activePlayerIndex];
      if (!activePlayer.isHuman && !activePlayer.hasPassed) {
        final delayMs = state.isMultiplayer ? 1500 + Random().nextInt(1500) : 1200;
        Future.delayed(Duration(milliseconds: delayMs), () {
          if (!mounted) return;
          _botBid();
        });
      }
    } else if (state.phase == GamePhase.declaring) {
      final bidder = state.players[state.bidderIndex!];
      if (!bidder.isHuman) {
        final delayMs = state.isMultiplayer ? 2000 + Random().nextInt(1500) : 1500;
        Future.delayed(Duration(milliseconds: delayMs), () {
          if (!mounted) return;
          _botDeclare();
        });
      }
    } else if (state.phase == GamePhase.playing) {
      final activePlayer = state.players[state.activePlayerIndex];
      if (!activePlayer.isHuman) {
        final delayMs = state.isMultiplayer ? 1500 + Random().nextInt(1500) : 1200;
        Future.delayed(Duration(milliseconds: delayMs), () {
          if (!mounted) return;
          _botPlayCard();
        });
      }
    }
  }

  void _botBid() {
    if (state.phase != GamePhase.bidding) return;

    final bot = state.players[state.activePlayerIndex];
    final maxBid = _calculateBotBidStrength(bot.hand);

    int nextBid = ((state.winningBid) ~/ 5 * 5) + 5;
    if (nextBid < 175) nextBid = 175;

    if (nextBid <= maxBid) {
      placeBid(nextBid);
    } else {
      passBid();
    }
  }

  int _calculateBotBidStrength(List<CardModel> hand) {
    final Map<String, int> suitCounts = {'S': 0, 'H': 0, 'C': 0, 'D': 0};
    for (var card in hand) {
      suitCounts[card.suit] = suitCounts[card.suit]! + 1;
    }

    String longestSuit = 'S';
    int maxCount = 0;
    suitCounts.forEach((suit, count) {
      if (count > maxCount) {
        maxCount = count;
        longestSuit = suit;
      }
    });

    int strength = maxCount * 15;
    for (var card in hand) {
      if (card.suit == longestSuit) {
        if (card.rank == 14) strength += 20; // Ace
        if (card.rank == 13) strength += 15; // King
        if (card.rank == 12) strength += 10; // Queen
        if (card.rank == 11) strength += 8;  // Jack
        if (card.rank == 10) strength += 5;  // 10
        if (card.suit == 'S' && card.rank == 3) strength += 30; // 3 of Spades
      } else {
        if (card.rank == 14) strength += 10;
        if (card.rank == 13) strength += 5;
        if (card.suit == 'S' && card.rank == 3) strength += 25;
      }
    }

    int calculatedBid = 175 + (strength * 0.65).toInt();
    calculatedBid = (calculatedBid ~/ 5) * 5;

    if (calculatedBid > 310) calculatedBid = 310;
    if (calculatedBid < 175) calculatedBid = 175;

    return calculatedBid;
  }

  void _botDeclare() {
    if (state.phase != GamePhase.declaring) return;

    final bot = state.players[state.bidderIndex!];

    // Select longest suit as Trump
    final Map<String, int> suitCounts = {'S': 0, 'H': 0, 'C': 0, 'D': 0};
    for (var card in bot.hand) {
      suitCounts[card.suit] = suitCounts[card.suit]! + 1;
    }

    String selectedTrump = 'S';
    int maxCount = 0;
    suitCounts.forEach((suit, count) {
      if (count > maxCount) {
        maxCount = count;
        selectedTrump = suit;
      }
    });

    // Nominate partner card: highest rank card of selectedTrump suit that bot does NOT hold
    final allCards = CardModel.generateDeck();
    
    // Sort all cards in trump suit descending rank
    final trumpCardsInDeck = allCards.where((c) => c.suit == selectedTrump).toList();
    trumpCardsInDeck.sort((a, b) => b.rank.compareTo(a.rank));

    CardModel? selectedPartnerCard;
    for (var card in trumpCardsInDeck) {
      final botHasIt = bot.hand.any((c) => c.suit == card.suit && c.rank == card.rank);
      if (!botHasIt) {
        selectedPartnerCard = card;
        break;
      }
    }

    // If bot somehow holds all cards of that suit (rare/impossible), look for other suits
    if (selectedPartnerCard == null) {
      for (var card in allCards) {
        final botHasIt = bot.hand.any((c) => c.suit == card.suit && c.rank == card.rank);
        if (!botHasIt) {
          selectedPartnerCard = card;
          break;
        }
      }
    }

    declareTrumpAndPartner(selectedTrump, selectedPartnerCard!);
  }

  void _botPlayCard() {
    if (state.phase != GamePhase.playing) return;

    final bot = state.players[state.activePlayerIndex];
    CardModel? cardToPlay;

    if (state.gameTurn == 1) {
      // Bot is leading. Heuristic: play a non-trump high card, or random
      // Let's just play a random card from hand to fulfill rule-based random start
      final random = Random();
      cardToPlay = bot.hand[random.nextInt(bot.hand.length)];
    } else {
      // Must follow suit if possible
      final matchingCards = bot.hand.where((c) => c.suit == state.trumpStart).toList();
      if (matchingCards.isNotEmpty) {
        // Play highest card of matching suit
        matchingCards.sort((a, b) => b.rank.compareTo(a.rank));
        cardToPlay = matchingCards.first;
      } else {
        // Void in starting suit, try to play Trump
        final trumpCards = bot.hand.where((c) => c.suit == state.trump).toList();
        if (trumpCards.isNotEmpty) {
          // Play highest trump card
          trumpCards.sort((a, b) => b.rank.compareTo(a.rank));
          cardToPlay = trumpCards.first;
        } else {
          // Void in starting suit and trump, play a random card
          final random = Random();
          cardToPlay = bot.hand[random.nextInt(bot.hand.length)];
        }
      }
    }

    playCard(cardToPlay);
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier(ref);
});
