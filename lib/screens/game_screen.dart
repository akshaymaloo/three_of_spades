import 'package:flutter/material.dart';
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
          child: const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.screen_rotation_rounded, color: GameTheme.neonPink, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Landscape Mode Required',
                    style: TextStyle(color: GameTheme.textWhite, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please rotate your device or widen your browser window to play.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: GameTheme.textGrey, fontSize: 13),
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

              // Game Status overlay messages
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: GameTheme.glassDecoration(opacity: 0.1, borderOpacity: 0.15, radius: 20),
                    child: Text(
                      game.message,
                      style: const TextStyle(
                        color: GameTheme.textWhite,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
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
}
