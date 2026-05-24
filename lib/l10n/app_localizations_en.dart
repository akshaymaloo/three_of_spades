// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get backgroundMusic => 'Background Music';

  @override
  String get onlineModeFirebase => 'Online Mode (Firebase)';

  @override
  String get onlineModeActive => 'Active (Needs Firebase setup)';

  @override
  String get onlineModeOffline => 'Simulation / Offline Only';

  @override
  String get switchedOnlineMode =>
      'Switched to Online Mode! Needs Firebase config.';

  @override
  String get switchedOfflineMode =>
      'Switched to Simulation Mode (Offline/Mock).';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get pushNotificationsSubtitle => 'Get room invites and updates';

  @override
  String get resetStatsTitle => 'Reset Stats?';

  @override
  String get resetStatsBody =>
      'This will reset your coins back to 5,000 and wipe out your win history. This action is irreversible.';

  @override
  String get cancel => 'CANCEL';

  @override
  String get reset => 'RESET';

  @override
  String get resetGuestStats => 'RESET GUEST STATS';

  @override
  String get editNameTitle => 'Edit Name';

  @override
  String get editNameSubtitle => 'Enter your alias:';

  @override
  String get alias => 'Alias';

  @override
  String get save => 'SAVE';

  @override
  String get coins => 'COINS';

  @override
  String earnedCoins(int amount) {
    return '🪙 Earned $amount coins!';
  }

  @override
  String get sevenPlayerMode => '7 Players\nEpic Mode';

  @override
  String get sevenPlayerModeBadge => '2 Decks · 7 Players';

  @override
  String get sevenPlayerModeDesc =>
      'Play against 6 bots with 104 cards and 2 partners!';

  @override
  String get adFailed => 'Ad failed or skipped';

  @override
  String get statistics => 'STATISTICS';

  @override
  String get played => 'Played';

  @override
  String get won => 'Won';

  @override
  String get winRate => 'Win Rate';

  @override
  String get bestBid => 'Best Bid';

  @override
  String get offlinePlay => 'OFFLINE PLAY';

  @override
  String get playVsIntelligentBots => 'Play vs Intelligent Bots';

  @override
  String get practiceBiddingDesc =>
      'Practice your bidding strategies and trick estimation with zero network wait times.';

  @override
  String get onlinePlay => 'ONLINE PLAY';

  @override
  String get privateRoom => 'PRIVATE ROOM';

  @override
  String get leaderboard => 'LEADERBOARD';

  @override
  String get live => 'LIVE';

  @override
  String get offline => 'OFFLINE';

  @override
  String get stats => 'STATS';

  @override
  String get enableOnlineToPlay =>
      'Enable Online Mode in Settings to play online.';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get hindi => 'Hindi';

  @override
  String get threeOfSpades => 'Three of Spades';

  @override
  String get classicFourPlayerGame => 'Classic 4-Player Card Game';

  @override
  String get playOffline => 'PLAY OFFLINE';

  @override
  String get signInAsGuest => 'SIGN IN AS GUEST';

  @override
  String get signInWithFacebook => 'SIGN IN WITH FACEBOOK';

  @override
  String get signInGlobalMatchmaking => 'Sign in to access global matchmaking';

  @override
  String get enterAsGuestCoins => 'Enter as Guest and get 5,000 free coins';

  @override
  String get onlineMode => 'Online Mode';

  @override
  String get simulationMode => 'Simulation Mode';

  @override
  String get howToPlay => 'HOW TO PLAY';

  @override
  String get skip => 'SKIP';

  @override
  String get next => 'NEXT';

  @override
  String get letsPlay => 'LET\'S PLAY!';

  @override
  String get welcomeTitle => 'Welcome to Three of Spades';

  @override
  String get welcomeDesc =>
      'Also known as Kaali Ki Teeggi, this is a strategic trick-taking card game popular in South Asia. In this modernized cyberpunk version, you play against smart bots or online players in a battle of bidding, declarations, and tactical play.';

  @override
  String get objectiveTitle => 'The Objective & Bidding';

  @override
  String get objectiveDesc =>
      'Players bid points (from 175 to 350) based on their hand strength. The highest bidder wins the bid and tries to make that many points. Bids can only be placed or passed, and bidding progresses in increments of 5.';

  @override
  String get minBidLabel => 'Min Bid: 175';

  @override
  String get maxBidLabel => 'Max Bid: 350';

  @override
  String get scoringTitle => 'Scoring & Point Cards';

  @override
  String get scoringDesc =>
      'Unlike standard card games, only specific cards carry points. Winning tricks containing these cards earns points:';

  @override
  String get totalPointsLabel => 'Total Points: 350';

  @override
  String get scoringTeamDesc =>
      'The bidder + partner team must win tricks containing point cards equal to or greater than their bid to win!';

  @override
  String get gameplayFlowTitle => 'Gameplay Flow';

  @override
  String get flowStep1Title => 'Bidding';

  @override
  String get flowStep1Desc => 'Players bid points';

  @override
  String get flowStep2Title => 'Declaration';

  @override
  String get flowStep2Desc => 'Bidder picks Trump & Partner card';

  @override
  String get flowStep3Title => 'Trick Play';

  @override
  String get flowStep3Desc => 'Follow suits to win tricks';

  @override
  String get flowStep4Title => 'Scoring';

  @override
  String get flowStep4Desc => 'Sum points from tricks won';

  @override
  String get tipsTitle => 'Tips & Rules';

  @override
  String get tip1 =>
      'You MUST follow the suit led if you have it in your hand.';

  @override
  String get tip2 =>
      'If you don\'t have the led suit, you can play any card, including a Trump to win the trick.';

  @override
  String get tip3 =>
      'The partner is secret! Only when the declared Partner card is played is the partner\'s identity revealed.';

  @override
  String get matchmaking => 'MATCHMAKING';

  @override
  String get matchFound => 'MATCH FOUND!';

  @override
  String get cancelMatch => 'CANCEL MATCH';

  @override
  String searchingPlayers(int seconds) {
    return 'Searching for players... (Timer: ${seconds}s)';
  }

  @override
  String startingGameIn(int seconds) {
    return 'Starting game in $seconds seconds...';
  }

  @override
  String get searching => 'Searching...';

  @override
  String get privateLobby => 'PRIVATE LOBBY';

  @override
  String get createRoom => 'CREATE ROOM';

  @override
  String get joinRoom => 'JOIN ROOM';

  @override
  String get createLobbyDesc =>
      'Create a private lobby code. You can invite your friends to join this lobby or fill up seats with bots.';

  @override
  String get generateRoom => 'GENERATE ROOM';

  @override
  String get enterRoomCodeDesc =>
      'Enter the 6-character room code to join an active private lobby.';

  @override
  String get roomCodeLabel => 'ROOM CODE: ';

  @override
  String get joinLobby => 'JOIN LOBBY';

  @override
  String get seatedPlayers => 'SEATED PLAYERS (Max 4)';

  @override
  String get emptySeat => 'Empty Seat';

  @override
  String get host => 'HOST';

  @override
  String get ready => 'READY';

  @override
  String get waiting => 'WAITING...';

  @override
  String get addBots => 'ADD BOTS';

  @override
  String get startMatch => 'START MATCH';

  @override
  String get invalidRoomCode => 'Please enter a valid room code.';

  @override
  String get leaderboards => 'LEADERBOARDS';

  @override
  String get daily => 'DAILY';

  @override
  String get allTime => 'ALL-TIME';

  @override
  String get rank => 'Rank';

  @override
  String get player => 'PLAYER';

  @override
  String get gamesWon => 'GAMES WON';

  @override
  String get you => 'YOU';

  @override
  String get noEntries => 'No leaderboard entries yet.';

  @override
  String failedToLoadLeaderboard(String error) {
    return 'Failed to load leaderboard: $error';
  }

  @override
  String get dailyReward => 'DAILY REWARD';

  @override
  String dayNumber(int day) {
    return 'Day $day';
  }

  @override
  String get alreadyClaimed => 'Already Claimed ✓';

  @override
  String claimCoins(int amount) {
    return 'Claim $amount Coins!';
  }

  @override
  String claimedDailyReward(int amount) {
    return '🎁 Claimed $amount daily reward coins!';
  }

  @override
  String get landscapeRequired => 'Landscape Mode Required';

  @override
  String get rotateDeviceDesc =>
      'Please rotate your device or widen your browser window to play.';

  @override
  String get biddingTitle => 'PLACE YOUR BID';

  @override
  String biddingSubtitle(int bid) {
    return 'Current Bid: $bid';
  }

  @override
  String get pass => 'PASS';

  @override
  String bidButton(int bid) {
    return 'BID $bid';
  }

  @override
  String get declareTrumpTitle => 'DECLARE TRUMP SUIT';

  @override
  String get declarePartnerTitle => 'CHOOSE PARTNER CARD';

  @override
  String get declareSubmit => 'DECLARE & START PLAYING';

  @override
  String get victory => 'VICTORY';

  @override
  String get defeat => 'DEFEAT';

  @override
  String bidderLabel(String name, String identity) {
    return 'Bidder: $name ($identity)';
  }

  @override
  String partnerLabel(String name, String identity) {
    return 'Partner: $name ($identity)';
  }

  @override
  String get youIdentity => 'You';

  @override
  String get botIdentity => 'Bot';

  @override
  String get themselves => 'Themselves';

  @override
  String get bidValue => 'BID VALUE';

  @override
  String get collected => 'COLLECTED';

  @override
  String get coinRewardsPenalties => 'COIN REWARDS / PENALTIES:';

  @override
  String get quit => 'QUIT';

  @override
  String get playAgain => 'PLAY AGAIN';

  @override
  String get creditsTitle => 'Credits';

  @override
  String get close => 'Close';

  @override
  String get finishMatch => 'Finish Match';

  @override
  String get continueButton => 'Continue';

  @override
  String get trainingMode => 'Training';

  @override
  String get gameChat => 'GAME CHAT';

  @override
  String get typeMessage => 'Type message...';

  @override
  String get trumpLabel => 'TRUMP: ';

  @override
  String get partnerLabelUpper => 'PARTNER: ';

  @override
  String get revealed => '(REVEALED)';

  @override
  String get hidden => '(HIDDEN)';

  @override
  String get passed => 'PASSED';

  @override
  String bidLabel(int bid) {
    return 'BID: $bid';
  }

  @override
  String bidderLabelShort(int bid) {
    return 'BIDDER ($bid)';
  }

  @override
  String get partnerLabelShort => 'PARTNER';

  @override
  String pointsLabel(int points) {
    return 'Pts: $points';
  }

  @override
  String get thinking => 'Thinking ';

  @override
  String get noCards => 'No Cards';

  @override
  String get playCard => 'PLAY CARD';

  @override
  String get ptsUnit => 'pts';

  @override
  String get suit => 'Suit';

  @override
  String get holdWarning =>
      'Warning: You hold this card! Select a card you do NOT hold.';

  @override
  String get declareTitle => 'DECLARE TRUMP & PARTNER';

  @override
  String get selectTrump => '1. SELECT TRUMP SUIT';

  @override
  String get nominatePartner => '2. NOMINATE PARTNER CARD';

  @override
  String get jack => 'Jack';

  @override
  String get queen => 'Queen';

  @override
  String get king => 'King';

  @override
  String get ace => 'Ace';

  @override
  String get spade => 'Spade';

  @override
  String get heart => 'Heart';

  @override
  String get club => 'Club';

  @override
  String get diamond => 'Diamond';

  @override
  String get spades => 'Spades';

  @override
  String get hearts => 'Hearts';

  @override
  String get clubs => 'Clubs';

  @override
  String get diamonds => 'Diamonds';

  @override
  String get selectModePlay => 'Select a mode to play';

  @override
  String get dealingCards => 'Dealing cards...';

  @override
  String get allPassedRedealing => 'All players passed. Redealing...';

  @override
  String get allPassedMustBid =>
      'All players passed before you. You must bid at least 175 or Pass.';

  @override
  String get welcomeMessage => 'Welcome to Three of Spades!';

  @override
  String forcedBid175(String name) {
    return '$name is forced to bid 175.';
  }

  @override
  String playerBidMessage(String name, int amount) {
    return '$name bid $amount points.';
  }

  @override
  String playerPassedMessage(String name) {
    return '$name passed.';
  }

  @override
  String wonBidDeclaring(String name, int bid) {
    return '$name won the bid with $bid! Declaring Trump & Partner...';
  }

  @override
  String turnToLead(String name) {
    return '$name\'s turn to lead.';
  }

  @override
  String invalidFollowSuit(String suit) {
    return 'Invalid play! You must follow suit ($suit).';
  }

  @override
  String winsTrick(String name, String card, int points) {
    return '$name wins the trick with $card (+$points pts)!';
  }

  @override
  String trumpPartnerDeclaration(String trump, String card, String name) {
    return 'Trump is $trump. Partner Card is $card. $name leads.';
  }

  @override
  String gameOverSummary(String bidder, String partner, String result) {
    return 'Game Over! Bidder was $bidder, Partner was $partner. $result';
  }

  @override
  String bidderPartnerWon(int got, int bid) {
    return 'Bidder & Partner won! Got $got / $bid points.';
  }

  @override
  String defendersWon(int got, int bid) {
    return 'Defenders won! Bidder & Partner only got $got / $bid points.';
  }
}
