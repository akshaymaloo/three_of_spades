import 'card_model.dart';
import 'player_model.dart';

enum GamePhase {
  splash,
  start,
  home,
  dealing,
  bidding,
  declaring,
  playing,
  roundOver,
  matchOver,
}

class Nullable<T> {
  final T value;
  const Nullable(this.value);
}

class GameState {
  final GamePhase phase;
  final List<PlayerModel> players;
  final int playerCount;        // 4 or 7
  final int activePlayerIndex;  // 0..(playerCount-1)
  final int dealerIndex;        // 0..(playerCount-1)
  final int roundNumber;        // 1..tricksPerRound
  final int gameTurn;           // 1..playerCount (cards played in current trick)
  final String trumpStart;      // Suit of the first card played in current trick
  final String trump;           // 'S', 'H', 'C', 'D' or 'x'
  final CardModel? partnerCard;
  final CardModel? partnerCard2;
  final int winningBid;
  final int? bidderIndex;       // 0..(playerCount-1)
  final int? partnerIndex2;     // 0..(playerCount-1)
  final int? trickWinnerIndex;  // 0..(playerCount-1)
  final String message;
  final bool soundEnabled;
  final bool isMultiplayer;
  final bool isTrainingMode;

  const GameState({
    required this.phase,
    required this.players,
    this.playerCount = 4,
    required this.activePlayerIndex,
    required this.dealerIndex,
    required this.roundNumber,
    required this.gameTurn,
    required this.trumpStart,
    required this.trump,
    this.partnerCard,
    this.partnerCard2,
    required this.winningBid,
    this.bidderIndex,
    this.partnerIndex2,
    this.trickWinnerIndex,
    required this.message,
    this.soundEnabled = true,
    this.isMultiplayer = false,
    this.isTrainingMode = false,
  });

  GameState copyWith({
    GamePhase? phase,
    List<PlayerModel>? players,
    int? playerCount,
    int? activePlayerIndex,
    int? dealerIndex,
    int? roundNumber,
    int? gameTurn,
    String? trumpStart,
    String? trump,
    Nullable<CardModel?>? partnerCard,
    Nullable<CardModel?>? partnerCard2,
    int? winningBid,
    Nullable<int?>? bidderIndex,
    Nullable<int?>? partnerIndex2,
    Nullable<int?>? trickWinnerIndex,
    String? message,
    bool? soundEnabled,
    bool? isMultiplayer,
    bool? isTrainingMode,
  }) {
    return GameState(
      phase: phase ?? this.phase,
      players: players ?? this.players,
      playerCount: playerCount ?? this.playerCount,
      activePlayerIndex: activePlayerIndex ?? this.activePlayerIndex,
      dealerIndex: dealerIndex ?? this.dealerIndex,
      roundNumber: roundNumber ?? this.roundNumber,
      gameTurn: gameTurn ?? this.gameTurn,
      trumpStart: trumpStart ?? this.trumpStart,
      trump: trump ?? this.trump,
      partnerCard: partnerCard != null ? partnerCard.value : this.partnerCard,
      partnerCard2: partnerCard2 != null ? partnerCard2.value : this.partnerCard2,
      winningBid: winningBid ?? this.winningBid,
      bidderIndex: bidderIndex != null ? bidderIndex.value : this.bidderIndex,
      partnerIndex2: partnerIndex2 != null ? partnerIndex2.value : this.partnerIndex2,
      trickWinnerIndex: trickWinnerIndex != null ? trickWinnerIndex.value : this.trickWinnerIndex,
      message: message ?? this.message,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      isMultiplayer: isMultiplayer ?? this.isMultiplayer,
      isTrainingMode: isTrainingMode ?? this.isTrainingMode,
    );
  }

  int get tricksPerRound => playerCount == 7 ? 14 : 13;

  // Helper to fetch the current trick cards in order of players
  List<CardModel?> get currentTrickCards => players.map((p) => p.playedCard).toList();
}
