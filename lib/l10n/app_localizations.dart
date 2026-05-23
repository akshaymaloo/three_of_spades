import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// No description provided for @backgroundMusic.
  ///
  /// In en, this message translates to:
  /// **'Background Music'**
  String get backgroundMusic;

  /// No description provided for @onlineModeFirebase.
  ///
  /// In en, this message translates to:
  /// **'Online Mode (Firebase)'**
  String get onlineModeFirebase;

  /// No description provided for @onlineModeActive.
  ///
  /// In en, this message translates to:
  /// **'Active (Needs Firebase setup)'**
  String get onlineModeActive;

  /// No description provided for @onlineModeOffline.
  ///
  /// In en, this message translates to:
  /// **'Simulation / Offline Only'**
  String get onlineModeOffline;

  /// No description provided for @switchedOnlineMode.
  ///
  /// In en, this message translates to:
  /// **'Switched to Online Mode! Needs Firebase config.'**
  String get switchedOnlineMode;

  /// No description provided for @switchedOfflineMode.
  ///
  /// In en, this message translates to:
  /// **'Switched to Simulation Mode (Offline/Mock).'**
  String get switchedOfflineMode;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @pushNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get room invites and updates'**
  String get pushNotificationsSubtitle;

  /// No description provided for @resetStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Stats?'**
  String get resetStatsTitle;

  /// No description provided for @resetStatsBody.
  ///
  /// In en, this message translates to:
  /// **'This will reset your coins back to 5,000 and wipe out your win history. This action is irreversible.'**
  String get resetStatsBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'RESET'**
  String get reset;

  /// No description provided for @resetGuestStats.
  ///
  /// In en, this message translates to:
  /// **'RESET GUEST STATS'**
  String get resetGuestStats;

  /// No description provided for @editNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Name'**
  String get editNameTitle;

  /// No description provided for @editNameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your alias:'**
  String get editNameSubtitle;

  /// No description provided for @alias.
  ///
  /// In en, this message translates to:
  /// **'Alias'**
  String get alias;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get save;

  /// No description provided for @coins.
  ///
  /// In en, this message translates to:
  /// **'COINS'**
  String get coins;

  /// No description provided for @earnedCoins.
  ///
  /// In en, this message translates to:
  /// **'Earned {amount} coins!'**
  String earnedCoins(int amount);

  /// No description provided for @adFailed.
  ///
  /// In en, this message translates to:
  /// **'Ad failed or skipped'**
  String get adFailed;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'STATISTICS'**
  String get statistics;

  /// No description provided for @played.
  ///
  /// In en, this message translates to:
  /// **'Played'**
  String get played;

  /// No description provided for @won.
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get won;

  /// No description provided for @winRate.
  ///
  /// In en, this message translates to:
  /// **'Win Rate'**
  String get winRate;

  /// No description provided for @bestBid.
  ///
  /// In en, this message translates to:
  /// **'Best Bid'**
  String get bestBid;

  /// No description provided for @offlinePlay.
  ///
  /// In en, this message translates to:
  /// **'OFFLINE PLAY'**
  String get offlinePlay;

  /// No description provided for @playVsIntelligentBots.
  ///
  /// In en, this message translates to:
  /// **'Play vs Intelligent Bots'**
  String get playVsIntelligentBots;

  /// No description provided for @practiceBiddingDesc.
  ///
  /// In en, this message translates to:
  /// **'Practice your bidding strategies and trick estimation with zero network wait times.'**
  String get practiceBiddingDesc;

  /// No description provided for @onlinePlay.
  ///
  /// In en, this message translates to:
  /// **'ONLINE PLAY'**
  String get onlinePlay;

  /// No description provided for @privateRoom.
  ///
  /// In en, this message translates to:
  /// **'PRIVATE ROOM'**
  String get privateRoom;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'LEADERBOARD'**
  String get leaderboard;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get live;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'OFFLINE'**
  String get offline;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'STATS'**
  String get stats;

  /// No description provided for @enableOnlineToPlay.
  ///
  /// In en, this message translates to:
  /// **'Enable Online Mode in Settings to play online.'**
  String get enableOnlineToPlay;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @threeOfSpades.
  ///
  /// In en, this message translates to:
  /// **'Three of Spades'**
  String get threeOfSpades;

  /// No description provided for @classicFourPlayerGame.
  ///
  /// In en, this message translates to:
  /// **'Classic 4-Player Card Game'**
  String get classicFourPlayerGame;

  /// No description provided for @playOffline.
  ///
  /// In en, this message translates to:
  /// **'PLAY OFFLINE'**
  String get playOffline;

  /// No description provided for @signInAsGuest.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN AS GUEST'**
  String get signInAsGuest;

  /// No description provided for @signInWithFacebook.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN WITH FACEBOOK'**
  String get signInWithFacebook;

  /// No description provided for @signInGlobalMatchmaking.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access global matchmaking'**
  String get signInGlobalMatchmaking;

  /// No description provided for @enterAsGuestCoins.
  ///
  /// In en, this message translates to:
  /// **'Enter as Guest and get 5,000 free coins'**
  String get enterAsGuestCoins;

  /// No description provided for @onlineMode.
  ///
  /// In en, this message translates to:
  /// **'Online Mode'**
  String get onlineMode;

  /// No description provided for @simulationMode.
  ///
  /// In en, this message translates to:
  /// **'Simulation Mode'**
  String get simulationMode;

  /// No description provided for @howToPlay.
  ///
  /// In en, this message translates to:
  /// **'HOW TO PLAY'**
  String get howToPlay;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'SKIP'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get next;

  /// No description provided for @letsPlay.
  ///
  /// In en, this message translates to:
  /// **'LET\'S PLAY!'**
  String get letsPlay;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Three of Spades'**
  String get welcomeTitle;

  /// No description provided for @welcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Also known as Kaali Ki Teeggi, this is a strategic trick-taking card game popular in South Asia. In this modernized cyberpunk version, you play against smart bots or online players in a battle of bidding, declarations, and tactical play.'**
  String get welcomeDesc;

  /// No description provided for @objectiveTitle.
  ///
  /// In en, this message translates to:
  /// **'The Objective & Bidding'**
  String get objectiveTitle;

  /// No description provided for @objectiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Players bid points (from 175 to 350) based on their hand strength. The highest bidder wins the bid and tries to make that many points. Bids can only be placed or passed, and bidding progresses in increments of 5.'**
  String get objectiveDesc;

  /// No description provided for @minBidLabel.
  ///
  /// In en, this message translates to:
  /// **'Min Bid: 175'**
  String get minBidLabel;

  /// No description provided for @maxBidLabel.
  ///
  /// In en, this message translates to:
  /// **'Max Bid: 350'**
  String get maxBidLabel;

  /// No description provided for @scoringTitle.
  ///
  /// In en, this message translates to:
  /// **'Scoring & Point Cards'**
  String get scoringTitle;

  /// No description provided for @scoringDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlike standard card games, only specific cards carry points. Winning tricks containing these cards earns points:'**
  String get scoringDesc;

  /// No description provided for @totalPointsLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Points: 350'**
  String get totalPointsLabel;

  /// No description provided for @scoringTeamDesc.
  ///
  /// In en, this message translates to:
  /// **'The bidder + partner team must win tricks containing point cards equal to or greater than their bid to win!'**
  String get scoringTeamDesc;

  /// No description provided for @gameplayFlowTitle.
  ///
  /// In en, this message translates to:
  /// **'Gameplay Flow'**
  String get gameplayFlowTitle;

  /// No description provided for @flowStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Bidding'**
  String get flowStep1Title;

  /// No description provided for @flowStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'Players bid points'**
  String get flowStep1Desc;

  /// No description provided for @flowStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Declaration'**
  String get flowStep2Title;

  /// No description provided for @flowStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Bidder picks Trump & Partner card'**
  String get flowStep2Desc;

  /// No description provided for @flowStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Trick Play'**
  String get flowStep3Title;

  /// No description provided for @flowStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'Follow suits to win tricks'**
  String get flowStep3Desc;

  /// No description provided for @flowStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Scoring'**
  String get flowStep4Title;

  /// No description provided for @flowStep4Desc.
  ///
  /// In en, this message translates to:
  /// **'Sum points from tricks won'**
  String get flowStep4Desc;

  /// No description provided for @tipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tips & Rules'**
  String get tipsTitle;

  /// No description provided for @tip1.
  ///
  /// In en, this message translates to:
  /// **'You MUST follow the suit led if you have it in your hand.'**
  String get tip1;

  /// No description provided for @tip2.
  ///
  /// In en, this message translates to:
  /// **'If you don\'t have the led suit, you can play any card, including a Trump to win the trick.'**
  String get tip2;

  /// No description provided for @tip3.
  ///
  /// In en, this message translates to:
  /// **'The partner is secret! Only when the declared Partner card is played is the partner\'s identity revealed.'**
  String get tip3;

  /// No description provided for @matchmaking.
  ///
  /// In en, this message translates to:
  /// **'MATCHMAKING'**
  String get matchmaking;

  /// No description provided for @matchFound.
  ///
  /// In en, this message translates to:
  /// **'MATCH FOUND!'**
  String get matchFound;

  /// No description provided for @cancelMatch.
  ///
  /// In en, this message translates to:
  /// **'CANCEL MATCH'**
  String get cancelMatch;

  /// No description provided for @searchingPlayers.
  ///
  /// In en, this message translates to:
  /// **'Searching for players... (Timer: {seconds}s)'**
  String searchingPlayers(int seconds);

  /// No description provided for @startingGameIn.
  ///
  /// In en, this message translates to:
  /// **'Starting game in {seconds} seconds...'**
  String startingGameIn(int seconds);

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// No description provided for @privateLobby.
  ///
  /// In en, this message translates to:
  /// **'PRIVATE LOBBY'**
  String get privateLobby;

  /// No description provided for @createRoom.
  ///
  /// In en, this message translates to:
  /// **'CREATE ROOM'**
  String get createRoom;

  /// No description provided for @joinRoom.
  ///
  /// In en, this message translates to:
  /// **'JOIN ROOM'**
  String get joinRoom;

  /// No description provided for @createLobbyDesc.
  ///
  /// In en, this message translates to:
  /// **'Create a private lobby code. You can invite your friends to join this lobby or fill up seats with bots.'**
  String get createLobbyDesc;

  /// No description provided for @generateRoom.
  ///
  /// In en, this message translates to:
  /// **'GENERATE ROOM'**
  String get generateRoom;

  /// No description provided for @enterRoomCodeDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-character room code to join an active private lobby.'**
  String get enterRoomCodeDesc;

  /// No description provided for @roomCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'ROOM CODE: '**
  String get roomCodeLabel;

  /// No description provided for @joinLobby.
  ///
  /// In en, this message translates to:
  /// **'JOIN LOBBY'**
  String get joinLobby;

  /// No description provided for @seatedPlayers.
  ///
  /// In en, this message translates to:
  /// **'SEATED PLAYERS (Max 4)'**
  String get seatedPlayers;

  /// No description provided for @emptySeat.
  ///
  /// In en, this message translates to:
  /// **'Empty Seat'**
  String get emptySeat;

  /// No description provided for @host.
  ///
  /// In en, this message translates to:
  /// **'HOST'**
  String get host;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'READY'**
  String get ready;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'WAITING...'**
  String get waiting;

  /// No description provided for @addBots.
  ///
  /// In en, this message translates to:
  /// **'ADD BOTS'**
  String get addBots;

  /// No description provided for @startMatch.
  ///
  /// In en, this message translates to:
  /// **'START MATCH'**
  String get startMatch;

  /// No description provided for @invalidRoomCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid room code.'**
  String get invalidRoomCode;

  /// No description provided for @leaderboards.
  ///
  /// In en, this message translates to:
  /// **'LEADERBOARDS'**
  String get leaderboards;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'DAILY'**
  String get daily;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'ALL-TIME'**
  String get allTime;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @player.
  ///
  /// In en, this message translates to:
  /// **'PLAYER'**
  String get player;

  /// No description provided for @gamesWon.
  ///
  /// In en, this message translates to:
  /// **'GAMES WON'**
  String get gamesWon;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'YOU'**
  String get you;

  /// No description provided for @noEntries.
  ///
  /// In en, this message translates to:
  /// **'No leaderboard entries yet.'**
  String get noEntries;

  /// No description provided for @failedToLoadLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Failed to load leaderboard: {error}'**
  String failedToLoadLeaderboard(String error);

  /// No description provided for @dailyReward.
  ///
  /// In en, this message translates to:
  /// **'DAILY REWARD'**
  String get dailyReward;

  /// No description provided for @dayNumber.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String dayNumber(int day);

  /// No description provided for @alreadyClaimed.
  ///
  /// In en, this message translates to:
  /// **'Already Claimed ✓'**
  String get alreadyClaimed;

  /// No description provided for @claimCoins.
  ///
  /// In en, this message translates to:
  /// **'Claim {amount} Coins!'**
  String claimCoins(int amount);

  /// No description provided for @claimedDailyReward.
  ///
  /// In en, this message translates to:
  /// **'🎁 Claimed {amount} daily reward coins!'**
  String claimedDailyReward(int amount);

  /// No description provided for @landscapeRequired.
  ///
  /// In en, this message translates to:
  /// **'Landscape Mode Required'**
  String get landscapeRequired;

  /// No description provided for @rotateDeviceDesc.
  ///
  /// In en, this message translates to:
  /// **'Please rotate your device or widen your browser window to play.'**
  String get rotateDeviceDesc;

  /// No description provided for @biddingTitle.
  ///
  /// In en, this message translates to:
  /// **'PLACE YOUR BID'**
  String get biddingTitle;

  /// No description provided for @biddingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Current Bid: {bid}'**
  String biddingSubtitle(int bid);

  /// No description provided for @pass.
  ///
  /// In en, this message translates to:
  /// **'PASS'**
  String get pass;

  /// No description provided for @bidButton.
  ///
  /// In en, this message translates to:
  /// **'BID {bid}'**
  String bidButton(int bid);

  /// No description provided for @declareTrumpTitle.
  ///
  /// In en, this message translates to:
  /// **'DECLARE TRUMP SUIT'**
  String get declareTrumpTitle;

  /// No description provided for @declarePartnerTitle.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE PARTNER CARD'**
  String get declarePartnerTitle;

  /// No description provided for @declareSubmit.
  ///
  /// In en, this message translates to:
  /// **'DECLARE & START PLAYING'**
  String get declareSubmit;

  /// No description provided for @victory.
  ///
  /// In en, this message translates to:
  /// **'VICTORY'**
  String get victory;

  /// No description provided for @defeat.
  ///
  /// In en, this message translates to:
  /// **'DEFEAT'**
  String get defeat;

  /// No description provided for @bidderLabel.
  ///
  /// In en, this message translates to:
  /// **'Bidder: {name} ({identity})'**
  String bidderLabel(String name, String identity);

  /// No description provided for @partnerLabel.
  ///
  /// In en, this message translates to:
  /// **'Partner: {name} ({identity})'**
  String partnerLabel(String name, String identity);

  /// No description provided for @youIdentity.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youIdentity;

  /// No description provided for @botIdentity.
  ///
  /// In en, this message translates to:
  /// **'Bot'**
  String get botIdentity;

  /// No description provided for @themselves.
  ///
  /// In en, this message translates to:
  /// **'Themselves'**
  String get themselves;

  /// No description provided for @bidValue.
  ///
  /// In en, this message translates to:
  /// **'BID VALUE'**
  String get bidValue;

  /// No description provided for @collected.
  ///
  /// In en, this message translates to:
  /// **'COLLECTED'**
  String get collected;

  /// No description provided for @coinRewardsPenalties.
  ///
  /// In en, this message translates to:
  /// **'COIN REWARDS / PENALTIES:'**
  String get coinRewardsPenalties;

  /// No description provided for @quit.
  ///
  /// In en, this message translates to:
  /// **'QUIT'**
  String get quit;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'PLAY AGAIN'**
  String get playAgain;

  /// No description provided for @creditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get creditsTitle;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @finishMatch.
  ///
  /// In en, this message translates to:
  /// **'Finish Match'**
  String get finishMatch;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @trainingMode.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get trainingMode;

  /// No description provided for @gameChat.
  ///
  /// In en, this message translates to:
  /// **'GAME CHAT'**
  String get gameChat;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type message...'**
  String get typeMessage;

  /// No description provided for @trumpLabel.
  ///
  /// In en, this message translates to:
  /// **'TRUMP: '**
  String get trumpLabel;

  /// No description provided for @partnerLabelUpper.
  ///
  /// In en, this message translates to:
  /// **'PARTNER: '**
  String get partnerLabelUpper;

  /// No description provided for @revealed.
  ///
  /// In en, this message translates to:
  /// **'(REVEALED)'**
  String get revealed;

  /// No description provided for @hidden.
  ///
  /// In en, this message translates to:
  /// **'(HIDDEN)'**
  String get hidden;

  /// No description provided for @passed.
  ///
  /// In en, this message translates to:
  /// **'PASSED'**
  String get passed;

  /// No description provided for @bidLabel.
  ///
  /// In en, this message translates to:
  /// **'BID: {bid}'**
  String bidLabel(int bid);

  /// No description provided for @bidderLabelShort.
  ///
  /// In en, this message translates to:
  /// **'BIDDER ({bid})'**
  String bidderLabelShort(int bid);

  /// No description provided for @partnerLabelShort.
  ///
  /// In en, this message translates to:
  /// **'PARTNER'**
  String get partnerLabelShort;

  /// No description provided for @pointsLabel.
  ///
  /// In en, this message translates to:
  /// **'Pts: {points}'**
  String pointsLabel(int points);

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking '**
  String get thinking;

  /// No description provided for @noCards.
  ///
  /// In en, this message translates to:
  /// **'No Cards'**
  String get noCards;

  /// No description provided for @playCard.
  ///
  /// In en, this message translates to:
  /// **'PLAY CARD'**
  String get playCard;

  /// No description provided for @ptsUnit.
  ///
  /// In en, this message translates to:
  /// **'pts'**
  String get ptsUnit;

  /// No description provided for @suit.
  ///
  /// In en, this message translates to:
  /// **'Suit'**
  String get suit;

  /// No description provided for @holdWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: You hold this card! Select a card you do NOT hold.'**
  String get holdWarning;

  /// No description provided for @declareTitle.
  ///
  /// In en, this message translates to:
  /// **'DECLARE TRUMP & PARTNER'**
  String get declareTitle;

  /// No description provided for @selectTrump.
  ///
  /// In en, this message translates to:
  /// **'1. SELECT TRUMP SUIT'**
  String get selectTrump;

  /// No description provided for @nominatePartner.
  ///
  /// In en, this message translates to:
  /// **'2. NOMINATE PARTNER CARD'**
  String get nominatePartner;

  /// No description provided for @jack.
  ///
  /// In en, this message translates to:
  /// **'Jack'**
  String get jack;

  /// No description provided for @queen.
  ///
  /// In en, this message translates to:
  /// **'Queen'**
  String get queen;

  /// No description provided for @king.
  ///
  /// In en, this message translates to:
  /// **'King'**
  String get king;

  /// No description provided for @ace.
  ///
  /// In en, this message translates to:
  /// **'Ace'**
  String get ace;

  /// No description provided for @spade.
  ///
  /// In en, this message translates to:
  /// **'Spade'**
  String get spade;

  /// No description provided for @heart.
  ///
  /// In en, this message translates to:
  /// **'Heart'**
  String get heart;

  /// No description provided for @club.
  ///
  /// In en, this message translates to:
  /// **'Club'**
  String get club;

  /// No description provided for @diamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get diamond;

  /// No description provided for @spades.
  ///
  /// In en, this message translates to:
  /// **'Spades'**
  String get spades;

  /// No description provided for @hearts.
  ///
  /// In en, this message translates to:
  /// **'Hearts'**
  String get hearts;

  /// No description provided for @clubs.
  ///
  /// In en, this message translates to:
  /// **'Clubs'**
  String get clubs;

  /// No description provided for @diamonds.
  ///
  /// In en, this message translates to:
  /// **'Diamonds'**
  String get diamonds;

  /// No description provided for @selectModePlay.
  ///
  /// In en, this message translates to:
  /// **'Select a mode to play'**
  String get selectModePlay;

  /// No description provided for @dealingCards.
  ///
  /// In en, this message translates to:
  /// **'Dealing cards...'**
  String get dealingCards;

  /// No description provided for @allPassedRedealing.
  ///
  /// In en, this message translates to:
  /// **'All players passed. Redealing...'**
  String get allPassedRedealing;

  /// No description provided for @allPassedMustBid.
  ///
  /// In en, this message translates to:
  /// **'All players passed before you. You must bid at least 175 or Pass.'**
  String get allPassedMustBid;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Three of Spades!'**
  String get welcomeMessage;

  /// No description provided for @forcedBid175.
  ///
  /// In en, this message translates to:
  /// **'{name} is forced to bid 175.'**
  String forcedBid175(String name);

  /// No description provided for @playerBidMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} bid {amount} points.'**
  String playerBidMessage(String name, int amount);

  /// No description provided for @playerPassedMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} passed.'**
  String playerPassedMessage(String name);

  /// No description provided for @wonBidDeclaring.
  ///
  /// In en, this message translates to:
  /// **'{name} won the bid with {bid}! Declaring Trump & Partner...'**
  String wonBidDeclaring(String name, int bid);

  /// No description provided for @turnToLead.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s turn to lead.'**
  String turnToLead(String name);

  /// No description provided for @invalidFollowSuit.
  ///
  /// In en, this message translates to:
  /// **'Invalid play! You must follow suit ({suit}).'**
  String invalidFollowSuit(String suit);

  /// No description provided for @winsTrick.
  ///
  /// In en, this message translates to:
  /// **'{name} wins the trick with {card} (+{points} pts)!'**
  String winsTrick(String name, String card, int points);

  /// No description provided for @trumpPartnerDeclaration.
  ///
  /// In en, this message translates to:
  /// **'Trump is {trump}. Partner Card is {card}. {name} leads.'**
  String trumpPartnerDeclaration(String trump, String card, String name);

  /// No description provided for @gameOverSummary.
  ///
  /// In en, this message translates to:
  /// **'Game Over! Bidder was {bidder}, Partner was {partner}. {result}'**
  String gameOverSummary(String bidder, String partner, String result);

  /// No description provided for @bidderPartnerWon.
  ///
  /// In en, this message translates to:
  /// **'Bidder & Partner won! Got {got} / {bid} points.'**
  String bidderPartnerWon(int got, int bid);

  /// No description provided for @defendersWon.
  ///
  /// In en, this message translates to:
  /// **'Defenders won! Bidder & Partner only got {got} / {bid} points.'**
  String defendersWon(int got, int bid);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
