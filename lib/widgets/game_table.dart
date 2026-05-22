import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/player_model.dart';
import '../models/multiplayer_state.dart';
import '../core/theme.dart';
import '../core/suit_utils.dart';
import '../providers/multiplayer_notifier.dart';
import 'playing_card_widget.dart';

class GameTable extends ConsumerWidget {
  final GameState game;

  const GameTable({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Felt green table
        Container(
          width: size.width * 0.75,
          height: size.height * 0.52,
          decoration: BoxDecoration(
            gradient: GameTheme.tableGradient,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ],
          ),
        ),

        // Dotted center slot representing trick cards
        _buildTrickCenter(game),

        // Seat positions
        _buildSeat(context, ref, game.players[1], Alignment.centerLeft, game.activePlayerIndex == 1), // Left Bot
        _buildSeat(context, ref, game.players[2], Alignment.topCenter, game.activePlayerIndex == 2),  // Top Bot
        _buildSeat(context, ref, game.players[3], Alignment.centerRight, game.activePlayerIndex == 3), // Right Bot
        _buildSeat(context, ref, game.players[0], Alignment.bottomCenter, game.activePlayerIndex == 0), // Human (bottom)
      ],
    );
  }

  Widget _buildSeat(BuildContext context, WidgetRef ref, PlayerModel player, Alignment alignment, bool isActive) {
    final showGlow = isActive && (game.phase != GamePhase.roundOver);
    final shadowColor = showGlow ? GameTheme.neonCyan : Colors.transparent;

    // Status label below avatar
    String status = '';
    Color statusColor = GameTheme.textGrey;

    if (game.phase == GamePhase.bidding) {
      if (player.hasPassed) {
        status = 'PASSED';
        statusColor = GameTheme.neonPink;
      } else if (player.currentBid != null) {
        status = 'BID: ${player.currentBid}';
        statusColor = GameTheme.neonGreen;
      }
    } else if (game.phase == GamePhase.playing || game.phase == GamePhase.declaring || game.phase == GamePhase.roundOver) {
      if (player.isBidder) {
        status = 'BIDDER (${game.winningBid})';
        statusColor = GameTheme.neonCyan;
      } else if (player.isPartner && player.isPartnerRevealed) {
        status = 'PARTNER';
        statusColor = GameTheme.neonGreen;
      }
    }

    final isTyping = game.isMultiplayer && isActive && !player.isHuman && (game.phase == GamePhase.playing || game.phase == GamePhase.bidding || game.phase == GamePhase.declaring);
    final isRowLayout = alignment == Alignment.topCenter || alignment == Alignment.bottomCenter;

    final seatContent = Container(
      padding: EdgeInsets.symmetric(
        horizontal: isRowLayout ? 12 : 10,
        vertical: isRowLayout ? 4 : 6,
      ),
      decoration: GameTheme.glassDecoration(opacity: isActive ? 0.12 : 0.03, borderOpacity: isActive ? 0.25 : 0.08, radius: 12),
      child: isRowLayout
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: showGlow ? GameTheme.neonCyan : Colors.white24, width: 1.5),
                    boxShadow: GameTheme.neonGlow(shadowColor, blurRadius: 8),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/guest_avatar.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(color: GameTheme.textWhite, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    if (isTyping) ...[
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Thinking ',
                            style: TextStyle(color: GameTheme.neonCyan, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          TypingIndicator(),
                        ],
                      ),
                    ] else if (status.isNotEmpty || ((game.phase == GamePhase.playing || game.phase == GamePhase.roundOver))) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (status.isNotEmpty)
                            Text(
                              status,
                              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          if (status.isNotEmpty && (game.phase == GamePhase.playing || game.phase == GamePhase.roundOver))
                            const SizedBox(width: 6),
                          if ((game.phase == GamePhase.playing || game.phase == GamePhase.roundOver))
                            Text(
                              'Pts: ${player.roundPoints}',
                              style: const TextStyle(color: GameTheme.goldAccent, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: showGlow ? GameTheme.neonCyan : Colors.white24, width: 1.5),
                    boxShadow: GameTheme.neonGlow(shadowColor, blurRadius: 8),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/guest_avatar.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  player.name,
                  style: const TextStyle(color: GameTheme.textWhite, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                if (isTyping) ...[
                  const SizedBox(height: 4),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Thinking ',
                        style: TextStyle(color: GameTheme.neonCyan, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      TypingIndicator(),
                    ],
                  ),
                ] else if (status.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    status,
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
                if ((game.phase == GamePhase.playing || game.phase == GamePhase.roundOver) && !isTyping) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Pts: ${player.roundPoints}',
                    style: const TextStyle(color: GameTheme.goldAccent, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            ),
    );

    // Look up active message for this player
    final multiplayerState = ref.watch(multiplayerProvider);
    ChatMessage? activeMessage;
    final now = DateTime.now();
    for (final msg in multiplayerState.chatMessages.reversed) {
      if (msg.sender == player.name && now.difference(msg.timestamp).inSeconds < 4) {
        activeMessage = msg;
        break;
      }
    }

    final paddingVal = isRowLayout ? 2.0 : 12.0;

    if (activeMessage == null) {
      return Align(
        alignment: alignment,
        child: Padding(
          padding: EdgeInsets.all(paddingVal),
          child: seatContent,
        ),
      );
    }

    final isEmoji = activeMessage.text.runes.length <= 2;
    final bubbleWidget = FloatingBubble(text: activeMessage.text, isEmoji: isEmoji);

    // Determine bubble placement relative to seat
    double? left, right, top, bottom;
    if (alignment == Alignment.centerLeft) {
      left = 80;
      top = -10;
    } else if (alignment == Alignment.centerRight) {
      right = 80;
      top = -10;
    } else if (alignment == Alignment.topCenter) {
      top = 50;
    } else if (alignment == Alignment.bottomCenter) {
      bottom = 50;
    }

    return Align(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.all(paddingVal),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            seatContent,
            Positioned(
              left: left,
              right: right,
              top: top,
              bottom: bottom,
              child: bubbleWidget,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrickCenter(GameState game) {
    return Container(
      width: 150,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.01),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Centered indicator of current led suit
          if (game.gameTurn > 1 && game.trumpStart != 'x')
            Center(
              child: Opacity(
                opacity: 0.1,
                child: Text(
                  getSuitSymbol(game.trumpStart),
                  style: const TextStyle(fontSize: 54, color: Colors.white),
                ),
              ),
            ),

          // Player 0 (Bottom) played card
          if (game.players[0].playedCard != null)
            Align(
              alignment: const Alignment(0, 0.45),
              child: PlayingCardWidget(card: game.players[0].playedCard!, width: 40, height: 58),
            ),

          // Player 1 (Left) played card
          if (game.players[1].playedCard != null)
            Align(
              alignment: const Alignment(-0.6, 0),
              child: PlayingCardWidget(card: game.players[1].playedCard!, width: 40, height: 58),
            ),

          // Player 2 (Top) played card
          if (game.players[2].playedCard != null)
            Align(
              alignment: const Alignment(0, -0.45),
              child: PlayingCardWidget(card: game.players[2].playedCard!, width: 40, height: 58),
            ),

          // Player 3 (Right) played card
          if (game.players[3].playedCard != null)
            Align(
              alignment: const Alignment(0.6, 0),
              child: PlayingCardWidget(card: game.players[3].playedCard!, width: 40, height: 58),
            ),
        ],
      ),
    );
  }
}

// Bouncing Typing dots widget
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            double progress = _controller.value - delay;
            if (progress < 0) progress += 1.0;
            if (progress > 1.0) progress -= 1.0;

            final double bounce = sin(progress * pi * 2);
            final double translation = (bounce > 0 ? bounce : 0) * -4.0;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 5,
              height: 5,
              transform: Matrix4.translationValues(0, translation, 0),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: GameTheme.neonCyan,
              ),
            );
          },
        );
      }),
    );
  }
}

// Custom animated overlay chat bubble
class FloatingBubble extends StatefulWidget {
  final String text;
  final bool isEmoji;

  const FloatingBubble({
    super.key,
    required this.text,
    required this.isEmoji,
  });

  @override
  State<FloatingBubble> createState() => _FloatingBubbleState();
}

class _FloatingBubbleState extends State<FloatingBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)), weight: 10),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 80),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)), weight: 10),
    ]).animate(_controller);

    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 80),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 10),
    ]).animate(_controller);

    _slideAnimation = Tween<double>(begin: 10.0, end: -10.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(FloatingBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: widget.isEmoji
          ? Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.6),
                border: Border.all(color: GameTheme.neonCyan.withValues(alpha: 0.4), width: 1),
                boxShadow: GameTheme.neonGlow(GameTheme.neonCyan, blurRadius: 6),
              ),
              child: Text(
                widget.text,
                style: const TextStyle(fontSize: 24),
              ),
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              constraints: const BoxConstraints(maxWidth: 140),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GameTheme.neonCyan.withValues(alpha: 0.6), width: 1.5),
                boxShadow: GameTheme.neonGlow(GameTheme.neonCyan, blurRadius: 6),
              ),
              child: Text(
                widget.text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: GameTheme.textWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }
}
