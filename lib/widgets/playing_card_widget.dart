import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/card_model.dart';
import '../core/theme.dart';

class PlayingCardWidget extends StatelessWidget {
  final CardModel card;
  final bool isSelected;
  final bool isPlayable;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final bool showBack;
  final double selectionOffset;

  const PlayingCardWidget({
    super.key,
    required this.card,
    this.isSelected = false,
    this.isPlayable = true,
    this.onTap,
    this.width = 72,
    this.height = 104,
    this.showBack = false,
    this.selectionOffset = 18,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardBody;

    if (showBack) {
      cardBody = ExcludeSemantics(
        child: SvgPicture.asset(
          'assets/cards/back_side_blue.svg',
          fit: BoxFit.fill,
          placeholderBuilder: (context) => _buildCardBackFallback(),
        ),
      );
    } else {
      cardBody = ExcludeSemantics(
        child: SvgPicture.asset(
          card.assetPath,
          fit: BoxFit.fill,
          placeholderBuilder: (context) => _buildCardFrontFallback(),
        ),
      );
    }

    final String labelStr = showBack
        ? 'Face down card'
        : '${card.name}${card.points > 0 ? ", ${card.points} points" : ""}${isSelected ? ", selected" : ""}${!isPlayable ? ", unplayable" : ""}';

    return Semantics(
      label: labelStr,
      button: isPlayable && onTap != null,
      enabled: isPlayable,
      child: GestureDetector(
        onTap: isPlayable ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: width,
          height: height,
          margin: EdgeInsets.only(bottom: isSelected ? selectionOffset : 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? GameTheme.neonGlow(GameTheme.neonCyan, blurRadius: 10)
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isPlayable
                ? cardBody
                : ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withValues(alpha: 0.5),
                      BlendMode.dstATop,
                    ),
                    child: cardBody,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardBackFallback() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF0D47A1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              '♠',
              style: TextStyle(fontSize: 32, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardFrontFallback() {
    final isRed = card.suit == 'H' || card.suit == 'D';
    final suitSymbol = _getSuitSymbol(card.suit);

    return Container(
      width: width,
      height: height,
      color: Colors.white,
      padding: const EdgeInsets.all(4),
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 72,
          height: 104,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  card.rankLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isRed ? Colors.red : Colors.black,
                  ),
                ),
              ),
              Text(
                suitSymbol,
                style: TextStyle(
                  fontSize: 24,
                  color: isRed ? Colors.red : Colors.black,
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Transform.rotate(
                  angle: 3.14159,
                  child: Text(
                    card.rankLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isRed ? Colors.red : Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
}
