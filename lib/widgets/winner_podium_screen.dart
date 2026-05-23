import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_model.dart';
import '../core/theme.dart';
import '../providers/game_notifier.dart';
import '../l10n/app_localizations.dart';

class WinnerPodiumScreen extends ConsumerStatefulWidget {
  final List<PlayerModel> players;

  const WinnerPodiumScreen({super.key, required this.players});

  @override
  ConsumerState<WinnerPodiumScreen> createState() => _WinnerPodiumScreenState();
}

class _WinnerPodiumScreenState extends ConsumerState<WinnerPodiumScreen> {
  late ConfettiController _confettiController;
  late List<PlayerModel> _sortedPlayers;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
    _confettiController.play();
    
    _sortedPlayers = List.from(widget.players);
    _sortedPlayers.sort((a, b) => b.coins.compareTo(a.coins));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Widget _buildPodiumStep(PlayerModel player, int rank, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          player.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${player.coins} pts',
          style: TextStyle(color: color, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            boxShadow: GameTheme.neonGlow(color, blurRadius: 10),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: Colors.black.withValues(alpha: 0.8),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 3.14 / 2, // downwards
            maxBlastForce: 5,
            minBlastForce: 2,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.1,
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)?.victory ?? 'MATCH RESULTS',
                style: const TextStyle(
                  color: GameTheme.goldAccent, 
                  fontSize: 32, 
                  fontWeight: FontWeight.bold, 
                  letterSpacing: 2
                ),
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_sortedPlayers.length > 1)
                    _buildPodiumStep(_sortedPlayers[1], 2, 120, Colors.grey[300]!),
                  const SizedBox(width: 16),
                  if (_sortedPlayers.isNotEmpty)
                    _buildPodiumStep(_sortedPlayers[0], 1, 160, GameTheme.goldAccent),
                  const SizedBox(width: 16),
                  if (_sortedPlayers.length > 2)
                    _buildPodiumStep(_sortedPlayers[2], 3, 90, Colors.brown[300]!),
                  const SizedBox(width: 16),
                  if (_sortedPlayers.length > 3)
                    _buildPodiumStep(_sortedPlayers[3], 4, 60, Colors.blueGrey),
                ],
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () {
                  ref.read(gameProvider.notifier).goToHome();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: GameTheme.neonCyan,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  AppLocalizations.of(context)?.continueButton ?? 'CONTINUE', 
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
