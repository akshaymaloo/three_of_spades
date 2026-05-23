# Kaali Ki Teeggi (Three of Spades)

A premium, responsive Flutter implementation of the popular Indian trick-taking card game **Kaali Ki Teeggi** (Three of Spades), with offline bot play, real-time online multiplayer, daily rewards, ads, and push notifications.

Designed for **Android**, **iOS**, and **Web** with strategic AI, clean card-game aesthetics, dynamic animations, and Firebase-backed online services.

---

## 🎮 Game Rules & Objective

Kaali Ki Teeggi is a 4-player strategic card game played with a standard 52-card deck. The objective is to win tricks containing high-point cards.

### Point Cards (350 total)
| Card | Points |
|---|---|
| 3 of Spades (Kaali Ki Teeggi) | 30 |
| Aces (A) | 20 each |
| Kings (K), Queens (Q), Jacks (J) | 15 each |
| Tens (10) | 10 each |
| Fives (5) | 5 each |
| All other cards | 0 |

### Gameplay Flow
1. **Dealing**: 13 cards dealt to each of 4 players.
2. **Bidding**: Players bid 175–350 points (increments of 5). Pass = out. Three passes = remaining player wins. All pass = redeal.
3. **Declaration**: Winning bidder declares **Trump Suit** and **Partner Card** (not in their hand). The holder is the secret partner.
4. **Trick-Taking**: Follow suit required. Trump beats led suit. Highest card wins the trick.
5. **Scoring**: Bidder + Partner combined points ≥ bid = they win. Otherwise, defenders win.

### Coin Rewards (Bid-Scaled)
| Outcome | Coins |
|---|---|
| Bidder Wins | `bid × 2` |
| Partner Wins | `bid × 1` |
| Bidder Loses | `-bid × 1.5` |
| Partner Loses | `-bid × 0.75` |

---

## 🚀 Quick Start

### Prerequisites
- [Flutter SDK 3.x+](https://docs.flutter.dev/get-started/install)
- Android Studio / Xcode / Chrome for target platform
- (Optional) [Firebase CLI](https://firebase.google.com/docs/cli) for online mode

### Run in Simulation Mode (No Firebase Needed)
```bash
# Clone and install
git clone <repo-url>
cd three_of_spades_flutter
flutter pub get

# Run on connected device or emulator
flutter run

# Run on Android emulator specifically
flutter run -d emulator-5554

# Run on Chrome
flutter run -d chrome
```

The app starts in **Simulation Mode** by default — all multiplayer features use local bot simulation. No Firebase project required.

---

## 🔄 Online vs Simulation Mode

The app supports two modes controlled via a settings toggle:

| Feature | Simulation Mode (Default) | Online Mode |
|---|---|---|
| Matchmaking | Local bots join after short delays | Real players via Firestore rooms |
| Chat | Bot-generated responses | Real-time Firestore chat |
| Leaderboard | Hardcoded sample data | Live Firestore rankings |
| Auth | Guest user (local) | Firebase Auth (Anonymous / Facebook) |
| Ads | Simulated (2s delay, always rewards) | Real AdMob ads |
| Push Notifications | Disabled | Firebase Cloud Messaging |
| Daily Rewards | Works locally | Synced to Firestore |

### Switching Modes
1. Open the app → go to **Home Screen**
2. Tap the **⚙️ Settings** button
3. Toggle **"Online Mode"** switch
4. A SnackBar confirms the mode change

> **Note**: Online Mode requires Firebase credentials. Without them, the toggle will be disabled and the app stays in Simulation Mode.

---

## 🔥 Going Live (Firebase Setup)

To enable Online Mode with real Firebase services:

### 1. Create a Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project (or use an existing one)
3. Enable the following services:
   - **Authentication** → Enable "Anonymous" and "Facebook" sign-in methods
   - **Cloud Firestore** → Create database in production mode
   - **Cloud Messaging** → Enabled by default
   - **Analytics** → Enabled by default
   - **Crashlytics** → Enable in the console

### 2. Add Platform Config Files

#### Android
1. In Firebase Console → Project Settings → Add Android app
2. Package name: `com.kaalikiteeggi.three_of_spades`
3. Download `google-services.json`
4. Place it at: `android/app/google-services.json`

#### iOS
1. In Firebase Console → Project Settings → Add iOS app
2. Bundle ID: `com.kaalikiteeggi.threeOfSpades`
3. Download `GoogleService-Info.plist`
4. Place it at: `ios/Runner/GoogleService-Info.plist`

### 3. Facebook Login (Optional)
1. Create an app at [developers.facebook.com](https://developers.facebook.com)
2. Get your **App ID** and **Client Token**
3. Update `android/app/src/main/res/values/strings.xml`:
   ```xml
   <string name="facebook_app_id">YOUR_APP_ID</string>
   <string name="fb_login_protocol_scheme">fbYOUR_APP_ID</string>
   <string name="facebook_client_token">YOUR_CLIENT_TOKEN</string>
   ```

### 4. AdMob Setup (Optional)
1. Create an AdMob account at [admob.google.com](https://admob.google.com)
2. Create an Android app and get your **App ID**
3. Update `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data android:name="com.google.android.gms.ads.APPLICATION_ID"
              android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"/>
   ```
4. Update ad unit IDs in `lib/services/ad_service.dart`

### 5. Firestore Security Rules
Deploy these rules for your Firestore database:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /rooms/{roomId} {
      allow read, write: if request.auth != null;
      match /chat/{messageId} {
        allow read, write: if request.auth != null;
      }
    }
  }
}
```

### 6. Build & Deploy
```bash
# Build release APK
flutter build apk --release

# Build release App Bundle (for Play Store)
flutter build appbundle --release

# Build for iOS
flutter build ios --release
```

---

## 🛠️ Technology Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart) |
| State Management | Riverpod 2.x (Notifier pattern) |
| Navigation | GoRouter |
| Backend (Online) | Firebase (Auth, Firestore, FCM, Analytics, Crashlytics) |
| Ads | Google Mobile Ads (AdMob) |
| Auth Providers | Anonymous, Facebook |
| Styling | Custom HSL palettes, glassmorphic overlays, Google Fonts (Outfit) |
| Audio | `audioplayers` for BGM and SFX |
| Local Storage | `shared_preferences` |
| Accessibility | Flutter Semantics framework |

---

## 📂 Project Architecture

```
lib/
├── core/
│   ├── router.dart              # GoRouter route declarations
│   ├── sound_manager.dart       # Audio manager (music, SFX)
│   ├── theme.dart               # Color tokens, gradients, glass decorations
│   ├── suit_utils.dart          # Suit symbol/color helpers
│   └── scoring_utils.dart       # Bid-scaled scoring algorithms
├── models/
│   ├── card_model.dart          # Card class with deck generators
│   ├── player_model.dart        # Player state (hands, roles, stats)
│   ├── game_state.dart          # Game phases, round state, trump suit
│   └── multiplayer_state.dart   # Lobby/matchmaking state
├── providers/
│   ├── config_provider.dart     # Online/Simulation mode toggle
│   ├── game_notifier.dart       # Game engine loop, bot AI, trick logic
│   ├── stats_provider.dart      # Local stats, settings, player name
│   ├── multiplayer_notifier.dart# Matchmaking & room management
│   ├── daily_reward_provider.dart# Daily login reward system
│   ├── ad_provider.dart         # Ad loading and display management
│   └── notification_provider.dart# Push notification state
├── services/
│   ├── auth_service.dart        # Base/Live/Mock auth (Anonymous + FB)
│   ├── multiplayer_sync_service.dart # Base/Live/Mock room sync
│   ├── leaderboard_service.dart # Base/Live/Mock leaderboard
│   ├── ad_service.dart          # Base/Live/Mock ads (AdMob)
│   └── notification_service.dart# Base/Live/Mock push notifications (FCM)
├── screens/
│   ├── splash_screen.dart       # App loader
│   ├── start_screen.dart        # Login screen (Guest / Facebook)
│   ├── home_screen.dart         # Dashboard with stats, modes, settings
│   ├── game_screen.dart         # Gameplay table composition
│   ├── matchmaking_screen.dart  # Quick match finder
│   ├── private_room_screen.dart # Private room setup
│   ├── leaderboard_screen.dart  # Rankings (daily + all-time)
│   └── tutorial_screen.dart     # Interactive rules & onboarding
└── widgets/
    ├── bidding_overlay.dart      # Bid slider overlay
    ├── chat_panel.dart           # In-game chat
    ├── daily_reward_dialog.dart  # Daily reward claim dialog
    ├── dealing_animation.dart    # Card dealing animation
    ├── declaring_overlay.dart    # Trump & partner selection
    ├── game_table.dart           # Round table seats & tricks
    ├── game_top_bar.dart         # Match HUD
    ├── glass_dialog.dart         # Glassmorphic alert dialog
    ├── player_hand_panel.dart    # Human hand layout
    ├── playing_card_widget.dart  # Accessible card widget
    └── scoreboard_overlay.dart   # End-of-round scores
```

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run a specific test file
flutter test test/game_notifier_test.dart
```

### Test Coverage
| Area | Tests |
|---|---|
| Game engine logic | game_notifier_test.dart |
| Card model & scoring | game_test.dart |
| Bot AI (bidding, playing, declaring) | bot_ai_test.dart |
| Multiplayer state | multiplayer_test.dart |
| Widget rendering | widget_test.dart |
| Config provider | config_provider_test.dart |
| Auth service | auth_service_test.dart |
| Daily rewards | daily_reward_test.dart |
| Ad service | ad_service_test.dart |
| Notification service | notification_service_test.dart |

---

## ♿ Accessibility
- **Playing Cards**: Rank, suit, point weight read by screen readers (TalkBack/VoiceOver)
- **Interactive Targets**: Minimum 48×48dp touch targets
- **Live Announcements**: Game state changes broadcast via `SemanticsService.announce`
- **Typography**: Minimum 11px font size across all screens

---

## 📄 License

This project is proprietary software. All rights reserved.
