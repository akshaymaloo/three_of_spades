import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/stats_provider.dart';
import '../providers/game_notifier.dart';
import '../widgets/glass_dialog.dart';
import 'matchmaking_screen.dart';
import 'private_room_screen.dart';
import 'leaderboard_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showSettings(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        final game = ref.watch(gameProvider);
        return GlassDialog(
          title: 'Settings',
          glowColor: GameTheme.neonCyan,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sound toggle
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Sound Effects', style: TextStyle(color: GameTheme.textWhite)),
                trailing: Switch(
                  value: game.soundEnabled,
                  activeColor: GameTheme.neonCyan,
                  onChanged: (val) {
                    ref.read(gameProvider.notifier).toggleSound();
                  },
                ),
              ),
              const Divider(color: Colors.white10),
              const SizedBox(height: 12),
              // Reset stats button
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (subContext) => GlassDialog(
                      title: 'Reset Stats?',
                      glowColor: GameTheme.neonPink,
                      content: const Text(
                        'This will reset your coins back to 5,000 and wipe out your win history. This action is irreversible.',
                        style: TextStyle(color: GameTheme.textWhite, fontSize: 14),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(subContext),
                          child: const Text('CANCEL', style: TextStyle(color: GameTheme.textGrey)),
                        ),
                        TextButton(
                          onPressed: () {
                            ref.read(statsProvider.notifier).resetStats();
                            Navigator.pop(subContext); // pop confirm
                            Navigator.pop(context); // pop settings
                          },
                          child: const Text('RESET', style: TextStyle(color: GameTheme.neonPink, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: GameTheme.neonPink.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restore_outlined, color: GameTheme.neonPink, size: 20),
                      SizedBox(width: 8),
                      Text('RESET GUEST STATS', style: TextStyle(color: GameTheme.neonPink, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final winRate = stats.gamesPlayed > 0 
        ? '${(stats.gamesWon / stats.gamesPlayed * 100).toStringAsFixed(1)}%'
        : '0.0%';

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: GameTheme.neonCyan, width: 1.5),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/guest_avatar.png'),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: GameTheme.neonGlow(GameTheme.neonCyan, blurRadius: 6),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stats.name,
                              style: const TextStyle(
                                color: GameTheme.textWhite,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.stars, color: GameTheme.goldAccent, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${stats.coins.toString()} COINS',
                                  style: const TextStyle(
                                    color: GameTheme.goldAccent,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.settings, color: GameTheme.textWhite, size: 24),
                          onPressed: () => _showSettings(context, ref),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.05),
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Main Stats dashboard
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Statistics Panel (Left)
                      Expanded(
                        flex: 4,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: GameTheme.glassDecoration(opacity: 0.03, borderOpacity: 0.08),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'STATISTICS',
                                style: TextStyle(
                                  color: GameTheme.neonCyan,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: GridView.count(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1.8,
                                  children: [
                                    _buildStatTile('Played', stats.gamesPlayed.toString(), Icons.play_arrow_rounded),
                                    _buildStatTile('Won', stats.gamesWon.toString(), Icons.emoji_events_rounded),
                                    _buildStatTile('Win Rate', winRate, Icons.percent_rounded),
                                    _buildStatTile('Best Bid', stats.highestBidWon > 0 ? stats.highestBidWon.toString() : '-', Icons.workspace_premium_rounded),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Game Modes Panel (Right)
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Offline game trigger (Active)
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  ref.read(gameProvider.notifier).startNewGame();
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        GameTheme.cardTableColor.withOpacity(0.3),
                                        GameTheme.cardTableColor.withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: GameTheme.neonGreen.withOpacity(0.3), width: 1.5),
                                    boxShadow: GameTheme.neonGlow(GameTheme.neonGreen, blurRadius: 10),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        right: -10,
                                        bottom: -10,
                                        child: Opacity(
                                          opacity: 0.15,
                                          child: Text(
                                            '♠',
                                            style: TextStyle(
                                              fontSize: 150,
                                              color: GameTheme.neonGreen,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(24.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: GameTheme.neonGreen.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: GameTheme.neonGreen.withOpacity(0.4)),
                                              ),
                                              child: const Text(
                                                'OFFLINE PLAY',
                                                style: TextStyle(
                                                  color: GameTheme.neonGreen,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                  letterSpacing: 1.2,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            const Text(
                                              'Play vs Intelligent Bots',
                                              style: TextStyle(
                                                color: GameTheme.textWhite,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              'Practice your bidding strategies and trick estimation with zero network wait times.',
                                              style: TextStyle(
                                                color: GameTheme.textGrey,
                                                fontSize: 12,
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
                            ),
                            const SizedBox(height: 16),

                            // Online / Mode features row
                            SizedBox(
                              height: 90,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildModeCard(
                                      context, 
                                      'ONLINE PLAY', 
                                      Icons.wifi_rounded,
                                      GameTheme.neonCyan,
                                      () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const MatchmakingScreen()),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildModeCard(
                                      context, 
                                      'PRIVATE ROOM', 
                                      Icons.vpn_key_rounded,
                                      Colors.purpleAccent,
                                      () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const PrivateRoomScreen()),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildModeCard(
                                      context, 
                                      'LEADERBOARD', 
                                      Icons.leaderboard_rounded,
                                      GameTheme.goldAccent,
                                      () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: GameTheme.neonCyan.withOpacity(0.08),
            ),
            child: Icon(icon, color: GameTheme.neonCyan, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: GameTheme.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: GameTheme.textGrey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard(BuildContext context, String title, IconData icon, Color glowColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: glowColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(0.05),
              blurRadius: 6,
              spreadRadius: 1,
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: glowColor, size: 22),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: GameTheme.textWhite,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: glowColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                title == 'LEADERBOARD' ? 'STATS' : 'LIVE',
                style: TextStyle(
                  color: glowColor,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
