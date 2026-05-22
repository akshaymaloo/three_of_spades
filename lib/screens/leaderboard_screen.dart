import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/stats_provider.dart';

class LeaderboardPlayer {
  final String name;
  final int coins;
  final String winRate;
  final bool isUser;

  const LeaderboardPlayer({
    required this.name,
    required this.coins,
    required this.winRate,
    this.isUser = false,
  });
}

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    return statsAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: GameTheme.neonCyan),
        ),
      ),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
        ),
      ),
      data: (stats) {
        // Mock global players
    final List<LeaderboardPlayer> globalPlayers = [
      const LeaderboardPlayer(name: 'SpadeKing ♠', coins: 154500, winRate: '72%'),
      const LeaderboardPlayer(name: 'NeonTrump', coins: 89000, winRate: '68%'),
      const LeaderboardPlayer(name: 'KaaliMaster', coins: 64200, winRate: '61%'),
      const LeaderboardPlayer(name: 'TeeggiWrecker', coins: 45000, winRate: '59%'),
      const LeaderboardPlayer(name: 'GlitchDealer', coins: 32400, winRate: '58%'),
      const LeaderboardPlayer(name: 'PixelTricks', coins: 21800, winRate: '56%'),
      const LeaderboardPlayer(name: 'VoltCaster', coins: 15600, winRate: '54%'),
      const LeaderboardPlayer(name: 'CyberBids', coins: 12500, winRate: '52%'),
      const LeaderboardPlayer(name: 'AlphaCardist', coins: 9800, winRate: '50%'),
      const LeaderboardPlayer(name: 'StarterDeck', coins: 4200, winRate: '45%'),
    ];

    // Add user to the list
    final userWinRate = stats.gamesPlayed > 0 
        ? '${(stats.gamesWon / stats.gamesPlayed * 100).toStringAsFixed(0)}%'
        : '0%';
        
    globalPlayers.add(LeaderboardPlayer(
      name: '${stats.name} (You)',
      coins: stats.coins,
      winRate: userWinRate,
      isUser: true,
    ));

    // Sort list by coins descending
    globalPlayers.sort((a, b) => b.coins.compareTo(a.coins));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: GameTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header row
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: GameTheme.textWhite),
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'GLOBAL LEADERBOARD',
                      style: TextStyle(
                        color: GameTheme.textWhite,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: GameTheme.neonCyan.withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: GameTheme.goldAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: GameTheme.goldAccent.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.stars, color: GameTheme.goldAccent, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '${stats.coins} COINS',
                            style: const TextStyle(
                              color: GameTheme.goldAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(width: 40, child: Text('RANK', style: TextStyle(color: GameTheme.textGrey, fontSize: 11, fontWeight: FontWeight.bold))),
                      Expanded(child: Text('PLAYER', style: TextStyle(color: GameTheme.textGrey, fontSize: 11, fontWeight: FontWeight.bold))),
                      SizedBox(width: 100, child: Text('COINS', textAlign: TextAlign.right, style: TextStyle(color: GameTheme.textGrey, fontSize: 11, fontWeight: FontWeight.bold))),
                      SizedBox(width: 80, child: Text('WIN RATE', textAlign: TextAlign.right, style: TextStyle(color: GameTheme.textGrey, fontSize: 11, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Leaderboard List
                Expanded(
                  child: ListView.builder(
                    itemCount: globalPlayers.length,
                    itemBuilder: (context, index) {
                      final player = globalPlayers[index];
                      final rank = index + 1;
                      
                      // Theme-specific styles
                      Color rowBorderColor = Colors.white.withValues(alpha: 0.04);
                      Color rowBgColor = Colors.white.withValues(alpha: 0.01);
                      Widget rankWidget = Text(
                        '#$rank',
                        style: TextStyle(
                          color: player.isUser ? GameTheme.neonGreen : GameTheme.textGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      );

                      if (rank == 1) {
                        rowBorderColor = GameTheme.goldAccent.withValues(alpha: 0.3);
                        rowBgColor = GameTheme.goldAccent.withValues(alpha: 0.02);
                        rankWidget = const Icon(Icons.emoji_events_rounded, color: GameTheme.goldAccent, size: 22);
                      } else if (rank == 2) {
                        rowBorderColor = Colors.grey.withValues(alpha: 0.3);
                        rowBgColor = Colors.grey.withValues(alpha: 0.02);
                        rankWidget = const Icon(Icons.emoji_events_rounded, color: Colors.grey, size: 20);
                      } else if (rank == 3) {
                        rowBorderColor = Colors.brown.withValues(alpha: 0.4);
                        rowBgColor = Colors.brown.withValues(alpha: 0.02);
                        rankWidget = const Icon(Icons.emoji_events_rounded, color: Colors.brown, size: 18);
                      }

                      if (player.isUser) {
                        rowBorderColor = GameTheme.neonCyan.withValues(alpha: 0.6);
                        rowBgColor = GameTheme.neonCyan.withValues(alpha: 0.05);
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: rowBgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: rowBorderColor),
                          boxShadow: player.isUser 
                              ? GameTheme.neonGlow(GameTheme.neonCyan, blurRadius: 8)
                              : null,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                              child: rankWidget,
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  if (player.isUser) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: GameTheme.neonCyan.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: GameTheme.neonCyan.withValues(alpha: 0.4)),
                                      ),
                                      child: const Text(
                                        'YOU',
                                        style: TextStyle(color: GameTheme.neonCyan, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                  Text(
                                    player.name,
                                    style: TextStyle(
                                      color: player.isUser ? GameTheme.neonCyan : GameTheme.textWhite,
                                      fontWeight: player.isUser ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(
                                player.coins.toString(),
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: rank == 1 ? GameTheme.goldAccent : GameTheme.textWhite,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(
                                player.winRate,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: GameTheme.textGrey,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }
}
