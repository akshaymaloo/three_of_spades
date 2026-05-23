import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'glass_dialog.dart';
import '../l10n/app_localizations.dart';

class CreditsDialog extends StatelessWidget {
  const CreditsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassDialog(
      title: AppLocalizations.of(context)?.creditsTitle ?? 'Credits',
      glowColor: GameTheme.goldAccent,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Three of Spades',
            style: TextStyle(color: GameTheme.neonCyan, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Developed with ❤️ by Akshay Maloo',
            textAlign: TextAlign.center,
            style: TextStyle(color: GameTheme.textWhite, fontSize: 14),
          ),
          const SizedBox(height: 16),
          const Text(
            'A modern take on the classic Indian 3-5-8 card game, featuring beautiful neon visuals and intelligent bot AI.',
            textAlign: TextAlign.center,
            style: TextStyle(color: GameTheme.textGrey, fontSize: 12),
          ),
          const SizedBox(height: 16),
          const Text(
            'Special thanks to the open-source community for Flutter and Riverpod!',
            textAlign: TextAlign.center,
            style: TextStyle(color: GameTheme.textGrey, fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)?.close ?? 'CLOSE', style: const TextStyle(color: GameTheme.textWhite, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
