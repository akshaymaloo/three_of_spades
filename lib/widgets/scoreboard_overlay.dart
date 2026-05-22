import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../core/theme.dart';
import '../core/scoring_utils.dart';
import '../providers/game_notifier.dart';

class ScoreboardOverlay extends ConsumerWidget {
  final GameState game;

  const ScoreboardOverlay({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bidderIndex = game.bidderIndex!;

    // Find partner index
    int partnerIndex = bidderIndex;
    for (int i = 0; i < 4; i++) {
      if (game.players[i].isPartner) {
        partnerIndex = i;
        break;
      }
    }

    final bidderPoints = game.players[bidderIndex].roundPoints;
    final partnerPoints = game.players[partnerIndex].roundPoints;
    final totalBidderPoints = bidderIndex == partnerIndex ? bidderPoints : bidderPoints + partnerPoints;
    final isBidWon = totalBidderPoints >= game.winningBid;

    // Check if human won
    final isHumanBidderOrPartner = (bidderIndex == 0 || partnerIndex == 0);
    final bool humanWon = isBidWon ? isHumanBidderOrPartner : !isHumanBidderOrPartner;

    final glowColor = humanWon ? GameTheme.neonGreen : GameTheme.neonPink;
    final size = MediaQuery.of(context).size;

    // Calculate coin deltas
    final coinDelta = calculateCoinDeltas(
      winningBid: game.winningBid,
      bidderIndex: bidderIndex,
      partnerIndex: partnerIndex,
      isBidWon: isBidWon,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black.withValues(alpha: 0.65),
            ),
          ),
        ),
        Center(
          child: Container(
            width: 440,
            constraints: BoxConstraints(maxHeight: size.height - 32),
            decoration: BoxDecoration(
              color: GameTheme.darkBackground.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: glowColor.withValues(alpha: 0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    humanWon ? 'VICTORY' : 'DEFEAT',
                    style: TextStyle(
                      color: glowColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                      shadows: GameTheme.neonGlow(glowColor),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Bidder: ${game.players[bidderIndex].name} (${game.players[bidderIndex].isHuman ? "You" : "Bot"})',
                    style: const TextStyle(color: GameTheme.textWhite, fontSize: 13),
                  ),
                  Text(
                    'Partner: ${bidderIndex == partnerIndex ? "Themselves" : game.players[partnerIndex].name} (${game.players[partnerIndex].isHuman ? "You" : "Bot"})',
                    style: const TextStyle(color: GameTheme.textWhite, fontSize: 13),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('BID VALUE', style: TextStyle(color: GameTheme.textGrey, fontSize: 11)),
                            Text('${game.winningBid} pts', style: const TextStyle(color: GameTheme.textWhite, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('COLLECTED', style: TextStyle(color: GameTheme.textGrey, fontSize: 11)),
                            Text('$totalBidderPoints pts', style: TextStyle(color: glowColor, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('COIN REWARDS / PENALTIES:', style: TextStyle(color: GameTheme.textGrey, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),

                  // List of players and coins gained/lost
                  ...List.generate(4, (i) {
                    final p = game.players[i];
                    final delta = coinDelta[i];
                    final isPositive = delta >= 0;
                    final text = isPositive ? '+$delta' : '$delta';
                    final color = isPositive ? GameTheme.neonGreen : GameTheme.neonPink;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(p.name, style: const TextStyle(color: GameTheme.textWhite, fontSize: 12)),
                          Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            ref.read(gameProvider.notifier).goToHome();
                          },
                          child: const Text('QUIT', style: TextStyle(color: GameTheme.textWhite, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: glowColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            ref.read(gameProvider.notifier).startNewGame();
                          },
                          child: const Text('PLAY AGAIN', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
