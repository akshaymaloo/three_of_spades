import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme.dart';

class GlassDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;
  final Color glowColor;

  const GlassDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions = const [],
    this.glowColor = GameTheme.neonCyan,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: AlertDialog(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: GameTheme.darkBackground.withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: glowColor.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: GameTheme.neonGlow(glowColor, blurRadius: 15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.05),
                      width: 1.0,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: GameTheme.textWhite,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: glowColor.withOpacity(0.8),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: GameTheme.textGrey, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: content,
              ),
              // Actions
              if (actions.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions.map((a) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: a,
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Quick helper to show alerts
  static void showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => GlassDialog(
        title: 'Coming Soon',
        glowColor: GameTheme.neonPink,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: GameTheme.neonPink.withOpacity(0.1),
                border: Border.all(color: GameTheme.neonPink.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.bolt,
                size: 40,
                color: GameTheme.neonPink,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '$feature multiplayer is under development!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: GameTheme.textWhite,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Compete in global rankings, match with active players online, and set up custom tables soon.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: GameTheme.textGrey,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'ACKNOWLEDGE',
              style: TextStyle(color: GameTheme.neonPink, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
