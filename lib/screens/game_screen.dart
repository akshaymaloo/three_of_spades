import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../models/card_model.dart';
import '../models/player_model.dart';
import '../models/game_state.dart';
import '../models/multiplayer_state.dart';
import '../providers/game_notifier.dart';
import '../providers/multiplayer_notifier.dart';
import '../providers/stats_provider.dart';
import '../widgets/playing_card_widget.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  int? _selectedCardIndex;
  
  // Bidding inputs
  int _sliderBid = 175;

  // Declaring inputs
  String _selectedTrumpSuit = 'S';
  int _selectedPartnerRank = 14; // Ace
  String _selectedPartnerSuit = 'S';

  // Chat/Reaction variables
  late ScrollController _chatScrollController;
  late TextEditingController _chatTextController;
  bool _isChatOpen = false;
  int _lastSeenMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _chatScrollController = ScrollController();
    _chatTextController = TextEditingController();
  }

  @override
  void dispose() {
    _chatScrollController.dispose();
    _chatTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final multiplayerState = ref.watch(multiplayerProvider);

    // Auto-scroll when chat is open and a new message arrives
    if (_isChatOpen && multiplayerState.chatMessages.length > _lastSeenMessageCount) {
      _lastSeenMessageCount = multiplayerState.chatMessages.length;
      _scrollToBottom();
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

    // Auto-update default slider value when human bidding starts
    if (game.phase == GamePhase.bidding && game.activePlayerIndex == 0) {
      final minBid = (game.winningBid == 0) ? 175 : ((game.winningBid ~/ 5) * 5) + 5;
      if (_sliderBid < minBid) {
        _sliderBid = minBid;
      }
    }

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
                  _buildTopBar(game),
                  
                  // Central Card Table Area
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Felt green table
                          Container(
                            width: size.width * 0.75,
                            height: size.height * 0.52,
                            decoration: BoxDecoration(
                              gradient: GameTheme.tableGradient,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: Colors.white.withOpacity(0.08), width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                          ),

                          // Dotted center slot representing trick cards
                          _buildTrickCenter(game),

                          // Seat positions
                          _buildSeat(game.players[1], Alignment.centerLeft, game.activePlayerIndex == 1), // Left Bot
                          _buildSeat(game.players[2], Alignment.topCenter, game.activePlayerIndex == 2),  // Top Bot
                          _buildSeat(game.players[3], Alignment.centerRight, game.activePlayerIndex == 3), // Right Bot
                          _buildSeat(game.players[0], Alignment.bottomCenter, game.activePlayerIndex == 0), // Human (bottom)
                        ],
                      ),
                    ),
                  ),

                  // Bottom HUD: User Cards
                  _buildUserHandPanel(game, humanPlayer),
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

              // Bidding Control Overlay in the center
              if (game.phase == GamePhase.bidding && game.activePlayerIndex == 0)
                _buildBiddingOverlay(game),

              // Trump and Partner Declaration Overlay
              if (game.phase == GamePhase.declaring && game.activePlayerIndex == 0)
                _buildDeclaringOverlay(humanPlayer),

              // Game Over / Round Over Scoreboard Overlay
              if (game.phase == GamePhase.roundOver)
                _buildScoreboardOverlay(game),

              // Chat Slide Drawer Overlay
              if (game.isMultiplayer)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  right: _isChatOpen ? 0 : -300,
                  top: 0,
                  bottom: 0,
                  child: _buildChatPanelSideWidget(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(GameState game) {
    final trumpIcon = game.trump != 'x' ? _getSuitSymbol(game.trump) : '?';
    final trumpColor = (game.trump == 'H' || game.trump == 'D') ? Colors.red : Colors.white;
    final multiplayerState = ref.watch(multiplayerProvider);
    final int unreadCount = game.isMultiplayer && !_isChatOpen
        ? (multiplayerState.chatMessages.length - _lastSeenMessageCount).clamp(0, 99)
        : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: Colors.black.withOpacity(0.2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: GameTheme.textWhite),
            onPressed: () {
              ref.read(gameProvider.notifier).goToHome();
            },
          ),
          Row(
            children: [
              // Trump HUD
              if (game.trump != 'x')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  margin: const EdgeInsets.only(right: 12),
                  decoration: GameTheme.glassDecoration(opacity: 0.05, borderOpacity: 0.1, radius: 8),
                  child: Row(
                    children: [
                      const Text('TRUMP: ', style: TextStyle(color: GameTheme.textGrey, fontSize: 11, fontWeight: FontWeight.bold)),
                      Text(
                        trumpIcon,
                        style: TextStyle(color: trumpColor, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        CardModel.getSuitName(game.trump),
                        style: TextStyle(color: trumpColor, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

              // Partner Card HUD
              if (game.partnerCard != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: GameTheme.glassDecoration(opacity: 0.05, borderOpacity: 0.1, radius: 8),
                  child: Row(
                    children: [
                      const Text('PARTNER: ', style: TextStyle(color: GameTheme.textGrey, fontSize: 11, fontWeight: FontWeight.bold)),
                      Text(
                        game.partnerCard!.rankLabel,
                        style: const TextStyle(color: GameTheme.textWhite, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _getSuitSymbol(game.partnerCard!.suit),
                        style: TextStyle(
                          color: (game.partnerCard!.suit == 'H' || game.partnerCard!.suit == 'D') ? Colors.red : Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isPartnerRevealed(game) ? '(REVEALED)' : '(HIDDEN)',
                        style: TextStyle(
                          color: _isPartnerRevealed(game) ? GameTheme.neonGreen : GameTheme.neonPink,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          Row(
            children: [
              if (game.isMultiplayer) ...[
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline, color: GameTheme.textWhite),
                      onPressed: () {
                        setState(() {
                          _isChatOpen = true;
                          _lastSeenMessageCount = ref.read(multiplayerProvider).chatMessages.length;
                        });
                        _scrollToBottom();
                      },
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: GameTheme.neonPink,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Center(
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
              IconButton(
                icon: Icon(game.soundEnabled ? Icons.volume_up : Icons.volume_off, color: GameTheme.textWhite),
                onPressed: () {
                  ref.read(gameProvider.notifier).toggleSound();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isPartnerRevealed(GameState game) {
    return game.players.any((p) => p.isPartner && p.isPartnerRevealed);
  }

  Widget _buildSeat(PlayerModel player, Alignment alignment, bool isActive) {
    final showGlow = isActive && (ref.read(gameProvider).phase != GamePhase.roundOver);
    final shadowColor = showGlow ? GameTheme.neonCyan : Colors.transparent;

    // Status label below avatar
    String status = '';
    Color statusColor = GameTheme.textGrey;

    final game = ref.read(gameProvider);
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
                            style: TextStyle(color: GameTheme.neonCyan, fontSize: 9, fontWeight: FontWeight.bold),
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
                              style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          if (status.isNotEmpty && (game.phase == GamePhase.playing || game.phase == GamePhase.roundOver))
                            const SizedBox(width: 6),
                          if ((game.phase == GamePhase.playing || game.phase == GamePhase.roundOver))
                            Text(
                              'Pts: ${player.roundPoints}',
                              style: const TextStyle(color: GameTheme.goldAccent, fontSize: 9, fontWeight: FontWeight.bold),
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
                        style: TextStyle(color: GameTheme.neonCyan, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                      TypingIndicator(),
                    ],
                  ),
                ] else if (status.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    status,
                    style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ],
                if ((game.phase == GamePhase.playing || game.phase == GamePhase.roundOver) && !isTyping) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Pts: ${player.roundPoints}',
                    style: const TextStyle(color: GameTheme.goldAccent, fontSize: 9, fontWeight: FontWeight.bold),
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
        color: Colors.white.withOpacity(0.01),
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
                  _getSuitSymbol(game.trumpStart),
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

  Widget _buildUserHandPanel(GameState game, PlayerModel humanPlayer) {
    final hand = humanPlayer.hand;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 96,
              child: hand.isEmpty
                  ? const Center(child: Text('No Cards', style: TextStyle(color: GameTheme.textGrey)))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: hand.length,
                      itemBuilder: (context, index) {
                        final card = hand[index];
                        // Validate if playable
                        bool isPlayable = true;
                        if (game.phase == GamePhase.playing && game.activePlayerIndex == 0 && game.gameTurn > 1) {
                          final hasLedSuit = hand.any((c) => c.suit == game.trumpStart);
                          if (hasLedSuit && card.suit != game.trumpStart) {
                            isPlayable = false;
                          }
                        }

                        final isSelected = _selectedCardIndex == index;

                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: PlayingCardWidget(
                            card: card,
                            isSelected: isSelected,
                            isPlayable: isPlayable,
                            width: 56,
                            height: 80,
                            selectionOffset: 14,
                            onTap: () {
                              if (game.activePlayerIndex != 0) return;

                              if (isSelected) {
                                final played = ref.read(gameProvider.notifier).playCard(card);
                                if (played) {
                                  setState(() {
                                    _selectedCardIndex = null;
                                  });
                                }
                              } else {
                                setState(() {
                                  _selectedCardIndex = index;
                                });
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
          if (game.activePlayerIndex == 0 && game.phase == GamePhase.playing && _selectedCardIndex != null)
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GameTheme.neonGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  final card = hand[_selectedCardIndex!];
                  final played = ref.read(gameProvider.notifier).playCard(card);
                  if (played) {
                    setState(() {
                      _selectedCardIndex = null;
                    });
                  }
                },
                child: const Text('PLAY CARD', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBiddingOverlay(GameState game) {
    final minBid = (game.winningBid == 0) ? 175 : ((game.winningBid ~/ 5) * 5) + 5;
    final size = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black.withOpacity(0.65),
            ),
          ),
        ),
        Center(
          child: Container(
            width: 380,
            constraints: BoxConstraints(maxHeight: size.height - 32),
            decoration: BoxDecoration(
              color: GameTheme.darkBackground.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
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
                  const Text(
                    'YOUR TURN TO BID',
                    style: TextStyle(color: GameTheme.neonCyan, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current Bid: ${game.winningBid == 0 ? "None" : game.winningBid}',
                    style: const TextStyle(color: GameTheme.textWhite, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  
                  if (_sliderBid <= 350) ...[
                    Text(
                      'Your Bid: $_sliderBid',
                      style: const TextStyle(color: GameTheme.neonGreen, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Slider(
                      value: _sliderBid.toDouble(),
                      min: minBid.toDouble(),
                      max: 350,
                      divisions: ((350 - minBid) / 5).clamp(1, 100).toInt(),
                      activeColor: GameTheme.neonGreen,
                      inactiveColor: Colors.white24,
                      onChanged: (val) {
                        setState(() {
                          _sliderBid = (val / 5).round() * 5;
                        });
                      },
                    ),
                  ],

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: GameTheme.neonPink),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            ref.read(gameProvider.notifier).passBid();
                          },
                          child: const Text('PASS', style: TextStyle(color: GameTheme.neonPink, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GameTheme.neonGreen,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            ref.read(gameProvider.notifier).placeBid(_sliderBid);
                          },
                          child: const Text('BID', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildDeclaringOverlay(PlayerModel humanPlayer) {
    // Check if partner card is in hand
    final bool isPartnerInHand = humanPlayer.hand.any((c) => c.suit == _selectedPartnerSuit && c.rank == _selectedPartnerRank);
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black.withOpacity(0.65),
            ),
          ),
        ),
        Center(
          child: Container(
            width: 440,
            constraints: BoxConstraints(maxHeight: size.height - 32),
            decoration: BoxDecoration(
              color: GameTheme.darkBackground.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'DECLARE TRUMP & PARTNER',
                    style: TextStyle(color: GameTheme.neonCyan, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 16),

                  // Trump selection row
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('1. SELECT TRUMP SUIT', style: TextStyle(color: GameTheme.textGrey, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['S', 'H', 'C', 'D'].map((suit) {
                      final isSelected = _selectedTrumpSuit == suit;
                      final suitName = CardModel.getSuitName(suit);
                      final isRed = suit == 'H' || suit == 'D';

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedTrumpSuit = suit;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? GameTheme.neonCyan.withOpacity(0.2) : Colors.white.withOpacity(0.03),
                                border: Border.all(
                                  color: isSelected ? GameTheme.neonCyan : Colors.white12,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    _getSuitSymbol(suit),
                                    style: TextStyle(color: isRed ? Colors.red : Colors.white, fontSize: 18),
                                  ),
                                  Text(
                                    suitName.toUpperCase(),
                                    style: const TextStyle(color: GameTheme.textWhite, fontSize: 9),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Partner card selection
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('2. NOMINATE PARTNER CARD', style: TextStyle(color: GameTheme.textGrey, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Rank selector
                      Expanded(
                        flex: 5,
                        child: DropdownButtonFormField<int>(
                          dropdownColor: GameTheme.darkBackground,
                          decoration: InputDecoration(
                            labelText: 'Rank',
                            labelStyle: const TextStyle(color: GameTheme.textGrey, fontSize: 12),
                            enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(8)),
                            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: GameTheme.neonCyan), borderRadius: BorderRadius.circular(8)),
                          ),
                          value: _selectedPartnerRank,
                          items: List.generate(13, (i) => i + 2).map((rank) {
                            String label = rank.toString();
                            if (rank == 11) label = 'Jack';
                            if (rank == 12) label = 'Queen';
                            if (rank == 13) label = 'King';
                            if (rank == 14) label = 'Ace';
                            return DropdownMenuItem<int>(
                              value: rank,
                              child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedPartnerRank = val;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Suit selector
                      Expanded(
                        flex: 5,
                        child: DropdownButtonFormField<String>(
                          dropdownColor: GameTheme.darkBackground,
                          decoration: InputDecoration(
                            labelText: 'Suit',
                            labelStyle: const TextStyle(color: GameTheme.textGrey, fontSize: 12),
                            enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(8)),
                            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: GameTheme.neonCyan), borderRadius: BorderRadius.circular(8)),
                          ),
                          value: _selectedPartnerSuit,
                          items: ['S', 'H', 'C', 'D'].map((suit) {
                            return DropdownMenuItem<String>(
                              value: suit,
                              child: Text(
                                '${_getSuitSymbol(suit)} ${CardModel.getSuitName(suit)}s',
                                style: TextStyle(
                                  color: (suit == 'H' || suit == 'D') ? Colors.red : Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedPartnerSuit = val;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  if (isPartnerInHand)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: GameTheme.neonPink, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Warning: You hold this card! Select a card you do NOT hold.',
                              style: TextStyle(color: GameTheme.neonPink.withOpacity(0.9), fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPartnerInHand ? Colors.white10 : GameTheme.neonGreen,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(double.infinity, 44),
                    ),
                    onPressed: isPartnerInHand
                        ? null
                        : () {
                            // Build partner card dummy model
                            final partnerCard = CardModel(
                              id: 999, // dummy
                              suit: _selectedPartnerSuit,
                              rank: _selectedPartnerRank,
                              points: 0, // points calculated in engine
                              assetPath: 'assets/cards/${_selectedPartnerSuit.toLowerCase()}$_selectedPartnerRank.svg',
                            );
                            ref.read(gameProvider.notifier).declareTrumpAndPartner(_selectedTrumpSuit, partnerCard);
                          },
                    child: const Text('DECLARE & START PLAYING', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreboardOverlay(GameState game) {
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

    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black.withOpacity(0.65),
            ),
          ),
        ),
        Center(
          child: Container(
            width: 440,
            constraints: BoxConstraints(maxHeight: size.height - 32),
            decoration: BoxDecoration(
              color: GameTheme.darkBackground.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: glowColor.withOpacity(0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
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
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('BID VALUE', style: TextStyle(color: GameTheme.textGrey, fontSize: 10)),
                            Text('${game.winningBid} pts', style: const TextStyle(color: GameTheme.textWhite, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('COLLECTED', style: TextStyle(color: GameTheme.textGrey, fontSize: 10)),
                            Text('$totalBidderPoints pts', style: TextStyle(color: glowColor, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('COIN REWARDS / PENALTIES:', style: TextStyle(color: GameTheme.textGrey, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),

                  // List of players and coins gained/lost
                  ...List.generate(4, (i) {
                    final p = game.players[i];
                    // delta calculation
                    int delta = 0;
                    if (isBidWon) {
                      if (i == bidderIndex) delta = 300;
                      else if (i == partnerIndex) delta = bidderIndex == partnerIndex ? 300 : 150;
                      else delta = -150;
                    } else {
                      if (i == bidderIndex) delta = -300;
                      else if (i == partnerIndex) delta = bidderIndex == partnerIndex ? -300 : -150;
                      else delta = 150;
                    }

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

  String _getSuitSymbol(String suitChar) {
    switch (suitChar) {
      case 'S':
        return '♠';
      case 'H':
        return '♥';
      case 'C':
        return '♣';
      case 'D':
        return '♦';
      default:
        return '?';
    }
  }

  Widget _buildChatPanelSideWidget() {
    final multiplayerState = ref.watch(multiplayerProvider);
    final size = MediaQuery.of(context).size;

    return Container(
      width: 300,
      height: size.height,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        border: Border(left: BorderSide(color: GameTheme.neonCyan.withOpacity(0.3), width: 1.5)),
        boxShadow: [
          BoxShadow(
            color: GameTheme.neonCyan.withOpacity(0.15),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline, color: GameTheme.neonCyan, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'GAME CHAT',
                      style: TextStyle(
                        color: GameTheme.textWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        shadows: GameTheme.neonGlow(GameTheme.neonCyan, blurRadius: 4),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: GameTheme.textWhite, size: 20),
                  onPressed: () {
                    setState(() {
                      _isChatOpen = false;
                      _lastSeenMessageCount = ref.read(multiplayerProvider).chatMessages.length;
                    });
                  },
                ),
              ],
            ),
          ),

          // Message List
          Expanded(
            child: ListView.builder(
              controller: _chatScrollController,
              padding: const EdgeInsets.all(12),
              itemCount: multiplayerState.chatMessages.length,
              itemBuilder: (context, index) {
                final msg = multiplayerState.chatMessages[index];
                if (msg.isSystem) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        msg.text,
                        style: const TextStyle(color: GameTheme.textGrey, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final isMe = msg.sender == ref.read(statsProvider).name;
                final senderGlowColor = isMe ? GameTheme.neonCyan : GameTheme.neonPink;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isMe
                          ? GameTheme.neonCyan.withOpacity(0.12)
                          : Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
                        bottomRight: isMe ? Radius.zero : const Radius.circular(12),
                      ),
                      border: Border.all(
                        color: isMe
                            ? GameTheme.neonCyan.withOpacity(0.3)
                            : Colors.white.withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isMe)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2.0),
                            child: Text(
                              msg.sender,
                              style: TextStyle(
                                color: senderGlowColor,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        Text(
                          msg.text,
                          style: const TextStyle(color: GameTheme.textWhite, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Quick Emojis Selection
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.03))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['🔥', '😂', '😭', '👍', '😎', '♠'].map((emoji) {
                return InkWell(
                  onTap: () {
                    ref.read(multiplayerProvider.notifier).sendMessage(emoji);
                    _scrollToBottom();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(emoji, style: const TextStyle(fontSize: 20)),
                  ),
                );
              }).toList(),
            ),
          ),

          // Custom Input Area
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white.withOpacity(0.02),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatTextController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Type message...',
                      hintStyle: const TextStyle(color: GameTheme.textGrey, fontSize: 13),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.04),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: GameTheme.neonCyan.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onSubmitted: (val) {
                      _sendCustomMessage();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: GameTheme.neonCyan, size: 20),
                  onPressed: _sendCustomMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendCustomMessage() {
    final text = _chatTextController.text;
    if (text.trim().isEmpty) return;
    ref.read(multiplayerProvider.notifier).sendMessage(text);
    _chatTextController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
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
                color: Colors.black.withOpacity(0.6),
                border: Border.all(color: GameTheme.neonCyan.withOpacity(0.4), width: 1),
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
                color: Colors.black.withOpacity(0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GameTheme.neonCyan.withOpacity(0.6), width: 1.5),
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
