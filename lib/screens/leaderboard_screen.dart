import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/stats_provider.dart';
import '../providers/service_providers.dart';
import '../services/leaderboard_service.dart';
import '../l10n/app_localizations.dart';

final leaderboardFetchProvider = FutureProvider.family<List<LeaderboardEntry>, LeaderboardPeriod>((ref, period) async {
  final service = ref.watch(leaderboardServiceProvider);
  return service.fetchTopPlayers(period: period, limit: 15);
});

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                          AppLocalizations.of(context)?.leaderboards.toUpperCase() ?? 'LEADERBOARDS',
                          style: const TextStyle(
                            color: GameTheme.textWhite,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
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
                                '${stats.coins} ${AppLocalizations.of(context)?.coins ?? 'COINS'}',
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
                    const SizedBox(height: 12),

                    // Tab selector
                    Container(
                      height: 48,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          gradient: GameTheme.neonCyanGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        labelColor: GameTheme.darkBackground,
                        unselectedLabelColor: GameTheme.textGrey,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        tabs: [
                          Tab(text: AppLocalizations.of(context)?.daily.toUpperCase() ?? 'DAILY'),
                          Tab(text: AppLocalizations.of(context)?.allTime.toUpperCase() ?? 'ALL-TIME'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Table Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 40, child: Text(AppLocalizations.of(context)?.rank.toUpperCase() ?? 'RANK', style: const TextStyle(color: GameTheme.textGrey, fontSize: 11, fontWeight: FontWeight.bold))),
                          Expanded(child: Text(AppLocalizations.of(context)?.player.toUpperCase() ?? 'PLAYER', style: const TextStyle(color: GameTheme.textGrey, fontSize: 11, fontWeight: FontWeight.bold))),
                          SizedBox(width: 100, child: Text(AppLocalizations.of(context)?.coins.toUpperCase() ?? 'COINS', textAlign: TextAlign.right, style: const TextStyle(color: GameTheme.textGrey, fontSize: 11, fontWeight: FontWeight.bold))),
                          SizedBox(width: 80, child: Text(AppLocalizations.of(context)?.gamesWon.toUpperCase() ?? 'GAMES WON', textAlign: TextAlign.right, style: const TextStyle(color: GameTheme.textGrey, fontSize: 11, fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Tab Views
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildLeaderboardList(LeaderboardPeriod.daily, stats),
                          _buildLeaderboardList(LeaderboardPeriod.allTime, stats),
                        ],
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

  Widget _buildLeaderboardList(LeaderboardPeriod period, UserStats stats) {
    final listAsync = ref.watch(leaderboardFetchProvider(period));

    return listAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: GameTheme.neonCyan),
      ),
      error: (err, stack) => Center(
        child: Text(AppLocalizations.of(context)?.failedToLoadLeaderboard(err.toString()) ?? 'Failed to load leaderboard: $err', style: const TextStyle(color: GameTheme.neonPink)),
      ),
      data: (entries) {
        // Build a sorted mutable list
        final displayEntries = List<LeaderboardEntry>.from(entries);

        // Check if user is present in display entries (comparing name)
        final userIndex = displayEntries.indexWhere((e) => e.name == stats.name);

        if (userIndex == -1) {
          // Add user at the correct position or bottom
          displayEntries.add(LeaderboardEntry(
            rank: displayEntries.length + 1,
            name: '${stats.name} (${AppLocalizations.of(context)?.you ?? 'You'})',
            coins: stats.coins,
            gamesWon: stats.gamesWon,
          ));
          // Re-sort
          displayEntries.sort((a, b) => b.coins.compareTo(a.coins));
        }

        if (displayEntries.isEmpty) {
          return Center(
            child: Text(AppLocalizations.of(context)?.noEntries ?? 'No leaderboard entries yet.', style: const TextStyle(color: GameTheme.textGrey)),
          );
        }

        return ListView.builder(
          itemCount: displayEntries.length,
          itemBuilder: (context, index) {
            final entry = displayEntries[index];
            final rank = index + 1;
            final isUser = entry.name == stats.name || entry.name.contains('(You)');

            Color rowBorderColor = Colors.white.withValues(alpha: 0.04);
            Color rowBgColor = Colors.white.withValues(alpha: 0.01);
            Widget rankWidget = Text(
              '#$rank',
              style: TextStyle(
                color: isUser ? GameTheme.neonGreen : GameTheme.textGrey,
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

            if (isUser) {
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
                boxShadow: isUser 
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
                        if (isUser) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: GameTheme.neonCyan.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: GameTheme.neonCyan.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              AppLocalizations.of(context)?.you.toUpperCase() ?? 'YOU',
                              style: const TextStyle(color: GameTheme.neonCyan, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        Text(
                          entry.name,
                          style: TextStyle(
                            color: isUser ? GameTheme.neonCyan : GameTheme.textWhite,
                            fontWeight: isUser ? FontWeight.bold : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: Text(
                      entry.coins.toString(),
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
                      entry.gamesWon.toString(),
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
        );
      },
    );
  }
}
