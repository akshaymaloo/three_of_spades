import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../providers/game_notifier.dart';
import '../screens/splash_screen.dart';
import '../screens/start_screen.dart';
import '../screens/home_screen.dart';
import '../screens/game_screen.dart';
import '../screens/matchmaking_screen.dart';
import '../screens/private_room_screen.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/tutorial_screen.dart';
import '../providers/stats_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final phaseListenable = ValueNotifier<GamePhase>(ref.watch(gameProvider.select((s) => s.phase)));
  
  ref.listen<GamePhase>(
    gameProvider.select((s) => s.phase),
    (previous, next) {
      phaseListenable.value = next;
    },
  );

  return GoRouter(
    initialLocation: '/',
    refreshListenable: phaseListenable,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/start',
        builder: (context, state) => const StartScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/tutorial',
        builder: (context, state) => const TutorialScreen(),
      ),
      GoRoute(
        path: '/game',
        builder: (context, state) => const GameScreen(),
      ),
      GoRoute(
        path: '/matchmaking',
        builder: (context, state) => const MatchmakingScreen(),
      ),
      GoRoute(
        path: '/private-room',
        builder: (context, state) => const PrivateRoomScreen(),
      ),
      GoRoute(
        path: '/leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
    ],
    redirect: (context, state) {
      final phase = phaseListenable.value;
      final location = state.uri.path;

      // Handle main flow redirection based on phase
      if (phase == GamePhase.splash) {
        if (location != '/') return '/';
      } else if (phase == GamePhase.start) {
        if (location != '/start') return '/start';
      } else if (phase == GamePhase.home) {
        final statsAsync = ref.read(statsProvider);
        if (statsAsync is AsyncData<UserStats>) {
          final hasSeenTutorial = statsAsync.value.hasSeenTutorial;
          if (!hasSeenTutorial) {
            if (location != '/tutorial') return '/tutorial';
          } else {
            final allowedHomeRoutes = ['/home', '/matchmaking', '/private-room', '/leaderboard', '/tutorial'];
            if (!allowedHomeRoutes.contains(location)) {
              return '/home';
            }
          }
        } else {
          final allowedHomeRoutes = ['/home', '/matchmaking', '/private-room', '/leaderboard', '/tutorial'];
          if (!allowedHomeRoutes.contains(location)) {
            return '/home';
          }
        }
      } else {
        if (location != '/game') return '/game';
      }

      return null;
    },
  );
});
