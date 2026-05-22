# Kaali Ki Teeggi (Three of Spades) — Cyberpunk Edition

A premium, responsive, and feature-rich implementation of the popular Indian trick-taking card game **Kaali Ki Teeggi** (also known as Three of Spades), rebuilt in Flutter with a high-fidelity cyberpunk neon aesthetic. 

Designed to run beautifully on **Android**, **iOS**, and **Web**, the app features offline playing modes with strategic AI, real-time multiplayer simulation, dynamic animations, custom themes, background music, settings persistence, name customization, and robust accessibility semantics.

---

## 🎮 Game Rules & Objective

Kaali Ki Teeggi is a 4-player strategic card game played with a standard 52-card deck. The objective is to win tricks containing high-point cards.

### 1. Point Cards
There are a total of **350 points** in the deck distributed across specific cards:
*   **3 of Spades (Kaali Ki Teeggi)**: 30 Points (Highest value card in the game!)
*   **Aces (A)**: 20 Points each
*   **Kings (K), Queens (Q), Jacks (J)**: 15 Points each
*   **Tens (10)**: 10 Points each
*   **Fives (5)**: 5 Points each
*   *All other cards (2, 3 except Spades, 4, 6, 7, 8, 9)*: 0 Points

### 2. Gameplay Flow
1.  **Dealing**: The deck is shuffled and 13 cards are dealt to all 4 players.
2.  **Bidding**: Players bid in turns starting from the dealer. Bids range from **175** to **350** points (in increments of 5). If a player passes, they cannot bid again in that round. If three players pass, the remaining player wins the bid. If all players pass, the round is aborted and redealt.
3.  **Declaration**: The winning bidder declares:
    *   The **Trump Suit**.
    *   The **Partner Card** (which must not be in the bidder's own hand). The player holding this card becomes the bidder's secret partner. Nobody else (often not even the partner themselves initially) knows who the partner is until the card is played!
4.  **Trick-Taking**: The bidder leads the first trick. Players must follow suit if they have a card of the led suit. If they are void in that suit, they can play any card (including trump cards to win the trick). The highest card of the led suit wins, unless a trump is played (in which case the highest trump wins). The trick winner leads the next trick.
5.  **Scoring**: After 13 tricks, the points in all tricks won by the Bidder and the Partner are summed up.
    *   If their combined points $\ge$ the Winning Bid, the Bidder and Partner win.
    *   Otherwise, the Defenders (the other two players) win.

### 3. Bid-Scaled Coin Rewards
Coin updates scale dynamically based on the final winning bid:
*   **Bidder Wins**: Receives `bid * 2` coins.
*   **Partner Wins**: Receives `bid` coins.
*   **Bidder Loses**: Loses `bid * 1.5` coins.
*   **Partner Loses**: Loses `bid * 0.75` coins.
*   *Defenders receive / lose points opposing the bidder team's result.*

---

## 🛠️ Technology Stack

This project is built using a modern, scalable Flutter architecture:
*   **State Management**: [Riverpod 2.x](https://riverpod.dev/) (utilizing `Notifier` and `AsyncNotifier` for clean, predictable unidirectional data flow).
*   **Navigation**: [GoRouter](https://pub.dev/packages/go_router) (declarative path-based routing).
*   **Graphics & Styling**: Custom HSL-based neon palettes, glassmorphic card overlays, Google Fonts (`Inter`/`Outfit`), and optimized vector SVGs via `flutter_svg`.
*   **Audio**: `audioplayers` for loopable ambient electronic background music and dynamic sound effects (success chime, bidding pass, play card, errors).
*   **Local Storage**: `shared_preferences` for preserving player statistics (games played, win rates, coin balances, username settings, audio preferences).
*   **Accessibility**: Full integration of Flutter's `Semantics` framework (aria tags on playing cards, minimum 48x48dp interactive touch target areas, and screen reader announcements for critical game phase transitions).

---

## 📂 Project Architecture

```
lib/
├── core/
│   ├── router.dart           # GoRouter route declarations and redirect hooks
│   ├── sound_manager.dart    # Audio manager (music loop toggles, sfx chimes)
│   ├── theme.dart            # Cyberpunk color tokens, gradients, and neon shadow configurations
│   ├── suit_utils.dart       # Helper functions for suit symbols and colors
│   └── scoring_utils.dart    # Bid-scaled scoring algorithms
├── models/
│   ├── card_model.dart       # Core card class, overrides ==/hashCode, and deck generators
│   ├── player_model.dart     # Player state holding hands, roles, and statistics
│   ├── game_state.dart       # Whole game stage, round status, active seat, and trump suit
│   └── multiplayer_state.dart# Multiplayer lobby matchmaking statuses and room variables
├── providers/
│   ├── game_notifier.dart    # Main game engine loop, bot actions, and trick logic
│   ├── stats_provider.dart   # Local statistics storage, settings, and player naming updates
│   └── multiplayer_notifier.dart # Online room matchmaking simulators
├── screens/
│   ├── splash_screen.dart    # App loader landing screen
│   ├── tutorial_screen.dart  # Multi-page interactive rules and onboarding page
│   ├── home_screen.dart      # Main dashboard with stats, options, and lobby routing
│   ├── game_screen.dart      # Composition screen for offline/online gameplay table
│   ├── matchmaking_screen.dart# Cyberpunk matchfinder screen
│   ├── private_room_screen.dart# Private lounge setup simulator
│   └── leaderboard_screen.dart# Dynamic global top player ranking screen
└── widgets/
    ├── bidding_overlay.dart  # Interactive bidder slider overlay
    ├── chat_panel.dart       # In-game communication console and typing animations
    ├── dealing_animation.dart# Staggered deck distribution overlays
    ├── declaring_overlay.dart# Trump selection and partner card selectors
    ├── game_table.dart       # Round table seats and tricks display
    ├── game_top_bar.dart     # Match HUD (trumps, current trick, stats)
    ├── glass_dialog.dart     # Glassmorphic alerts
    ├── player_hand_panel.dart# Human hand layout and gesture controllers
    ├── playing_card_widget.dart# Accessible SVG playing cards
    └── scoreboard_overlay.dart# End-of-round scores, coin updates, and restart triggers
```

---

## 🚀 Building & Running

### Prerequisites
1. Install [Flutter SDK (3.x or higher)](https://docs.flutter.dev/get-started/install).
2. Ensure you have an Android Emulator, iOS Simulator, or Google Chrome installed.

### Setup
Run the following commands in the project directory:
```bash
# Fetch dependencies
flutter pub get
```

### Run Locally
```bash
# Run in development mode
flutter run

# Run on specific target (e.g. Chrome)
flutter run -d chrome

# Run on Android Emulator
flutter run -d emulator-5554
```

### Executing Tests
We maintain 100% success across all game loop logic and Bot decision engines:
```bash
# Run all unit/widget tests
flutter test

# Run tests with HTML coverage reports
flutter test --coverage
```

### Creating Release Builds
```bash
# Build unsigned release Android APK
flutter build apk --release

# Build optimized static files for Web
flutter build web --release

# Build iOS archive (no signing identity required for local check)
flutter build ios --no-codesign
```

---

## ♿ Accessibility (A11y) Compliance
*   **Playing Cards**: Stated rank, suit, point weight, and hand interaction cues read seamlessly by screen readers (e.g. TalkBack / VoiceOver).
*   **Interactive Targets**: Every clickable slider, text field, and button conforms to the minimum **48x48dp** touch target standards to aid user input.
*   **Live Announcements**: State messages (e.g., winning tricks, trump suit declared, bot bids) are programmatically broadcasted via `SemanticsService.announce` immediately on event changes.
*   **Typography**: Minimum font size matches the standard **11px** requirements across all screens to ensure high legibility under dense mobile aspect ratios.
