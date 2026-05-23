import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/game_notifier.dart';
import '../providers/config_provider.dart';
import '../providers/service_providers.dart';
import '../providers/stats_provider.dart';

class StartScreen extends ConsumerStatefulWidget {
  const StartScreen({super.key});

  @override
  ConsumerState<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends ConsumerState<StartScreen> {
  bool _isLoading = false;

  Future<void> _handleFacebookLogin() async {
    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signInWithFacebook();
      if (user != null) {
        // Update user stats with display name
        if (user.displayName != null) {
          await ref.read(statsProvider.notifier).updateName(user.displayName!);
        }
        if (mounted) {
          ref.read(gameProvider.notifier).goToHome();
        }
      } else {
        _showError('Facebook Login cancelled or failed');
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGuestLogin() async {
    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signInAnonymously();
      if (user != null) {
        if (user.displayName != null) {
          await ref.read(statsProvider.notifier).updateName(user.displayName!);
        }
        if (mounted) {
          ref.read(gameProvider.notifier).goToHome();
        }
      } else {
        _showError('Guest Sign-In failed');
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: GameTheme.neonPink,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(configProvider);
    final modeText = config.onlineMode ? 'Online Mode' : 'Simulation Mode';

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

                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(color: GameTheme.neonCyan),
                    )
                  else ...[
                    // Play Offline / Guest Button
                    InkWell(
                      onTap: () {
                        if (config.onlineMode) {
                          _handleGuestLogin();
                        } else {
                          ref.read(gameProvider.notifier).goToHome();
                        }
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
                        child: Center(
                          child: Text(
                            config.onlineMode ? 'SIGN IN AS GUEST' : 'PLAY OFFLINE',
                            style: const TextStyle(
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

                    // Facebook Login Button (Only in Online Mode or if they want to sign in)
                    if (config.onlineMode) ...[
                      InkWell(
                        onTap: _handleFacebookLogin,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1877F2), Color(0xFF0C56B3)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: GameTheme.neonGlow(const Color(0xFF1877F2)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.facebook, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'SIGN IN WITH FACEBOOK',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    Text(
                      config.onlineMode
                          ? 'Sign in to access global matchmaking'
                          : 'Enter as Guest and get 5,000 free coins',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: GameTheme.neonGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8),
                  Text(
                    'v1.0.0 ($modeText)',
                    style: const TextStyle(
                      fontSize: 11,
                      color: GameTheme.textGrey,
                      fontWeight: FontWeight.bold,
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
