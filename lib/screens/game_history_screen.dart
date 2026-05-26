import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../providers/stats_provider.dart';

/// Displays a scrollable, filterable log of the last 50 completed matches.
class GameHistoryScreen extends ConsumerStatefulWidget {
  const GameHistoryScreen({super.key});

  @override
  ConsumerState<GameHistoryScreen> createState() => _GameHistoryScreenState();
}

enum _HistoryFilter { all, wins, losses }

class _GameHistoryScreenState extends ConsumerState<GameHistoryScreen> {
  _HistoryFilter _filter = _HistoryFilter.all;

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(gameHistoryProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: GameTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildFilterTabs(),
              Expanded(
                child: historyAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: GameTheme.neonCyan),
                  ),
                  error: (e, _) => Center(
                    child: Text(
                      'Failed to load history',
                      style: TextStyle(color: GameTheme.textGrey),
                    ),
                  ),
                  data: (history) => _buildHistoryList(history),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => context.go('/home'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: GameTheme.textWhite,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Match History',
                  style: TextStyle(
                    color: GameTheme.textWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Your last 50 completed games',
                  style: TextStyle(
                    color: GameTheme.textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: _HistoryFilter.values.map((f) {
          final isSelected = _filter == f;
          final label = switch (f) {
            _HistoryFilter.all => 'All',
            _HistoryFilter.wins => 'Wins',
            _HistoryFilter.losses => 'Losses',
          };
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? GameTheme.neonCyan.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? GameTheme.neonCyan.withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? GameTheme.neonCyan : GameTheme.textGrey,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHistoryList(List<GameRecord> allRecords) {
    final filtered = allRecords.where((r) {
      return switch (_filter) {
        _HistoryFilter.all => true,
        _HistoryFilter.wins => r.won,
        _HistoryFilter.losses => !r.won,
      };
    }).toList();

    if (filtered.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _buildRecordCard(filtered[index]),
    );
  }

  Widget _buildEmptyState() {
    final isFiltered = _filter != _HistoryFilter.all;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: GameTheme.neonCyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: GameTheme.neonCyan.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              isFiltered ? Icons.filter_list_off_rounded : Icons.history_rounded,
              color: GameTheme.neonCyan,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isFiltered ? 'No ${_filter.name} found' : 'No games yet',
            style: const TextStyle(
              color: GameTheme.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isFiltered
                ? 'Try switching to "All" to see your full history.'
                : "Play your first game and your results will appear here!",
            textAlign: TextAlign.center,
            style: const TextStyle(color: GameTheme.textGrey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(GameRecord record) {
    final won = record.won;
    final accentColor = won ? GameTheme.neonCyan : GameTheme.neonPink;
    final coinsText =
        record.coinsChange >= 0 ? '+${record.coinsChange}' : '${record.coinsChange}';
    final coinsColor = record.coinsChange >= 0 ? GameTheme.neonCyan : GameTheme.neonPink;

    // Format date
    String formattedDate = 'Unknown date';
    try {
      final dt = DateTime.parse(record.dateTime).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays == 0) {
        formattedDate = 'Today ${_formatTime(dt)}';
      } else if (diff.inDays == 1) {
        formattedDate = 'Yesterday ${_formatTime(dt)}';
      } else {
        formattedDate =
            '${dt.day}/${dt.month}/${dt.year} ${_formatTime(dt)}';
      }
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Win/Loss badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentColor.withValues(alpha: 0.4)),
              ),
              child: Center(
                child: Text(
                  won ? 'W' : 'L',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Game details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    won ? 'Victory' : 'Defeat',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'vs ${record.opponentNames.take(3).join(', ')}',
                    style: const TextStyle(
                      color: GameTheme.textGrey,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: GameTheme.textGrey.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            // Right side stats
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  coinsText,
                  style: TextStyle(
                    color: coinsColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${record.tricksTaken} pts',
                  style: const TextStyle(
                    color: GameTheme.textGrey,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: GameTheme.goldAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Bid: ${record.bid}',
                    style: const TextStyle(
                      color: GameTheme.goldAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
