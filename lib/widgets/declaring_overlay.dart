import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_model.dart';
import '../models/card_model.dart';
import '../core/theme.dart';
import '../core/suit_utils.dart';
import '../providers/game_notifier.dart';
import '../l10n/app_localizations.dart';

class DeclaringOverlay extends ConsumerStatefulWidget {
  final PlayerModel humanPlayer;

  const DeclaringOverlay({
    super.key,
    required this.humanPlayer,
  });

  @override
  ConsumerState<DeclaringOverlay> createState() => _DeclaringOverlayState();
}

class _DeclaringOverlayState extends ConsumerState<DeclaringOverlay> {
  String _selectedTrumpSuit = 'S';
  int _selectedPartnerRank = 14; // Ace
  String _selectedPartnerSuit = 'S';

  @override
  Widget build(BuildContext context) {
    // Check if partner card is in hand
    final bool isPartnerInHand = widget.humanPlayer.hand.any((c) => c.suit == _selectedPartnerSuit && c.rank == _selectedPartnerRank);
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black.withValues(alpha: 0.65),
            ),
          ),
        ),
        Center(
          child: Container(
            width: 440,
            constraints: BoxConstraints(maxHeight: size.height - 32),
            decoration: BoxDecoration(
              color: GameTheme.darkBackground.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
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
                  Text(
                    AppLocalizations.of(context)?.declareTitle ?? 'DECLARE TRUMP & PARTNER',
                    style: const TextStyle(color: GameTheme.neonCyan, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 16),

                  // Trump selection row
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(AppLocalizations.of(context)?.selectTrump ?? '1. SELECT TRUMP SUIT', style: const TextStyle(color: GameTheme.textGrey, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['S', 'H', 'C', 'D'].map((suit) {
                      final isSelected = _selectedTrumpSuit == suit;
                      final suitName = CardModel.getLocalizedSuitName(context, suit);
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
                                color: isSelected ? GameTheme.neonCyan.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.03),
                                border: Border.all(
                                  color: isSelected ? GameTheme.neonCyan : Colors.white12,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    getSuitSymbol(suit),
                                    style: TextStyle(color: isRed ? Colors.red : Colors.white, fontSize: 18),
                                  ),
                                  Text(
                                    suitName.toUpperCase(),
                                    style: const TextStyle(color: GameTheme.textWhite, fontSize: 11),
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(AppLocalizations.of(context)?.nominatePartner ?? '2. NOMINATE PARTNER CARD', style: const TextStyle(color: GameTheme.textGrey, fontSize: 11, fontWeight: FontWeight.bold)),
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
                            labelText: AppLocalizations.of(context)?.rank ?? 'Rank',
                            labelStyle: const TextStyle(color: GameTheme.textGrey, fontSize: 12),
                            enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(8)),
                            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: GameTheme.neonCyan), borderRadius: BorderRadius.circular(8)),
                          ),
                          initialValue: _selectedPartnerRank,
                          items: List.generate(13, (i) => i + 2).map((rank) {
                            String label = rank.toString();
                            if (rank == 11) label = AppLocalizations.of(context)?.jack ?? 'Jack';
                            if (rank == 12) label = AppLocalizations.of(context)?.queen ?? 'Queen';
                            if (rank == 13) label = AppLocalizations.of(context)?.king ?? 'King';
                            if (rank == 14) label = AppLocalizations.of(context)?.ace ?? 'Ace';
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
                            labelText: AppLocalizations.of(context)?.suit ?? 'Suit',
                            labelStyle: const TextStyle(color: GameTheme.textGrey, fontSize: 12),
                            enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(8)),
                            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: GameTheme.neonCyan), borderRadius: BorderRadius.circular(8)),
                          ),
                          initialValue: _selectedPartnerSuit,
                          items: ['S', 'H', 'C', 'D'].map((suit) {
                            return DropdownMenuItem<String>(
                              value: suit,
                              child: Text(
                                '${getSuitSymbol(suit)} ${CardModel.getLocalizedSuitNamePlural(context, suit)}',
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
                              AppLocalizations.of(context)?.holdWarning ?? 'Warning: You hold this card! Select a card you do NOT hold.',
                              style: TextStyle(color: GameTheme.neonPink.withValues(alpha: 0.9), fontSize: 11, fontWeight: FontWeight.bold),
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
                    child: Text(AppLocalizations.of(context)?.declareSubmit ?? 'DECLARE & START PLAYING', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
