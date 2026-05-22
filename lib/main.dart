import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'models/game_state.dart';
import 'providers/game_notifier.dart';
import 'screens/splash_screen.dart';
import 'screens/start_screen.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock landscape orientation on mobile
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    const ProviderScope(
      child: ThreeOfSpadesApp(),
    ),
  );
}

class ThreeOfSpadesApp extends StatelessWidget {
  const ThreeOfSpadesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Three of Spades (Kaali Ki Teeggi)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: GameTheme.darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: GameTheme.neonCyan,
          secondary: GameTheme.neonPink,
          surface: GameTheme.darkBackground,
        ),
        fontFamily: 'Outfit', // Uses fallback if Google Fonts is not present locally
      ),
      home: const GamePhaseRouter(),
    );
  }
}

class GamePhaseRouter extends ConsumerWidget {
  const GamePhaseRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(gameProvider.select((state) => state.phase));

    switch (phase) {
      case GamePhase.splash:
        return const SplashScreen();
      case GamePhase.start:
        return const StartScreen();
      case GamePhase.home:
        return const HomeScreen();
      case GamePhase.dealing:
      case GamePhase.bidding:
      case GamePhase.declaring:
      case GamePhase.playing:
      case GamePhase.roundOver:
        return const GameScreen();
    }
  }
}
