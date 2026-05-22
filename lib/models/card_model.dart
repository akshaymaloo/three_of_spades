class CardModel {
  final int id;
  final String suit; // 'S', 'H', 'C', 'D'
  final int rank;    // 2..14 (where 11=J, 12=Q, 13=K, 14=A)
  final int points;
  final String assetPath;

  const CardModel({
    required this.id,
    required this.suit,
    required this.rank,
    required this.points,
    required this.assetPath,
  });

  // String representation of rank (e.g. "J", "K")
  String get rankLabel {
    if (rank <= 10) return rank.toString();
    switch (rank) {
      case 11:
        return 'J';
      case 12:
        return 'Q';
      case 13:
        return 'K';
      case 14:
        return 'A';
      default:
        return '';
    }
  }

  // Get full readable name (e.g., "Ace of Spades")
  String get name {
    final suitName = getSuitName(suit);
    final rankName = rankLabel;
    return '$rankName of ${suitName}s';
  }

  static String getSuitName(String suitChar) {
    switch (suitChar) {
      case 'S':
        return 'Spade';
      case 'H':
        return 'Heart';
      case 'C':
        return 'Club';
      case 'D':
        return 'Diamond';
      default:
        return 'Unknown';
    }
  }

  // Generate a standard sorted 52-card deck
  static List<CardModel> generateDeck() {
    final suits = ['S', 'H', 'C', 'D'];
    final List<CardModel> deck = [];
    int id = 0;

    for (var suit in suits) {
      for (int rank = 2; rank <= 14; rank++) {
        // Calculate points
        int points = 0;
        if (suit == 'S' && rank == 3) {
          points = 30; // Three of Spades is 30 points
        } else {
          switch (rank) {
            case 5:
              points = 5;
              break;
            case 10:
              points = 10;
              break;
            case 11:
            case 12:
            case 13:
              points = 15;
              break;
            case 14:
              points = 20;
              break;
          }
        }

        final lowerSuit = suit.toLowerCase();
        final assetPath = 'assets/cards/$lowerSuit$rank.svg';

        deck.add(CardModel(
          id: id++,
          suit: suit,
          rank: rank,
          points: points,
          assetPath: assetPath,
        ));
      }
    }
    return deck;
  }
}
