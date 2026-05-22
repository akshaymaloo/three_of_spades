import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/game_notifier.dart';

class StartScreen extends ConsumerWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: GameTheme.backgroundGradient,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(32),
              decoration: GameTheme.glassDecoration(opacity: 0.05, borderOpacity: 0.1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '♠ ♥ ♣ ♦',
                    style: TextStyle(
                      fontSize: 36,
                      color: GameTheme.neonCyan,
                      letterSpacing: 8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Three of Spades',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: GameTheme.textWhite,
                      shadows: [
                        Shadow(
                          color: GameTheme.neonPink.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Classic 4-Player Card Game',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: GameTheme.textGrey,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Glowing Play Button
                  InkWell(
                    onTap: () {
                      ref.read(gameProvider.notifier).goToHome();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: GameTheme.neonCyanGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: GameTheme.neonGlow(GameTheme.neonCyan),
                      ),
                      child: const Center(
                        child: Text(
                          'PLAY OFFLINE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: GameTheme.darkBackground,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Enter as Guest and get 5,000 free coins',
                    style: TextStyle(
                      fontSize: 12,
                      color: GameTheme.neonGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
