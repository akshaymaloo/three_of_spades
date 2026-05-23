import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/card_model.dart';

/// Translates the hardcoded game status log messages dynamically based on context localizations.
String getLocalizedGameMessage(BuildContext context, String message) {
  final l10n = AppLocalizations.of(context);
  if (l10n == null) return message;

  // 1. Welcome message
  if (message == 'Welcome to Three of Spades!') {
    return l10n.welcomeMessage;
  }
  // 2. Mode selection
  if (message == 'Select a mode to play') {
    return l10n.selectModePlay;
  }
  // 3. Dealing cards
  if (message == 'Dealing cards...') {
    return l10n.dealingCards;
  }
  // 4. Redealing
  if (message == 'All players passed. Redealing...') {
    return l10n.allPassedRedealing;
  }
  // 5. Forced bid 175
  // Pattern: "(.+) is forced to bid 175."
  final forcedBidReg = RegExp(r'^(.+) is forced to bid 175\.$');
  if (forcedBidReg.hasMatch(message)) {
    final name = forcedBidReg.firstMatch(message)!.group(1)!;
    final displayName = _translatePlayerName(context, name);
    return l10n.forcedBid175(displayName);
  }
  
  // 6. Player bid
  // Pattern: "(.+) bid (\d+) points."
  final bidReg = RegExp(r'^(.+) bid (\d+) points\.$');
  if (bidReg.hasMatch(message)) {
    final match = bidReg.firstMatch(message)!;
    final name = match.group(1)!;
    final amount = int.parse(match.group(2)!);
    final displayName = _translatePlayerName(context, name);
    return l10n.playerBidMessage(displayName, amount);
  }

  // 7. Player passed
  // Pattern: "(.+) passed."
  final passReg = RegExp(r'^(.+) passed\.$');
  if (passReg.hasMatch(message)) {
    final name = passReg.firstMatch(message)!.group(1)!;
    final displayName = _translatePlayerName(context, name);
    return l10n.playerPassedMessage(displayName);
  }

  // 8. Won the bid
  // Pattern: "(.+) won the bid with (\d+)! Declaring Trump & Partner..."
  final wonBidReg = RegExp(r'^(.+) won the bid with (\d+)! Declaring Trump & Partner\.\.\.$');
  if (wonBidReg.hasMatch(message)) {
    final match = wonBidReg.firstMatch(message)!;
    final name = match.group(1)!;
    final bid = int.parse(match.group(2)!);
    final displayName = _translatePlayerName(context, name);
    return l10n.wonBidDeclaring(displayName, bid);
  }

  // 9. All passed before you
  if (message == 'All players passed before you. You must bid at least 175 or Pass.') {
    return l10n.allPassedMustBid;
  }

  // 10. Turn to lead
  // Pattern: "(.+)'s turn to lead."
  final turnReg = RegExp(r"^(.+)'s turn to lead\.$");
  if (turnReg.hasMatch(message)) {
    final name = turnReg.firstMatch(message)!.group(1)!;
    final displayName = _translatePlayerName(context, name);
    return l10n.turnToLead(displayName);
  }

  // 11. Invalid follow suit
  // Pattern: "Invalid play! You must follow suit \((.+)s\)\."
  final followSuitReg = RegExp(r'^Invalid play! You must follow suit \((.+)s\)\.$');
  if (followSuitReg.hasMatch(message)) {
    final suitName = followSuitReg.firstMatch(message)!.group(1)!; // e.g. "Spade"
    final suitChar = _getSuitCharFromName(suitName);
    final localizedSuit = CardModel.getLocalizedSuitNamePlural(context, suitChar);
    return l10n.invalidFollowSuit(localizedSuit);
  }

  // 12. Wins the trick
  // Pattern: "(.+) wins the trick with (.+) \(\+(\d+) pts\)!"
  final winsTrickReg = RegExp(r'^(.+) wins the trick with (.+) \(\+(\d+) pts\)!$');
  if (winsTrickReg.hasMatch(message)) {
    final match = winsTrickReg.firstMatch(message)!;
    final name = match.group(1)!;
    final cardName = match.group(2)!; // e.g. "3 of Spades"
    final points = int.parse(match.group(3)!);
    final displayName = _translatePlayerName(context, name);
    final localizedCard = _translateCardName(context, cardName);
    return l10n.winsTrick(displayName, localizedCard, points);
  }

  // 13. Trump partner declaration
  // Pattern: "Trump is (.+)s\. Partner Card is (.+)\. (.+) leads\."
  final trumpDeclReg = RegExp(r'^Trump is (.+)s\. Partner Card is (.+)\. (.+) leads\.$');
  if (trumpDeclReg.hasMatch(message)) {
    final match = trumpDeclReg.firstMatch(message)!;
    final trumpSuitName = match.group(1)!; // e.g. "Spade"
    final partnerCardName = match.group(2)!; // e.g. "Ace of Spades"
    final playerName = match.group(3)!;
    
    final trumpSuitChar = _getSuitCharFromName(trumpSuitName);
    final localizedTrump = CardModel.getLocalizedSuitNamePlural(context, trumpSuitChar);
    final localizedCard = _translateCardName(context, partnerCardName);
    final displayName = _translatePlayerName(context, playerName);

    return l10n.trumpPartnerDeclaration(localizedTrump, localizedCard, displayName);
  }

  // 14. Game Over summary
  // Pattern: "Game Over! Bidder was (.+), Partner was (.+)\. (.*)"
  final gameOverReg = RegExp(r'^Game Over! Bidder was (.+), Partner was (.+)\. (.*)$');
  if (gameOverReg.hasMatch(message)) {
    final match = gameOverReg.firstMatch(message)!;
    final bidderName = match.group(1)!;
    final partnerName = match.group(2)!;
    final resultMsg = match.group(3)!;

    final displayBidder = _translatePlayerName(context, bidderName);
    final displayPartner = partnerName == 'themselves' 
        ? (l10n.themselves)
        : _translatePlayerName(context, partnerName);

    // Parse resultMsg
    String displayResult = resultMsg;
    // Pattern: "Bidder & Partner won! Got (\d+) / (\d+) points."
    final bidderWonReg = RegExp(r'^Bidder & Partner won! Got (\d+) / (\d+) points\.$');
    final defendersWonReg = RegExp(r'^Defenders won! Bidder & Partner only got (\d+) / (\d+) points\.$');
    
    if (bidderWonReg.hasMatch(resultMsg)) {
      final rm = bidderWonReg.firstMatch(resultMsg)!;
      final got = int.parse(rm.group(1)!);
      final bid = int.parse(rm.group(2)!);
      displayResult = l10n.bidderPartnerWon(got, bid);
    } else if (defendersWonReg.hasMatch(resultMsg)) {
      final rm = defendersWonReg.firstMatch(resultMsg)!;
      final got = int.parse(rm.group(1)!);
      final bid = int.parse(rm.group(2)!);
      displayResult = l10n.defendersWon(got, bid);
    }

    return l10n.gameOverSummary(displayBidder, displayPartner, displayResult);
  }

  return message;
}

String _translatePlayerName(BuildContext context, String name) {
  if (name == 'You') {
    return AppLocalizations.of(context)?.youIdentity ?? 'You';
  }
  final isHi = Localizations.localeOf(context).languageCode == 'hi';
  if (isHi && name.startsWith('Bot ')) {
    return name.replaceFirst('Bot ', 'बॉट ');
  }
  return name;
}

String _getSuitCharFromName(String suitName) {
  switch (suitName.toLowerCase()) {
    case 'spade':
    case 'spades':
      return 'S';
    case 'heart':
    case 'hearts':
      return 'H';
    case 'club':
    case 'clubs':
      return 'C';
    case 'diamond':
    case 'diamonds':
      return 'D';
    default:
      return 'S';
  }
}

String _translateCardName(BuildContext context, String cardName) {
  final l10n = AppLocalizations.of(context);
  if (l10n == null) return cardName;

  final cardReg = RegExp(r'^(.+) of (.+)s$');
  if (cardReg.hasMatch(cardName)) {
    final match = cardReg.firstMatch(cardName)!;
    final rankName = match.group(1)!;
    final suitName = match.group(2)!;
    final suitChar = _getSuitCharFromName(suitName);

    String localizedRank = rankName;
    switch (rankName) {
      case 'Jack':
        localizedRank = l10n.jack;
        break;
      case 'Queen':
        localizedRank = l10n.queen;
        break;
      case 'King':
        localizedRank = l10n.king;
        break;
      case 'Ace':
        localizedRank = l10n.ace;
        break;
    }

    final isHi = Localizations.localeOf(context).languageCode == 'hi';
    if (isHi) {
      final localizedSuit = CardModel.getLocalizedSuitName(context, suitChar);
      return '$localizedSuit का $localizedRank';
    } else {
      final localizedSuitPlural = CardModel.getLocalizedSuitNamePlural(context, suitChar);
      return '$localizedRank of $localizedSuitPlural';
    }
  }
  return cardName;
}
