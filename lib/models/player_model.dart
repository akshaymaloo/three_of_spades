import 'card_model.dart';

class PlayerModel {
  final int id;
  final String name;
  final String avatarPath;
  final int coins;
  final List<CardModel> hand;
  final bool isHuman;
  final int? currentBid;
  final bool hasPassed;
  final CardModel? playedCard;
  final int roundPoints;
  final bool isBidder;
  final bool isPartner;
  final bool isPartnerRevealed;

  const PlayerModel({
    required this.id,
    required this.name,
    required this.avatarPath,
    required this.coins,
    this.hand = const [],
    required this.isHuman,
    this.currentBid,
    this.hasPassed = false,
    this.playedCard,
    this.roundPoints = 0,
    this.isBidder = false,
    this.isPartner = false,
    this.isPartnerRevealed = false,
  });

  PlayerModel copyWith({
    int? id,
    String? name,
    String? avatarPath,
    int? coins,
    List<CardModel>? hand,
    bool? isHuman,
    int? currentBid,
    bool? hasPassed,
    CardModel? playedCard,
    int? roundPoints,
    bool? isBidder,
    bool? isPartner,
    bool? isPartnerRevealed,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
      coins: coins ?? this.coins,
      hand: hand ?? this.hand,
      isHuman: isHuman ?? this.isHuman,
      currentBid: currentBid ?? this.currentBid,
      hasPassed: hasPassed ?? this.hasPassed,
      playedCard: playedCard, // Allows setting to null explicitly if not passed
      roundPoints: roundPoints ?? this.roundPoints,
      isBidder: isBidder ?? this.isBidder,
      isPartner: isPartner ?? this.isPartner,
      isPartnerRevealed: isPartnerRevealed ?? this.isPartnerRevealed,
    );
  }

  // Set played card (allows explicitly passing null to clear)
  PlayerModel clearPlayedCard() {
    return PlayerModel(
      id: id,
      name: name,
      avatarPath: avatarPath,
      coins: coins,
      hand: hand,
      isHuman: isHuman,
      currentBid: currentBid,
      hasPassed: hasPassed,
      playedCard: null,
      roundPoints: roundPoints,
      isBidder: isBidder,
      isPartner: isPartner,
      isPartnerRevealed: isPartnerRevealed,
    );
  }
}
