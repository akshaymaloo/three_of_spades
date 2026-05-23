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
  final int activePlayerIndex; // 0..3
  final int dealerIndex;        // 0..3
  final int roundNumber;        // 1..13 (tricks)
  final int gameTurn;           // 1..4 (cards played in current trick)
  final String trumpStart;      // Suit of the first card played in current trick
  final String trump;           // 'S', 'H', 'C', 'D' or 'x'
  final CardModel? partnerCard;
  final int winningBid;
  final int? bidderIndex;       // 0..3
  final int? trickWinnerIndex;  // 0..3
  final String message;
  final bool soundEnabled;
  final bool isMultiplayer;
  final bool isTrainingMode;

  const GameState({
    required this.phase,
    required this.players,
    required this.activePlayerIndex,
    required this.dealerIndex,
    required this.roundNumber,
    required this.gameTurn,
    required this.trumpStart,
    required this.trump,
    this.partnerCard,
    required this.winningBid,
    this.bidderIndex,
    this.trickWinnerIndex,
    required this.message,
    this.soundEnabled = true,
    this.isMultiplayer = false,
    this.isTrainingMode = false,
  });

  GameState copyWith({
    GamePhase? phase,
    List<PlayerModel>? players,
    int? activePlayerIndex,
    int? dealerIndex,
    int? roundNumber,
    int? gameTurn,
    String? trumpStart,
    String? trump,
    Nullable<CardModel?>? partnerCard,
    int? winningBid,
    Nullable<int?>? bidderIndex,
    Nullable<int?>? trickWinnerIndex,
    String? message,
    bool? soundEnabled,
    bool? isMultiplayer,
    bool? isTrainingMode,
  }) {
    return GameState(
      phase: phase ?? this.phase,
      players: players ?? this.players,
      activePlayerIndex: activePlayerIndex ?? this.activePlayerIndex,
      dealerIndex: dealerIndex ?? this.dealerIndex,
      roundNumber: roundNumber ?? this.roundNumber,
      gameTurn: gameTurn ?? this.gameTurn,
      trumpStart: trumpStart ?? this.trumpStart,
      trump: trump ?? this.trump,
      partnerCard: partnerCard != null ? partnerCard.value : this.partnerCard,
      winningBid: winningBid ?? this.winningBid,
      bidderIndex: bidderIndex != null ? bidderIndex.value : this.bidderIndex,
      trickWinnerIndex: trickWinnerIndex != null ? trickWinnerIndex.value : this.trickWinnerIndex,
      message: message ?? this.message,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      isMultiplayer: isMultiplayer ?? this.isMultiplayer,
      isTrainingMode: isTrainingMode ?? this.isTrainingMode,
    );
  }

  // Helper to fetch the current trick cards in order of players (0..3)
  List<CardModel?> get currentTrickCards => players.map((p) => p.playedCard).toList();
}
