# Changelog

All notable changes to the **Kaali Ki Teeggi (Three of Spades)** Flutter project will be documented in this file.

## [1.0.0] - 2026-05-23

This is a major production-ready release bringing the Flutter codebase to feature parity with the native reference Android application.

### Added
- **Config-Driven Online/Simulation Toggle**: Allows toggling between Online (Firebase live) and Simulation (offline mock) modes directly from settings. Fallback mechanisms automatically downgrade to Simulation Mode if Firebase initialization fails on startup.
- **Firebase Infrastructure Integration**: Added Firebase Core, Firebase Authentication, Cloud Firestore, and Firebase Messaging (FCM) configurations.
- **Google Mobile Ads (AdMob)**: Configured mobile ads with preloaded Interstitial ads (showing after every 3rd game round) and Rewarded ads (awarding +500 coins on completion).
- **Daily Rewards System**: A consecutive 7-day reward schedule matching the original app (500 to 5000 coins) with custom highlighted UI cards and automatic checkmarks for claimed days.
- **Facebook Authentication**: Added Facebook login support on the start screen alongside Anonymous Guest login when in Online Mode.
- **Leaderboards**: Integrated a two-tab global leaderboard screen supporting "DAILY" and "ALL-TIME" rankings, fetching real-time data from Firestore.
- **Push Notifications (FCM)**: Added support for version update notifications and room invite payloads with topics subscription settings.
- **Unit & Integration Tests**: Expanded the test suite to 44 fully passing tests covering new service providers, mock behaviors, daily rewards calculations, and config toggles.

### Fixed
- Resolved overlapping banner text on the game table.
- Corrected imports alignment to satisfy Dart compiling constraints.
- Fixed Daily Reward dialog layout overflow under small screen heights and landscape orientations.
- Resolved Kotlin / Java JVM target compilation incompatibilities in subproject Gradle setups.
