// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get soundEffects => 'ध्वनि प्रभाव';

  @override
  String get backgroundMusic => 'पृष्ठभूमि संगीत';

  @override
  String get onlineModeFirebase => 'ऑनलाइन मोड (Firebase)';

  @override
  String get onlineModeActive => 'सक्रिय (Firebase सेटअप आवश्यक)';

  @override
  String get onlineModeOffline => 'सिमुलेशन / केवल ऑफ़लाइन';

  @override
  String get switchedOnlineMode =>
      'ऑनलाइन मोड में स्विच किया गया! Firebase कॉन्फ़िगरेशन आवश्यक है।';

  @override
  String get switchedOfflineMode =>
      'सिमुलेशन मोड (ऑफ़लाइन/मॉक) में स्विच किया गया।';

  @override
  String get pushNotifications => 'पुश सूचनाएं';

  @override
  String get pushNotificationsSubtitle =>
      'कमरे के निमंत्रण और अपडेट प्राप्त करें';

  @override
  String get resetStatsTitle => 'आँकड़े रीसेट करें?';

  @override
  String get resetStatsBody =>
      'यह आपके सिक्कों को 5,000 पर वापस कर देगा और आपके जीत के इतिहास को मिटा देगा। इस कार्रवाई को पूर्ववत नहीं किया जा सकता है।';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get reset => 'रीसेट';

  @override
  String get resetGuestStats => 'अतिथि आँकड़े रीसेट करें';

  @override
  String get editNameTitle => 'नाम संपादित करें';

  @override
  String get editNameSubtitle => 'अपना उपनाम दर्ज करें:';

  @override
  String get alias => 'उपनाम';

  @override
  String get save => 'सहेजें';

  @override
  String get coins => 'सिक्के';

  @override
  String earnedCoins(int amount) {
    return '🪙 $amount सिक्के मिले!';
  }

  @override
  String get sevenPlayerMode => '7 खिलाड़ी\nमहाकाव्य मोड';

  @override
  String get sevenPlayerModeBadge => '2 डेक · 7 खिलाड़ी';

  @override
  String get sevenPlayerModeDesc =>
      '104 कार्ड और 2 भागीदारों के साथ 6 बॉट्स के खिलाफ खेलें!';

  @override
  String get adFailed => 'विज्ञापन विफल रहा या छोड़ दिया गया';

  @override
  String get statistics => 'आँकड़े';

  @override
  String get played => 'खेले गए';

  @override
  String get won => 'जीते';

  @override
  String get winRate => 'जीतने की दर';

  @override
  String get bestBid => 'सर्वश्रेष्ठ बोली';

  @override
  String get offlinePlay => 'ऑफ़लाइन खेलें';

  @override
  String get playVsIntelligentBots => 'बुद्धिमान बॉट्स के खिलाफ खेलें';

  @override
  String get practiceBiddingDesc =>
      'शून्य नेटवर्क प्रतीक्षा समय के साथ अपनी बोली लगाने की रणनीतियों और चाल के अनुमान का अभ्यास करें।';

  @override
  String get onlinePlay => 'ऑनलाइन खेलें';

  @override
  String get privateRoom => 'निजी कमरा';

  @override
  String get leaderboard => 'लीडरबोर्ड';

  @override
  String get live => 'लाइव';

  @override
  String get offline => 'ऑफ़लाइन';

  @override
  String get stats => 'आँकड़े';

  @override
  String get enableOnlineToPlay =>
      'ऑनलाइन खेलने के लिए सेटिंग्स में ऑनलाइन मोड सक्षम करें।';

  @override
  String get language => 'भाषा';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get threeOfSpades => 'थ्री ऑफ स्पेड्स';

  @override
  String get classicFourPlayerGame => 'क्लासिक 4-खिलाड़ियों का कार्ड गेम';

  @override
  String get playOffline => 'ऑफ़लाइन खेलें';

  @override
  String get signInAsGuest => 'अतिथि के रूप में साइन इन करें';

  @override
  String get signInWithFacebook => 'फेसबुक के साथ साइन इन करें';

  @override
  String get signInGlobalMatchmaking =>
      'वैश्विक मैचमेकिंग तक पहुँचने के लिए साइन इन करें';

  @override
  String get enterAsGuestCoins =>
      'अतिथि के रूप में प्रवेश करें और 5,000 मुफ्त सिक्के प्राप्त करें';

  @override
  String get onlineMode => 'ऑनलाइन मोड';

  @override
  String get simulationMode => 'सिमुलेशन मोड';

  @override
  String get howToPlay => 'कैसे खेलें';

  @override
  String get skip => 'छोड़ें';

  @override
  String get next => 'अगला';

  @override
  String get letsPlay => 'चलो खेलते हैं!';

  @override
  String get welcomeTitle => 'थ्री ऑफ स्पेड्स में आपका स्वागत है';

  @override
  String get welcomeDesc =>
      'काली की तिग्गी के रूप में भी जाना जाने वाला, यह दक्षिण एशिया में लोकप्रिय एक रणनीतिक कार्ड गेम है। इस आधुनिक संस्करण में, आप बुद्धिमान बॉट्स या ऑनलाइन खिलाड़ियों के खिलाफ बोली लगाने, घोषणाओं और रणनीतिक खेल की लड़ाई में खेलते हैं।';

  @override
  String get objectiveTitle => 'उद्देश्य और बोली';

  @override
  String get objectiveDesc =>
      'खिलाड़ी अपने हाथ की ताकत के आधार पर अंकों (175 से 350 तक) की बोली लगाते हैं। उच्चतम बोली लगाने वाला बोली जीतता है और उतने अंक बनाने की कोशिश करता है। बोलियां केवल लगाई या पास की जा सकती हैं, और बोली 5 के अंतराल में आगे बढ़ती है।';

  @override
  String get minBidLabel => 'न्यूनतम बोली: 175';

  @override
  String get maxBidLabel => 'अधिकतम बोली: 350';

  @override
  String get scoringTitle => 'स्कोरिंग और पॉइंट कार्ड';

  @override
  String get scoringDesc =>
      'मानक कार्ड गेम के विपरीत, केवल विशिष्ट कार्डों में अंक होते हैं। इन कार्डों वाली चालें जीतने पर अंक मिलते हैं:';

  @override
  String get totalPointsLabel => 'कुल अंक: 350';

  @override
  String get scoringTeamDesc =>
      'जीतने के लिए बोली लगाने वाले + भागीदार टीम को अपनी बोली के बराबर या उससे अधिक अंक वाले कार्ड वाली चालें जीतनी होंगी!';

  @override
  String get gameplayFlowTitle => 'गेमप्ले का प्रवाह';

  @override
  String get flowStep1Title => 'बोली लगाना';

  @override
  String get flowStep1Desc => 'खिलाड़ी अंकों की बोली लगाते हैं';

  @override
  String get flowStep2Title => 'घोषणा';

  @override
  String get flowStep2Desc =>
      'बोली लगाने वाला ट्रम्प और भागीदार कार्ड चुनता है';

  @override
  String get flowStep3Title => 'चाल खेल';

  @override
  String get flowStep3Desc => 'चालें जीतने के लिए सूट का पालन करें';

  @override
  String get flowStep4Title => 'स्कोरिंग';

  @override
  String get flowStep4Desc => 'जीती गई चालों से अंक जोड़ें';

  @override
  String get tipsTitle => 'टिप्स और नियम';

  @override
  String get tip1 => 'यदि आपके हाथ में वह सूट है तो आपको उसका पालन करना चाहिए।';

  @override
  String get tip2 =>
      'यदि आपके पास नेतृत्व वाला सूट नहीं है, तो आप चाल जीतने के लिए ट्रम्प सहित कोई भी कार्ड खेल सकते हैं।';

  @override
  String get tip3 =>
      'भागीदार गुप्त है! घोषित भागीदार कार्ड खेले जाने पर ही भागीदार की पहचान उजागर होती है।';

  @override
  String get matchmaking => 'मैचमेकिंग';

  @override
  String get matchFound => 'मैच मिला!';

  @override
  String get cancelMatch => 'मैच रद्द करें';

  @override
  String searchingPlayers(int seconds) {
    return 'खिलाड़ियों की खोज की जा रही है... (समय: ${seconds}s)';
  }

  @override
  String startingGameIn(int seconds) {
    return '$seconds सेकंड में गेम शुरू हो रहा है...';
  }

  @override
  String get searching => 'खोज रहे हैं...';

  @override
  String get privateLobby => 'निजी लॉबी';

  @override
  String get createRoom => 'कमरा बनाएं';

  @override
  String get joinRoom => 'कमरे में शामिल हों';

  @override
  String get createLobbyDesc =>
      'एक निजी लॉबी कोड बनाएं। आप अपने दोस्तों को इस लॉबी में शामिल होने के लिए आमंत्रित कर सकते हैं या बॉट्स के साथ सीटें भर सकते हैं।';

  @override
  String get generateRoom => 'कमरा उत्पन्न करें';

  @override
  String get enterRoomCodeDesc =>
      'सक्रिय निजी लॉबी में शामिल होने के लिए 6-अक्षर का कमरा कोड दर्ज करें।';

  @override
  String get roomCodeLabel => 'कमरा कोड: ';

  @override
  String get joinLobby => 'लॉबी में शामिल हों';

  @override
  String get seatedPlayers => 'बैठे हुए खिलाड़ी (अधिकतम 4)';

  @override
  String get emptySeat => 'खाली सीट';

  @override
  String get host => 'मेजबान';

  @override
  String get ready => 'तैयार';

  @override
  String get waiting => 'प्रतीक्षा कर रहे हैं...';

  @override
  String get addBots => 'बॉट्स जोड़ें';

  @override
  String get startMatch => 'मैच शुरू करें';

  @override
  String get invalidRoomCode => 'कृपया एक वैध कमरा कोड दर्ज करें।';

  @override
  String get leaderboards => 'लीडरबोर्ड';

  @override
  String get daily => 'दैनिक';

  @override
  String get allTime => 'सर्वकालिक';

  @override
  String get rank => 'रैंक';

  @override
  String get player => 'खिलाड़ी';

  @override
  String get gamesWon => 'जीते गए खेल';

  @override
  String get you => 'आप';

  @override
  String get noEntries => 'अभी तक कोई लीडरबोर्ड प्रविष्टियाँ नहीं हैं।';

  @override
  String failedToLoadLeaderboard(String error) {
    return 'लीडरबोर्ड लोड करने में विफल: $error';
  }

  @override
  String get dailyReward => 'दैनिक पुरस्कार';

  @override
  String dayNumber(int day) {
    return 'दिन $day';
  }

  @override
  String get alreadyClaimed => 'पहले ही दावा किया जा चुका है ✓';

  @override
  String claimCoins(int amount) {
    return '$amount सिक्के प्राप्त करें!';
  }

  @override
  String claimedDailyReward(int amount) {
    return '🎁 $amount दैनिक पुरस्कार सिक्के प्राप्त किए!';
  }

  @override
  String get landscapeRequired => 'लैंडस्केप मोड आवश्यक है';

  @override
  String get rotateDeviceDesc =>
      'खेलने के लिए कृपया अपने डिवाइस को घुमाएं या अपनी ब्राउज़र विंडो को चौड़ा करें।';

  @override
  String get biddingTitle => 'अपनी बोली लगाएं';

  @override
  String biddingSubtitle(int bid) {
    return 'वर्तमान बोली: $bid';
  }

  @override
  String get pass => 'पास';

  @override
  String bidButton(int bid) {
    return 'बोली $bid';
  }

  @override
  String get declareTrumpTitle => 'ट्रम्प सूट घोषित करें';

  @override
  String get declarePartnerTitle => 'भागीदार कार्ड चुनें';

  @override
  String get declareSubmit => 'घोषणा की पुष्टि करें';

  @override
  String get victory => 'जीत';

  @override
  String get defeat => 'हार';

  @override
  String bidderLabel(String name, String identity) {
    return 'बोली लगाने वाला: $name ($identity)';
  }

  @override
  String partnerLabel(String name, String identity) {
    return 'भागीदार: $name ($identity)';
  }

  @override
  String get youIdentity => 'आप';

  @override
  String get botIdentity => 'बॉट';

  @override
  String get themselves => 'स्वयं';

  @override
  String get bidValue => 'बोली का मूल्य';

  @override
  String get collected => 'एकत्रित';

  @override
  String get coinRewardsPenalties => 'सिक्का पुरस्कार / दंड:';

  @override
  String get quit => 'बाहर निकलें';

  @override
  String get playAgain => 'फिर से खेलें';

  @override
  String get creditsTitle => 'क्रेडिट्स';

  @override
  String get close => 'बंद करें';

  @override
  String get finishMatch => 'मैच समाप्त करें';

  @override
  String get continueButton => 'जारी रखें';

  @override
  String get trainingMode => 'प्रशिक्षण';

  @override
  String get gameChat => 'गेम चैट';

  @override
  String get typeMessage => 'संदेश टाइप करें...';

  @override
  String get trumpLabel => 'ट्रम्प: ';

  @override
  String get partnerLabelUpper => 'भागीदार: ';

  @override
  String get revealed => '(खुला हुआ)';

  @override
  String get hidden => '(छिपा हुआ)';

  @override
  String get passed => 'पास किया';

  @override
  String bidLabel(int bid) {
    return 'बोली: $bid';
  }

  @override
  String bidderLabelShort(int bid) {
    return 'बोली लगाने वाला ($bid)';
  }

  @override
  String get partnerLabelShort => 'भागीदार';

  @override
  String pointsLabel(int points) {
    return 'अंक: $points';
  }

  @override
  String get thinking => 'सोच रहा है ';

  @override
  String get noCards => 'कोई कार्ड नहीं';

  @override
  String get playCard => 'कार्ड खेलें';

  @override
  String get ptsUnit => 'अंक';

  @override
  String get suit => 'सूट';

  @override
  String get holdWarning =>
      'चेतावनी: आपके पास यह कार्ड है! वह कार्ड चुनें जो आपके पास नहीं है।';

  @override
  String get declareTitle => 'ट्रम्प और भागीदार घोषित करें';

  @override
  String get selectTrump => '1. ट्रम्प सूट चुनें';

  @override
  String get nominatePartner => '2. भागीदार कार्ड नामांकित करें';

  @override
  String get jack => 'गुलाम';

  @override
  String get queen => 'बेगम';

  @override
  String get king => 'बादशाह';

  @override
  String get ace => 'इक्का';

  @override
  String get spade => 'हुकुम';

  @override
  String get heart => 'पान';

  @override
  String get club => 'चिड़ी';

  @override
  String get diamond => 'ईंट';

  @override
  String get spades => 'हुकुम';

  @override
  String get hearts => 'पान';

  @override
  String get clubs => 'चिड़ी';

  @override
  String get diamonds => 'ईंट';

  @override
  String get selectModePlay => 'खेलने के लिए एक मोड चुनें';

  @override
  String get dealingCards => 'कार्ड बांटे जा रहे हैं...';

  @override
  String get allPassedRedealing =>
      'सभी खिलाड़ियों ने पास किया। पुन: वितरण किया जा रहा है...';

  @override
  String get allPassedMustBid =>
      'आपके पहले सभी खिलाड़ियों ने पास किया। आपको कम से कम 175 की बोली लगानी होगी या पास करना होगा।';

  @override
  String get welcomeMessage => 'थ्री ऑफ स्पेड्स में आपका स्वागत है!';

  @override
  String forcedBid175(String name) {
    return '$name को 175 की बोली लगाने के लिए मजबूर किया गया है।';
  }

  @override
  String playerBidMessage(String name, int amount) {
    return '$name ने $amount अंकों की बोली लगाई।';
  }

  @override
  String playerPassedMessage(String name) {
    return '$name ने पास किया।';
  }

  @override
  String wonBidDeclaring(String name, int bid) {
    return '$name ने $bid के साथ बोली जीती! ट्रम्प और भागीदार घोषित कर रहे हैं...';
  }

  @override
  String turnToLead(String name) {
    return '$name की चलने की बारी है।';
  }

  @override
  String invalidFollowSuit(String suit) {
    return 'अमान्य खेल! आपको सूट ($suit) का पालन करना चाहिए।';
  }

  @override
  String winsTrick(String name, String card, int points) {
    return '$name ने $card (+$points अंक) के साथ चाल जीती!';
  }

  @override
  String trumpPartnerDeclaration(String trump, String card, String name) {
    return 'ट्रम्प $trump है। भागीदार कार्ड $card है। $name शुरुआत करता है।';
  }

  @override
  String gameOverSummary(String bidder, String partner, String result) {
    return 'खेल समाप्त! बोली लगाने वाला $bidder था, भागीदार $partner था। $result';
  }

  @override
  String bidderPartnerWon(int got, int bid) {
    return 'बोली लगाने वाला और भागीदार जीते! $got / $bid अंक प्राप्त किए।';
  }

  @override
  String defendersWon(int got, int bid) {
    return 'रक्षा करने वाले जीते! बोली लगाने वाला और भागीदार केवल $got / $bid अंक प्राप्त कर सके।';
  }

  @override
  String get cardBack => 'कार्ड बैक';

  @override
  String get classicBlue => 'क्लासिक नीला';

  @override
  String get classicRed => 'क्लासिक लाल';

  @override
  String get neonCross => 'नियोन क्रॉस';
}
