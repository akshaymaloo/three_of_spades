import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/game_notifier.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // After 2.5 seconds, navigate to start screen
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        ref.read(gameProvider.notifier).updatePlayersCoins();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: GameTheme.backgroundGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: GameTheme.darkBackground,
                    boxShadow: GameTheme.neonGlow(GameTheme.neonPink, blurRadius: 20),
                    border: Border.all(color: GameTheme.neonPink, width: 2),
                  ),
                  child: const Text(
                    '♠',
                    style: TextStyle(
                      fontSize: 80,
                      height: 1.1,
                      color: GameTheme.neonPink,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'THREE OF SPADES',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: GameTheme.textWhite,
                  shadows: [
                    Shadow(
                      color: GameTheme.neonCyan.withOpacity(0.8),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'KAALI KI TEEGGI',
                style: TextStyle(
                  fontSize: 14,
                  letterSpacing: 2,
                  color: GameTheme.neonCyan,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 64),
              SizedBox(
                width: 180,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white.withOpacity(0.05),
                    color: GameTheme.neonCyan,
                    minHeight: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

