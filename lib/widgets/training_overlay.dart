import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../core/theme.dart';

class TrainingOverlay extends StatelessWidget {
  final GameState game;

  const TrainingOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    if (!game.isTrainingMode) return const SizedBox.shrink();

    String title = '';
    String tip = '';

    switch (game.phase) {
      case GamePhase.bidding:
        title = 'Bidding Phase';
        tip = 'Estimate how many points you can win. Minimum bid is 175. If you win the bid, you get to choose Trump!';
        break;
      case GamePhase.declaring:
        title = 'Declaring Phase';
        tip = 'You won the bid! Choose a Trump suit and call a Partner card. The player holding that card will secretly be your partner.';
        break;
      case GamePhase.playing:
        if (game.activePlayerIndex == 0) {
          title = 'Your Turn';
          tip = 'Follow the suit if you have it. The highest card of the suit or the highest Trump wins the trick.';
        } else {
          return const SizedBox.shrink(); // don't show while bots are playing to avoid clutter
        }
        break;
      default:
        return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 150, // above the player hand
      left: 16,
      right: 16,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: GameTheme.neonCyan.withValues(alpha: 0.5)),
            boxShadow: GameTheme.neonGlow(GameTheme.neonCyan, blurRadius: 10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline, color: GameTheme.goldAccent, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: GameTheme.neonCyan,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tip,
                      style: const TextStyle(
                        color: GameTheme.textWhite,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
