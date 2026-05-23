import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

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

  // Full name representation of rank (e.g. "Jack", "Queen")
  String get rankName {
    if (rank <= 10) return rank.toString();
    switch (rank) {
      case 11:
        return 'Jack';
      case 12:
        return 'Queen';
      case 13:
        return 'King';
      case 14:
        return 'Ace';
      default:
        return '';
    }
  }

  // Get full readable name (e.g., "Ace of Spades")
  String get name {
    final suitName = getSuitName(suit);
    final rankText = rankName;
    return '$rankText of ${suitName}s';
  }

  String getLocalizedName(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return name;

    final String rankText;
    if (rank <= 10) {
      rankText = rank.toString();
    } else {
      switch (rank) {
        case 11:
          rankText = localizations.jack;
          break;
        case 12:
          rankText = localizations.queen;
          break;
        case 13:
          rankText = localizations.king;
          break;
        case 14:
          rankText = localizations.ace;
          break;
        default:
          rankText = '';
      }
    }

    final isHi = Localizations.localeOf(context).languageCode == 'hi';
    if (isHi) {
      final suitName = getLocalizedSuitName(context, suit);
      return '$suitName का $rankText';
    } else {
      final suitNamePlural = getLocalizedSuitNamePlural(context, suit);
      return '$rankText of $suitNamePlural';
    }
  }

  static String getLocalizedSuitName(BuildContext context, String suitChar) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return getSuitName(suitChar);
    switch (suitChar) {
      case 'S':
        return localizations.spade;
      case 'H':
        return localizations.heart;
      case 'C':
        return localizations.club;
      case 'D':
        return localizations.diamond;
      default:
        return 'Unknown';
    }
  }

  static String getLocalizedSuitNamePlural(BuildContext context, String suitChar) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return '${getSuitName(suitChar)}s';
    switch (suitChar) {
      case 'S':
        return localizations.spades;
      case 'H':
        return localizations.hearts;
      case 'C':
        return localizations.clubs;
      case 'D':
        return localizations.diamonds;
      default:
        return 'Unknown';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardModel &&
          runtimeType == other.runtimeType &&
          suit == other.suit &&
          rank == other.rank;

  @override
  int get hashCode => suit.hashCode ^ rank.hashCode;

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
