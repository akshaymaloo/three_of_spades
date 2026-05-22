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
    final viewInsets = MediaQuery.viewInsetsOf(context);
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: AlertDialog(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        insetPadding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 24,
        ).copyWith(bottom: 24 + viewInsets.bottom),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(
            maxWidth: 420,
            maxHeight: MediaQuery.sizeOf(context).height - 48 - viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: GameTheme.darkBackground.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: glowColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: GameTheme.neonGlow(glowColor, blurRadius: 15),
          ),
          child: SingleChildScrollView(
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
                        color: Colors.white.withValues(alpha: 0.05),
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
                              color: glowColor.withValues(alpha: 0.8),
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
                      color: Colors.white.withValues(alpha: 0.02),
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
      ),
    );
  }

}
