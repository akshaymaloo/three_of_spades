import 'dart:math' as math;
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/sound_manager.dart';

class DealingAnimation extends StatefulWidget {
  final VoidCallback onComplete;

  const DealingAnimation({
    super.key,
    required this.onComplete,
  });

  @override
  State<DealingAnimation> createState() => _DealingAnimationState();
}

class _DealingAnimationState extends State<DealingAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _lastPlayedSoundBatch = -1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _controller.addListener(() {
      // 13 batches of dealing (13 cards per player)
      final progress = _controller.value;
      final currentBatch = (progress * 13).floor();
      if (currentBatch > _lastPlayedSoundBatch && currentBatch < 13) {
        _lastPlayedSoundBatch = currentBatch;
        SoundManager().playSound('sounds/card_played.mp3');
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    // Start dealing animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Center Deck stack representing remaining cards
            Center(
              child: Container(
                width: 50,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D47A1).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 3)),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '♠',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ),
            
            // Build the 52 flying cards
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final double val = _controller.value;
                return Stack(
                  children: List.generate(52, (index) {
                    final int playerIdx = index % 4;
                    // Staggered timing for each card
                    final double startTime = (index / 52) * 0.70;
                    final double endTime = startTime + 0.25;

                    if (val < startTime) {
                      return const SizedBox.shrink();
                    }

                    // Calculate interpolation factor t (0.0 to 1.0)
                    final double rawT = (val - startTime) / (endTime - startTime);
                    final double t = Curves.easeOut.transform(rawT.clamp(0.0, 1.0));

                    // Target alignments for the 4 player seats
                    late final Alignment targetAlign;
                    late final double targetRotation;

                    switch (playerIdx) {
                      case 0: // Bottom (You)
                        targetAlign = const Alignment(0, 0.85);
                        targetRotation = 0.0;
                        break;
                      case 1: // Left Bot
                        targetAlign = const Alignment(-0.85, -0.05);
                        targetRotation = math.pi / 2;
                        break;
                      case 2: // Top Bot
                        targetAlign = const Alignment(0, -0.85);
                        targetRotation = math.pi;
                        break;
                      case 3: // Right Bot
                        targetAlign = const Alignment(0.85, -0.05);
                        targetRotation = -math.pi / 2;
                        break;
                    }

                    // Lerp position, scale, opacity, rotation
                    final alignment = Alignment.lerp(Alignment.center, targetAlign, t)!;
                    final opacity = lerpDouble(0.0, 1.0, t.clamp(0.0, 0.5) * 2.0)!;
                    final sizeMultiplier = lerpDouble(0.6, 1.0, t)!;
                    final rotation = lerpDouble(0.0, targetRotation, t)!;

                    return Align(
                      alignment: alignment,
                      child: Transform.rotate(
                        angle: rotation,
                        child: Transform.scale(
                          scale: sizeMultiplier,
                          child: Opacity(
                            opacity: opacity,
                            child: Container(
                              width: 44,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D47A1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.white, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: GameTheme.neonCyan.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                  const BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  '♠',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
            
            // Neon status overlay
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: GameTheme.glassDecoration(
                    opacity: 0.15,
                    borderOpacity: 0.3,
                    radius: 20,
                    borderColor: GameTheme.neonCyan,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(GameTheme.neonCyan),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'DEALING CARDS...',
                        style: TextStyle(
                          color: GameTheme.neonCyan,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
