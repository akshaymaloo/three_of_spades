import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/multiplayer_notifier.dart';
import '../core/theme.dart';

class EmojiPickerPanel extends ConsumerWidget {
  final VoidCallback onEmojiSent;

  const EmojiPickerPanel({super.key, required this.onEmojiSent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emojis = ['🔥', '😂', '😭', '👍', '😎', '♠', '👎', '🎉'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: GameTheme.glassDecoration(opacity: 0.1, radius: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: emojis.map((emoji) {
          return InkWell(
            onTap: () {
              ref.read(multiplayerProvider.notifier).sendMessage(emoji);
              onEmojiSent();
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
