import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../models/game_state.dart';
import '../providers/game_notifier.dart';
import '../providers/multiplayer_notifier.dart';
import '../widgets/bidding_overlay.dart';
import '../widgets/chat_panel.dart';
import '../widgets/dealing_animation.dart';
import '../widgets/declaring_overlay.dart';
import '../widgets/game_table.dart';
import '../widgets/game_top_bar.dart';
import '../widgets/player_hand_panel.dart';
import '../widgets/scoreboard_overlay.dart';
import '../l10n/app_localizations.dart';
import '../core/localization_helper.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _isChatOpen = false;
  int _lastSeenMessageCount = 0;

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final multiplayerState = ref.watch(multiplayerProvider);

    // Listen to changes in game status message and announce them
    ref.listen<String>(
      gameProvider.select((s) => s.message),
      (previous, next) {
        if (next.isNotEmpty) {
          final localizedMsg = getLocalizedGameMessage(context, next);
          SemanticsService.announce(localizedMsg, TextDirection.ltr);
        }
      },
    );

    // Auto-update message count when chat is open
    if (_isChatOpen && multiplayerState.chatMessages.length > _lastSeenMessageCount) {
      _lastSeenMessageCount = multiplayerState.chatMessages.length;
    }

    final size = MediaQuery.of(context).size;
    final isTooNarrow = size.width < 600 || size.height < 360;

    if (isTooNarrow) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: GameTheme.backgroundGradient),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.screen_rotation_rounded, color: GameTheme.neonPink, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)?.landscapeRequired ?? 'Landscape Mode Required',
                    style: const TextStyle(color: GameTheme.textWhite, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)?.rotateDeviceDesc ?? 'Please rotate your device or widen your browser window to play.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: GameTheme.textGrey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final humanPlayer = game.players[0];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: GameTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main Table & Seats
              Column(
                children: [
                  // Upper status bar
                  GameTopBar(
                    game: game,
                    isChatOpen: _isChatOpen,
                    lastSeenMessageCount: _lastSeenMessageCount,
                    onChatPressed: () {
                      setState(() {
                        _isChatOpen = true;
                        _lastSeenMessageCount = ref.read(multiplayerProvider).chatMessages.length;
                      });
                    },
                  ),
                  
                  // Status message banner (integrated, non-overlapping)
                  _buildStatusBanner(game),
                  
                  // Central Card Table Area
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GameTable(game: game),
                    ),
                  ),

                  // Bottom HUD: User Cards
                  PlayerHandPanel(
                    game: game,
                    humanPlayer: humanPlayer,
                  ),
                ],
              ),

              // Dealing Animation Overlay
              if (game.phase == GamePhase.dealing)
                DealingAnimation(
                  onComplete: () {
                    ref.read(gameProvider.notifier).completeDealing();
                  },
                ),

              // Bidding Control Overlay in the center
              if (game.phase == GamePhase.bidding && game.activePlayerIndex == 0)
                BiddingOverlay(game: game),

              // Trump and Partner Declaration Overlay
              if (game.phase == GamePhase.declaring && game.activePlayerIndex == 0)
                DeclaringOverlay(humanPlayer: humanPlayer),

              // Game Over / Round Over Scoreboard Overlay
              if (game.phase == GamePhase.roundOver)
                ScoreboardOverlay(game: game),

              // Chat Slide Drawer Overlay
              if (game.isMultiplayer)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  right: _isChatOpen ? 0 : -300,
                  top: 0,
                  bottom: 0,
                  child: ChatPanel(
                    onClose: () {
                      setState(() {
                        _isChatOpen = false;
                        _lastSeenMessageCount = ref.read(multiplayerProvider).chatMessages.length;
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(GamePhase phase) {
    switch (phase) {
      case GamePhase.dealing:
        return Icons.style;
      case GamePhase.bidding:
        return Icons.gavel;
      case GamePhase.declaring:
        return Icons.campaign;
      case GamePhase.playing:
        return Icons.play_circle_outline;
      case GamePhase.roundOver:
        return Icons.emoji_events;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildStatusBanner(GameState game) {
    final hasMessage = game.message.isNotEmpty;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      height: hasMessage ? 34 : 0,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: hasMessage
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getStatusIcon(game.phase),
                    size: 14,
                    color: GameTheme.goldAccent,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      getLocalizedGameMessage(context, game.message),
                      style: const TextStyle(
                        color: GameTheme.textWhite,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
