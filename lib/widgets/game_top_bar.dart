import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/card_model.dart';
import '../core/theme.dart';
import '../core/suit_utils.dart';
import '../providers/game_notifier.dart';
import '../providers/multiplayer_notifier.dart';
import '../l10n/app_localizations.dart';

class GameTopBar extends ConsumerWidget implements PreferredSizeWidget {
  final GameState game;
  final bool isChatOpen;
  final int lastSeenMessageCount;
  final VoidCallback onChatPressed;

  const GameTopBar({
    super.key,
    required this.game,
    required this.isChatOpen,
    required this.lastSeenMessageCount,
    required this.onChatPressed,
  });

  bool _isPartnerRevealed(GameState game) {
    return game.players.any((p) => p.isPartner && p.isPartnerRevealed);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trumpIcon = game.trump != 'x' ? getSuitSymbol(game.trump) : '?';
    final trumpColor = getSuitColor(game.trump);
    final multiplayerState = ref.watch(multiplayerProvider);
    final int unreadCount = game.isMultiplayer && !isChatOpen
        ? (multiplayerState.chatMessages.length - lastSeenMessageCount).clamp(0, 99)
        : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: Colors.black.withValues(alpha: 0.2),
      child: SafeArea(
        bottom: false,
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
                        Text(AppLocalizations.of(context)?.trumpLabel ?? 'TRUMP: ', style: const TextStyle(color: GameTheme.textGrey, fontSize: 11, fontWeight: FontWeight.bold)),
                        Text(
                          trumpIcon,
                          style: TextStyle(color: trumpColor, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          CardModel.getLocalizedSuitName(context, game.trump),
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
                        Text(AppLocalizations.of(context)?.partnerLabelUpper ?? 'PARTNER: ', style: const TextStyle(color: GameTheme.textGrey, fontSize: 11, fontWeight: FontWeight.bold)),
                        Text(
                          game.partnerCard!.rankLabel,
                          style: const TextStyle(color: GameTheme.textWhite, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          getSuitSymbol(game.partnerCard!.suit),
                          style: TextStyle(
                            color: getSuitColor(game.partnerCard!.suit),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isPartnerRevealed(game) 
                              ? (AppLocalizations.of(context)?.revealed ?? '(REVEALED)') 
                              : (AppLocalizations.of(context)?.hidden ?? '(HIDDEN)'),
                          style: TextStyle(
                            color: _isPartnerRevealed(game) ? GameTheme.neonGreen : GameTheme.neonPink,
                            fontSize: 11,
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
                      onPressed: onChatPressed,
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
                                fontSize: 11,
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
    ),
  );
}

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
