import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/multiplayer_notifier.dart';
import '../providers/stats_provider.dart';

class ChatPanel extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const ChatPanel({
    super.key,
    required this.onClose,
  });

  @override
  ConsumerState<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends ConsumerState<ChatPanel> {
  late final TextEditingController _chatTextController;
  late final ScrollController _chatScrollController;

  @override
  void initState() {
    super.initState();
    _chatTextController = TextEditingController();
    _chatScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _chatTextController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendCustomMessage() {
    final text = _chatTextController.text;
    if (text.trim().isEmpty) return;
    ref.read(multiplayerProvider.notifier).sendMessage(text.trim());
    _chatTextController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final multiplayerState = ref.watch(multiplayerProvider);
    final size = MediaQuery.of(context).size;

    // Listen to changes in chat messages length to auto-scroll
    ref.listen(multiplayerProvider.select((s) => s.chatMessages.length), (prev, next) {
      _scrollToBottom();
    });

    return Container(
      width: 300,
      height: size.height,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        border: Border(left: BorderSide(color: GameTheme.neonCyan.withValues(alpha: 0.3), width: 1.5)),
        boxShadow: [
          BoxShadow(
            color: GameTheme.neonCyan.withValues(alpha: 0.15),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline, color: GameTheme.neonCyan, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'GAME CHAT',
                      style: TextStyle(
                        color: GameTheme.textWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        shadows: GameTheme.neonGlow(GameTheme.neonCyan, blurRadius: 4),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: GameTheme.textWhite, size: 20),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),

          // Message List
          Expanded(
            child: ListView.builder(
              controller: _chatScrollController,
              padding: const EdgeInsets.all(12),
              itemCount: multiplayerState.chatMessages.length,
              itemBuilder: (context, index) {
                final msg = multiplayerState.chatMessages[index];
                if (msg.isSystem) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        msg.text,
                        style: const TextStyle(color: GameTheme.textGrey, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final isMe = msg.sender == (ref.read(statsProvider).value?.name ?? 'You');
                final senderGlowColor = isMe ? GameTheme.neonCyan : GameTheme.neonPink;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isMe
                          ? GameTheme.neonCyan.withValues(alpha: 0.12)
                          : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
                        bottomRight: isMe ? Radius.zero : const Radius.circular(12),
                      ),
                      border: Border.all(
                        color: isMe
                            ? GameTheme.neonCyan.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isMe)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2.0),
                            child: Text(
                              msg.sender,
                              style: TextStyle(
                                color: senderGlowColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        Text(
                          msg.text,
                          style: const TextStyle(color: GameTheme.textWhite, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Quick Emojis Selection
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.03))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['🔥', '😂', '😭', '👍', '😎', '♠'].map((emoji) {
                return InkWell(
                  onTap: () {
                    ref.read(multiplayerProvider.notifier).sendMessage(emoji);
                    _scrollToBottom();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(emoji, style: const TextStyle(fontSize: 20)),
                  ),
                );
              }).toList(),
            ),
          ),

          // Custom Input Area
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white.withValues(alpha: 0.02),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatTextController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Type message...',
                      hintStyle: const TextStyle(color: GameTheme.textGrey, fontSize: 13),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.04),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: GameTheme.neonCyan.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onSubmitted: (val) {
                      _sendCustomMessage();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: GameTheme.neonCyan, size: 20),
                  onPressed: _sendCustomMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
