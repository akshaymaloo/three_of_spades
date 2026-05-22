import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../core/theme.dart';
import '../providers/game_notifier.dart';

class BiddingOverlay extends ConsumerStatefulWidget {
  final GameState game;

  const BiddingOverlay({
    super.key,
    required this.game,
  });

  @override
  ConsumerState<BiddingOverlay> createState() => _BiddingOverlayState();
}

class _BiddingOverlayState extends ConsumerState<BiddingOverlay> {
  late int _sliderBid;
  late int _minBid;

  @override
  void initState() {
    super.initState();
    _minBid = (widget.game.winningBid == 0) ? 175 : ((widget.game.winningBid ~/ 5) * 5) + 5;
    _sliderBid = _minBid;
  }

  @override
  void didUpdateWidget(covariant BiddingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newMinBid = (widget.game.winningBid == 0) ? 175 : ((widget.game.winningBid ~/ 5) * 5) + 5;
    if (newMinBid != _minBid) {
      setState(() {
        _minBid = newMinBid;
        if (_sliderBid < _minBid) {
          _sliderBid = _minBid;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            width: 380,
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
                    'Current Bid: ${widget.game.winningBid == 0 ? "None" : widget.game.winningBid}',
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
                      min: _minBid.toDouble(),
                      max: 350,
                      divisions: ((350 - _minBid) / 5).clamp(1, 100).toInt(),
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
}
