import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/stats_provider.dart';
import '../providers/game_notifier.dart';
import '../core/sound_manager.dart';
import '../widgets/glass_dialog.dart';
import '../providers/config_provider.dart';
import '../providers/daily_reward_provider.dart';
import '../providers/ad_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/daily_reward_dialog.dart';
import 'matchmaking_screen.dart';
import 'private_room_screen.dart';
import 'leaderboard_screen.dart';
import '../l10n/app_localizations.dart';
import '../widgets/credits_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/celebrity_model.dart';
import 'avatar_selection_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ProviderSubscription<AsyncValue<UserStats>>? _statsSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _statsSubscription = ref.listenManual<AsyncValue<UserStats>>(
          statsProvider,
          (previous, next) {
            if (next is AsyncData<UserStats>) {
              final stats = next.value;
              SoundManager().setEnabled(stats.soundEnabled);
              SoundManager().setMusicEnabled(stats.musicEnabled);
              if (stats.musicEnabled && stats.soundEnabled) {
                SoundManager().playBackgroundMusic();
              }
            }
          },
          fireImmediately: true,
        );
        _checkDailyReward();
      }
    });
  }

  void _checkDailyReward() {
    final rewardState = ref.read(dailyRewardProvider);
    if (!rewardState.todayClaimed) {
      DailyRewardDialog.show(
        context,
        onClaim: (amount) {
          ref.read(statsProvider.notifier).addCoins(amount);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)?.claimedDailyReward(amount) ?? '🎁 Claimed $amount daily reward coins!'),
              backgroundColor: GameTheme.goldAccent,
            ),
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _statsSubscription?.close();
    super.dispose();
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final statsAsync = ref.watch(statsProvider);
            return statsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: GameTheme.neonCyan),
              ),
              error: (err, stack) => Center(
                child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
              ),
              data: (stats) {
                return GlassDialog(
                  title: AppLocalizations.of(context)?.settings ?? 'Settings',
                  glowColor: GameTheme.neonCyan,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Language toggle
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(AppLocalizations.of(context)?.language ?? 'Language', style: const TextStyle(color: GameTheme.textWhite)),
                        trailing: DropdownButton<String>(
                          value: stats.languageCode,
                          dropdownColor: GameTheme.darkBackground,
                          style: const TextStyle(color: GameTheme.neonCyan),
                          underline: const SizedBox(),
                          items: [
                            DropdownMenuItem(value: 'en', child: Text(AppLocalizations.of(context)?.english ?? 'English')),
                            DropdownMenuItem(value: 'hi', child: Text(AppLocalizations.of(context)?.hindi ?? 'Hindi')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(statsProvider.notifier).updateLanguage(val);
                            }
                          },
                        ),
                      ),
                      const Divider(color: Colors.white10),
                      // Sound toggle
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(AppLocalizations.of(context)?.soundEffects ?? 'Sound Effects', style: const TextStyle(color: GameTheme.textWhite)),
                        trailing: Switch(
                          value: stats.soundEnabled,
                          activeThumbColor: GameTheme.neonCyan,
                          onChanged: (val) {
                            ref.read(statsProvider.notifier).toggleSound(val);
                            ref.read(gameProvider.notifier).toggleSound(val);
                          },
                        ),
                      ),
                      const Divider(color: Colors.white10),
                      // Music toggle
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(AppLocalizations.of(context)?.backgroundMusic ?? 'Background Music', style: const TextStyle(color: GameTheme.textWhite)),
                        trailing: Switch(
                          value: stats.musicEnabled,
                          activeThumbColor: GameTheme.neonCyan,
                          onChanged: (val) {
                            ref.read(statsProvider.notifier).toggleMusic(val);
                          },
                        ),
                      ),
                      const Divider(color: Colors.white10),
                      // Vibration toggle
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Vibration', style: const TextStyle(color: GameTheme.textWhite)),
                        trailing: Switch(
                          value: stats.vibrationEnabled,
                          activeThumbColor: GameTheme.neonCyan,
                          onChanged: (val) {
                            ref.read(statsProvider.notifier).toggleVibration(val);
                          },
                        ),
                      ),
                      const Divider(color: Colors.white10),
                      // TTS toggle
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Read Events Aloud', style: const TextStyle(color: GameTheme.textWhite)),
                        trailing: Switch(
                          value: stats.ttsEnabled,
                          activeThumbColor: GameTheme.neonCyan,
                          onChanged: (val) {
                            ref.read(statsProvider.notifier).toggleTts(val);
                          },
                        ),
                      ),
                      const Divider(color: Colors.white10),
                      // Table Theme toggle
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Table Theme', style: const TextStyle(color: GameTheme.textWhite)),
                        trailing: DropdownButton<String>(
                          value: stats.tableTheme,
                          dropdownColor: GameTheme.darkBackground,
                          style: const TextStyle(color: GameTheme.neonCyan),
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 'green', child: Text('Classic Green')),
                            DropdownMenuItem(value: 'blue', child: Text('Royal Blue')),
                            DropdownMenuItem(value: 'red', child: Text('Casino Red')),
                            DropdownMenuItem(value: 'purple', child: Text('Majestic Purple')),
                            DropdownMenuItem(value: 'brown', child: Text('Wood Brown')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(statsProvider.notifier).setTableTheme(val);
                            }
                          },
                        ),
                      ),
                      const Divider(color: Colors.white10),
                      // Online Mode toggle
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(AppLocalizations.of(context)?.onlineModeFirebase ?? 'Online Mode (Firebase)', style: const TextStyle(color: GameTheme.textWhite)),
                        subtitle: Text(
                          ref.watch(configProvider).onlineMode 
                              ? (AppLocalizations.of(context)?.onlineModeActive ?? 'Active (Needs Firebase setup)') 
                              : (AppLocalizations.of(context)?.onlineModeOffline ?? 'Simulation / Offline Only'),
                          style: const TextStyle(color: GameTheme.textGrey, fontSize: 11),
                        ),
                        trailing: Switch(
                          value: ref.watch(configProvider).onlineMode,
                          activeThumbColor: GameTheme.neonCyan,
                          onChanged: (val) async {
                            await ref.read(configProvider.notifier).toggleOnlineMode();
                            if (context.mounted) {
                              final currentMode = ref.read(configProvider).onlineMode;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    currentMode
                                        ? (AppLocalizations.of(context)?.switchedOnlineMode ?? 'Switched to Online Mode! Needs Firebase config.')
                                        : (AppLocalizations.of(context)?.switchedOfflineMode ?? 'Switched to Simulation Mode (Offline/Mock).'),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const Divider(color: Colors.white10),
                      // Push Notifications toggle
                      if (ref.watch(configProvider).onlineMode) ...[
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(AppLocalizations.of(context)?.pushNotifications ?? 'Push Notifications', style: const TextStyle(color: GameTheme.textWhite)),
                          subtitle: Text(AppLocalizations.of(context)?.pushNotificationsSubtitle ?? 'Get room invites and updates', style: const TextStyle(color: GameTheme.textGrey, fontSize: 11)),
                          trailing: Switch(
                            value: ref.watch(notificationProvider).notificationsEnabled,
                            activeThumbColor: GameTheme.neonCyan,
                            onChanged: (val) {
                              ref.read(notificationProvider.notifier).toggleNotifications();
                            },
                          ),
                        ),
                        const Divider(color: Colors.white10),
                      ],
                      const SizedBox(height: 12),
                      // Reset stats button
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (subContext) => GlassDialog(
                              title: AppLocalizations.of(context)?.resetStatsTitle ?? 'Reset Stats?',
                              glowColor: GameTheme.neonPink,
                              content: Text(
                                AppLocalizations.of(context)?.resetStatsBody ?? 'This will reset your coins back to 5,000 and wipe out your win history. This action is irreversible.',
                                style: const TextStyle(color: GameTheme.textWhite, fontSize: 14),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(subContext),
                                  child: Text(AppLocalizations.of(context)?.cancel ?? 'CANCEL', style: const TextStyle(color: GameTheme.textGrey)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ref.read(statsProvider.notifier).resetStats();
                                    Navigator.pop(subContext); // pop confirm
                                    Navigator.pop(context); // pop settings
                                  },
                                  child: Text(AppLocalizations.of(context)?.reset ?? 'RESET', style: const TextStyle(color: GameTheme.neonPink, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: GameTheme.neonPink.withValues(alpha: 0.5)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.restore_outlined, color: GameTheme.neonPink, size: 20),
                              const SizedBox(width: 8),
                              Text(AppLocalizations.of(context)?.resetGuestStats ?? 'RESET GUEST STATS', style: const TextStyle(color: GameTheme.neonPink, fontWeight: FontWeight.bold)),
                            ],
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
      },
    );
  }

  void _showNameEditor(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) {
        return GlassDialog(
          title: AppLocalizations.of(context)?.editNameTitle ?? 'Edit Name',
          glowColor: GameTheme.neonCyan,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)?.editNameSubtitle ?? 'Enter your alias:',
                style: const TextStyle(color: GameTheme.textGrey, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(color: GameTheme.textWhite),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)?.alias ?? 'Alias',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: GameTheme.neonCyan.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: GameTheme.neonCyan),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLength: 15,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)?.cancel ?? 'CANCEL', style: const TextStyle(color: GameTheme.textGrey)),
            ),
            TextButton(
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  ref.read(statsProvider.notifier).updateName(newName);
                }
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)?.save ?? 'SAVE', style: const TextStyle(color: GameTheme.neonCyan, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(statsProvider);
    final config = ref.watch(configProvider);
    final avatar = ref.watch(avatarProvider);
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
        final winRate = stats.gamesPlayed > 0 
            ? '${(stats.gamesWon / stats.gamesPlayed * 100).toStringAsFixed(1)}%'
            : '0.0%';

        final size = MediaQuery.of(context).size;
        final bool isWide = size.width >= 750 && size.height >= 600;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: GameTheme.backgroundGradient,
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1000,
                    maxHeight: 700,
                  ),
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
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const AvatarSelectionScreen()),
                                    );
                                  },
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: GameTheme.neonCyan, width: 1.5),
                                      boxShadow: GameTheme.neonGlow(GameTheme.neonCyan, blurRadius: 6),
                                    ),
                                    child: avatar != null && avatar.imageUrl.startsWith('http')
                                        ? CachedNetworkImage(
                                            imageUrl: avatar.imageUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: GameTheme.neonCyan, strokeWidth: 2)),
                                            errorWidget: (context, url, error) => Image.asset('assets/images/guest_avatar.png', fit: BoxFit.cover),
                                          )
                                        : Image.asset(avatar != null ? avatar.imageUrl : 'assets/images/guest_avatar.png', fit: BoxFit.cover),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () => _showNameEditor(context, stats.name),
                                      behavior: HitTestBehavior.opaque,
                                      child: Row(
                                        children: [
                                          Text(
                                            stats.name,
                                            style: const TextStyle(
                                              color: GameTheme.textWhite,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(
                                            Icons.edit_rounded,
                                            color: GameTheme.neonCyan,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.stars, color: GameTheme.goldAccent, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${stats.coins.toString()} ${AppLocalizations.of(context)?.coins ?? 'COINS'}',
                                          style: const TextStyle(
                                            color: GameTheme.goldAccent,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        InkWell(
                                          onTap: () async {
                                            final reward = await ref.read(adProvider.notifier).showRewardedAd();
                                            if (reward > 0) {
                                              await ref.read(statsProvider.notifier).addCoins(reward);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(AppLocalizations.of(context)?.earnedCoins(reward) ?? '🪙 Earned $reward coins!'),
                                                    backgroundColor: GameTheme.neonGreen,
                                                  ),
                                                );
                                              }
                                            } else {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(AppLocalizations.of(context)?.adFailed ?? 'Ad failed or skipped'),
                                                    backgroundColor: GameTheme.neonPink,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          borderRadius: BorderRadius.circular(12),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: GameTheme.neonCyan.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: GameTheme.neonCyan.withValues(alpha: 0.3)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.play_circle_outline, color: GameTheme.neonCyan, size: 12),
                                                const SizedBox(width: 2),
                                                Text(
                                                  '+500 ${AppLocalizations.of(context)?.coins ?? 'COINS'}',
                                                  style: const TextStyle(
                                                    color: GameTheme.neonCyan,
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
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
                                  icon: const Icon(Icons.info_outline, color: GameTheme.textWhite, size: 24),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => const CreditsDialog(),
                                    );
                                  },
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                                    padding: const EdgeInsets.all(12),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.settings, color: GameTheme.textWhite, size: 24),
                                  onPressed: () => _showSettings(context),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                                    padding: const EdgeInsets.all(12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Main Stats dashboard
                        isWide
                            ? SizedBox(
                                height: 320,
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
                                            Text(
                                              AppLocalizations.of(context)?.statistics.toUpperCase() ?? 'STATISTICS',
                                              style: const TextStyle(
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
                                                physics: const NeverScrollableScrollPhysics(),
                                                children: [
                                                  _buildStatTile(AppLocalizations.of(context)?.played ?? 'Played', stats.gamesPlayed.toString(), Icons.play_arrow_rounded),
                                                  _buildStatTile(AppLocalizations.of(context)?.won ?? 'Won', stats.gamesWon.toString(), Icons.emoji_events_rounded),
                                                  _buildStatTile(AppLocalizations.of(context)?.winRate ?? 'Win Rate', winRate, Icons.percent_rounded),
                                                  _buildStatTile(AppLocalizations.of(context)?.bestBid ?? 'Best Bid', stats.highestBidWon > 0 ? stats.highestBidWon.toString() : '-', Icons.workspace_premium_rounded),
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
                                          Expanded(
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                Expanded(child: _buildIntelligentBotsCard(context)),
                                                const SizedBox(width: 12),
                                                Expanded(child: _build7PlayersCard(context)),
                                              ],
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
                                                    AppLocalizations.of(context)?.onlinePlay.toUpperCase() ?? 'ONLINE PLAY', 
                                                    Icons.wifi_rounded,
                                                    GameTheme.neonCyan,
                                                    config.onlineMode,
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
                                                    AppLocalizations.of(context)?.privateRoom.toUpperCase() ?? 'PRIVATE ROOM', 
                                                    Icons.vpn_key_rounded,
                                                    Colors.purpleAccent,
                                                    config.onlineMode,
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
                                                    AppLocalizations.of(context)?.trainingMode?.toUpperCase() ?? 'TRAINING', 
                                                    Icons.school_rounded,
                                                    GameTheme.neonPink,
                                                    true,
                                                    () {
                                                      ref.read(gameProvider.notifier).startTrainingGame();
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: _buildModeCard(
                                                    context, 
                                                    AppLocalizations.of(context)?.leaderboard.toUpperCase() ?? 'LEADERBOARD', 
                                                    Icons.leaderboard_rounded,
                                                    GameTheme.goldAccent,
                                                    true,
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
                              )
                            : Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Statistics Panel (Top)
                                      Container(
                                        height: 190,
                                        padding: const EdgeInsets.all(16),
                                        decoration: GameTheme.glassDecoration(opacity: 0.03, borderOpacity: 0.08),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)?.statistics.toUpperCase() ?? 'STATISTICS',
                                              style: const TextStyle(
                                                color: GameTheme.neonCyan,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Expanded(
                                              child: GridView.count(
                                                crossAxisCount: 2,
                                                crossAxisSpacing: 10,
                                                mainAxisSpacing: 10,
                                                childAspectRatio: 2.2,
                                                physics: const NeverScrollableScrollPhysics(),
                                                children: [
                                                  _buildStatTile(AppLocalizations.of(context)?.played ?? 'Played', stats.gamesPlayed.toString(), Icons.play_arrow_rounded),
                                                  _buildStatTile(AppLocalizations.of(context)?.won ?? 'Won', stats.gamesWon.toString(), Icons.emoji_events_rounded),
                                                  _buildStatTile(AppLocalizations.of(context)?.winRate ?? 'Win Rate', winRate, Icons.percent_rounded),
                                                  _buildStatTile(AppLocalizations.of(context)?.bestBid ?? 'Best Bid', stats.highestBidWon > 0 ? stats.highestBidWon.toString() : '-', Icons.workspace_premium_rounded),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // Intelligent Bots Card (Middle)
                                      SizedBox(
                                        height: 150,
                                        child: _buildIntelligentBotsCard(context),
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        height: 140,
                                        child: _build7PlayersCard(context),
                                      ),
                                      const SizedBox(height: 16),
                                      // Bottom Game Modes (Bottom)
                                      SizedBox(
                                        height: 90,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: _buildModeCard(
                                                context, 
                                                AppLocalizations.of(context)?.onlinePlay.toUpperCase() ?? 'ONLINE PLAY', 
                                                Icons.wifi_rounded,
                                                GameTheme.neonCyan,
                                                config.onlineMode,
                                                () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => const MatchmakingScreen()),
                                                  );
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: _buildModeCard(
                                                context, 
                                                AppLocalizations.of(context)?.privateRoom.toUpperCase() ?? 'PRIVATE ROOM', 
                                                Icons.vpn_key_rounded,
                                                Colors.purpleAccent,
                                                config.onlineMode,
                                                () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => const PrivateRoomScreen()),
                                                  );
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: _buildModeCard(
                                                context, 
                                                AppLocalizations.of(context)?.leaderboard.toUpperCase() ?? 'LEADERBOARD', 
                                                Icons.leaderboard_rounded,
                                                GameTheme.goldAccent,
                                                true,
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _build7PlayersCard(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context)?.sevenPlayerMode ?? '7 Players',
      button: true,
      child: InkWell(
        onTap: () {
          ref.read(gameProvider.notifier).startNewGame(playerCount: 7);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                GameTheme.neonPink.withValues(alpha: 0.3),
                GameTheme.neonPink.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: GameTheme.neonPink.withValues(alpha: 0.3), width: 1.5),
            boxShadow: GameTheme.neonGlow(GameTheme.neonPink, blurRadius: 10),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                bottom: -10,
                child: Opacity(
                  opacity: 0.15,
                  child: const Text(
                    '7',
                    style: TextStyle(
                      fontSize: 150,
                      color: GameTheme.neonPink,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: GameTheme.neonPink.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          AppLocalizations.of(context)?.sevenPlayerModeBadge ?? '2 Decks · 7 Players',
                          style: const TextStyle(
                            color: GameTheme.neonPink,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)?.sevenPlayerMode ?? '7 Players\nEpic Mode',
                        style: const TextStyle(
                          color: GameTheme.textWhite,
                          fontSize: 22,
                          height: 1.1,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)?.sevenPlayerModeDesc ?? 'Play against 6 bots with 104 cards and 2 partners!',
                        style: const TextStyle(
                          color: GameTheme.textGrey,
                          fontSize: 12,
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
    );
  }

  Widget _buildIntelligentBotsCard(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context)?.playVsIntelligentBots ?? 'Play vs Intelligent Bots',
      button: true,
      child: InkWell(
        onTap: () {
          ref.read(gameProvider.notifier).startNewGame();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                GameTheme.cardTableColor.withValues(alpha: 0.3),
                GameTheme.cardTableColor.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: GameTheme.neonGreen.withValues(alpha: 0.3), width: 1.5),
            boxShadow: GameTheme.neonGlow(GameTheme.neonGreen, blurRadius: 10),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                bottom: -10,
                child: Opacity(
                  opacity: 0.15,
                  child: const Text(
                    '♠',
                    style: TextStyle(
                      fontSize: 150,
                      color: GameTheme.neonGreen,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: GameTheme.neonGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: GameTheme.neonGreen.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          AppLocalizations.of(context)?.offlinePlay.toUpperCase() ?? 'OFFLINE PLAY',
                          style: const TextStyle(
                            color: GameTheme.neonGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(context)?.playVsIntelligentBots ?? 'Play vs Intelligent Bots',
                        style: const TextStyle(
                          color: GameTheme.textWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLocalizations.of(context)?.practiceBiddingDesc ?? 'Practice your bidding strategies and trick estimation with zero network wait times.',
                        style: const TextStyle(
                          color: GameTheme.textGrey,
                          fontSize: 11,
                          height: 1.2,
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
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: GameTheme.neonCyan.withValues(alpha: 0.08),
            ),
            child: Icon(icon, color: GameTheme.neonCyan, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: GameTheme.textWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: GameTheme.textGrey,
                    fontSize: 10,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context,
    String title,
    IconData icon,
    Color glowColor,
    bool enabled,
    VoidCallback onTap,
  ) {
    final finalColor = enabled ? glowColor : GameTheme.textGrey;
    return Semantics(
      label: title,
      button: true,
      child: InkWell(
        onTap: enabled
            ? onTap
            : () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)?.enableOnlineToPlay ?? 'Enable Online Mode in Settings to play online.'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: finalColor.withValues(alpha: 0.2)),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: finalColor.withValues(alpha: 0.05),
                      blurRadius: 6,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: finalColor, size: 22),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: enabled ? GameTheme.textWhite : GameTheme.textGrey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: finalColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  icon == Icons.leaderboard_rounded
                      ? (AppLocalizations.of(context)?.stats.toUpperCase() ?? 'STATS')
                      : (enabled 
                          ? (AppLocalizations.of(context)?.live.toUpperCase() ?? 'LIVE') 
                          : (AppLocalizations.of(context)?.offline.toUpperCase() ?? 'OFFLINE')),
                  style: TextStyle(
                    color: finalColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
     ),
    );
  }
}
