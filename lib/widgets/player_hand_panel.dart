import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/player_model.dart';
import '../core/theme.dart';
import 'playing_card_widget.dart';
import '../providers/game_notifier.dart';
import '../l10n/app_localizations.dart';

class PlayerHandPanel extends ConsumerStatefulWidget {
  final GameState game;
  final PlayerModel humanPlayer;

  const PlayerHandPanel({
    super.key,
    required this.game,
    required this.humanPlayer,
  });

  @override
  ConsumerState<PlayerHandPanel> createState() => _PlayerHandPanelState();
}

class _PlayerHandPanelState extends ConsumerState<PlayerHandPanel> {
  int? _selectedCardIndex;

  @override
  void didUpdateWidget(covariant PlayerHandPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset selection if it's no longer the human player's turn to play
    if (widget.game.activePlayerIndex != 0 || widget.game.phase != GamePhase.playing) {
      _selectedCardIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hand = widget.humanPlayer.hand;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 120,
              child: hand.isEmpty
                  ? Center(child: Text(AppLocalizations.of(context)?.noCards ?? 'No Cards', style: const TextStyle(color: GameTheme.textGrey)))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: hand.length,
                      itemBuilder: (context, index) {
                        final card = hand[index];
                        // Validate if playable
                        bool isPlayable = true;
                        if (widget.game.phase == GamePhase.playing && widget.game.activePlayerIndex == 0 && widget.game.gameTurn > 1) {
                          final hasLedSuit = hand.any((c) => c.suit == widget.game.trumpStart);
                          if (hasLedSuit && card.suit != widget.game.trumpStart) {
                            isPlayable = false;
                          }
                        }

                        final isSelected = _selectedCardIndex == index;

                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0, top: 16.0), // Add top padding to allow badge space
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              PlayingCardWidget(
                                card: card,
                                isSelected: isSelected,
                                isPlayable: isPlayable,
                                width: 56,
                                height: 80,
                                selectionOffset: 14,
                                onTap: () {
                                  if (widget.game.activePlayerIndex != 0) return;

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
                              if (card.points > 0)
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOut,
                                  top: isSelected ? -20 : -6,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                          )
                                        ],
                                      ),
                                      child: Text(
                                        '${card.points}',
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
                        );
                      },
                    ),
            ),
          ),
          if (widget.game.activePlayerIndex == 0 && widget.game.phase == GamePhase.playing && _selectedCardIndex != null)
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
                child: Text(AppLocalizations.of(context)?.playCard ?? 'PLAY CARD', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}
