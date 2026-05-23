import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../models/multiplayer_state.dart';
import '../providers/multiplayer_notifier.dart';
import '../l10n/app_localizations.dart';

class MatchmakingScreen extends ConsumerStatefulWidget {
  const MatchmakingScreen({super.key});

  @override
  ConsumerState<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends ConsumerState<MatchmakingScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-trigger matchmaking search when entering this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(multiplayerProvider.notifier).startMatchmaking();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mState = ref.watch(multiplayerProvider);

    // Pop the screen automatically if state has transitioned to playing
    if (mState.status == MultiplayerStatus.playing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.pop();
        }
      });
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(multiplayerProvider.notifier).cancelMatchmaking();
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: GameTheme.backgroundGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Row(
                children: [
                  // Left Column: Banner, Radar Scanner / Countdown, Cancel Button
                  Expanded(
                    flex: 4,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            mState.status == MultiplayerStatus.searching
                                ? (AppLocalizations.of(context)?.matchmaking ?? 'MATCHMAKING')
                                : (AppLocalizations.of(context)?.matchFound ?? 'MATCH FOUND!'),
                            style: const TextStyle(
                              color: GameTheme.textWhite,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 100,
                            width: 100,
                            child: mState.status == MultiplayerStatus.searching
                                ? const RadarScanner()
                                : Center(
                                    child: Text(
                                      mState.countdownTimer.toString(),
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: GameTheme.neonGreen,
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 16),
                          if (mState.status == MultiplayerStatus.searching)
                            InkWell(
                              onTap: () {
                                ref.read(multiplayerProvider.notifier).cancelMatchmaking();
                                context.pop();
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                                decoration: BoxDecoration(
                                  border: Border.all(color: GameTheme.neonPink.withValues(alpha: 0.5)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)?.cancelMatch ?? 'CANCEL MATCH',
                                  style: const TextStyle(
                                    color: GameTheme.neonPink,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const VerticalDivider(color: Colors.white12, width: 24, indent: 20, endIndent: 20),
                  // Right Column: Connection status, connected players
                  Expanded(
                    flex: 6,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mState.status == MultiplayerStatus.searching
                                ? (AppLocalizations.of(context)?.searchingPlayers(mState.searchTimer) ?? 'Searching for players... (Timer: ${mState.searchTimer}s)')
                                : (AppLocalizations.of(context)?.startingGameIn(mState.countdownTimer) ?? 'Starting game in ${mState.countdownTimer} seconds...'),
                            style: const TextStyle(
                              color: GameTheme.textGrey,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: GameTheme.glassDecoration(opacity: 0.03, borderOpacity: 0.08),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 3.0,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: 4,
                              itemBuilder: (context, index) {
                                final hasPlayer = mState.lobbyPlayers.length > index;
                                final name = hasPlayer 
                                    ? mState.lobbyPlayers[index] 
                                    : (AppLocalizations.of(context)?.searching ?? 'Searching...');
                                final isUser = index == 0;
 
                                return Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: hasPlayer 
                                              ? (isUser ? GameTheme.neonCyan : GameTheme.neonGreen)
                                              : Colors.white10,
                                          width: 1.5,
                                        ),
                                        boxShadow: hasPlayer 
                                            ? GameTheme.neonGlow(isUser ? GameTheme.neonCyan : GameTheme.neonGreen, blurRadius: 4)
                                            : null,
                                        color: Colors.white.withValues(alpha: 0.02),
                                      ),
                                      child: Icon(
                                        hasPlayer ? Icons.person_rounded : Icons.hourglass_empty_rounded,
                                        color: hasPlayer 
                                            ? (isUser ? GameTheme.neonCyan : GameTheme.neonGreen)
                                            : GameTheme.textGrey.withValues(alpha: 0.3),
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: hasPlayer ? GameTheme.textWhite : GameTheme.textGrey.withValues(alpha: 0.4),
                                          fontSize: 11,
                                          fontWeight: hasPlayer ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
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

class RadarScanner extends StatefulWidget {
  const RadarScanner({super.key});

  @override
  State<RadarScanner> createState() => _RadarScannerState();
}

class _RadarScannerState extends State<RadarScanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: RadarPainter(_controller.value),
          size: const Size(200, 200),
        );
      },
    );
  }
}

class RadarPainter extends CustomPainter {
  final double animationValue;
  RadarPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Draw concentric circles
    final paint = Paint()
      ..color = GameTheme.neonCyan.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 1; i <= 3; i++) {
      final radius = maxRadius * ((animationValue + (i / 3)) % 1.0);
      final opacity = 1.0 - (radius / maxRadius);
      paint.color = GameTheme.neonCyan.withValues(alpha: opacity * 0.4);
      canvas.drawCircle(center, radius, paint);
    }

    // Draw scanning sweeping line
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          GameTheme.neonCyan.withValues(alpha: 0.0),
          GameTheme.neonCyan.withValues(alpha: 0.3),
          GameTheme.neonCyan.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(animationValue * 2 * pi),
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, maxRadius, sweepPaint);
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
