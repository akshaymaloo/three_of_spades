enum MultiplayerStatus {
  idle,
  searching,
  found,
  playing,
}

class ChatMessage {
  final String sender;
  final String text;
  final DateTime timestamp;
  final bool isSystem;

  const ChatMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
    this.isSystem = false,
  });
}

class MultiplayerState {
  final MultiplayerStatus status;
  final String roomCode;
  final List<String> lobbyPlayers;
  final List<ChatMessage> chatMessages;
  final int searchTimer;
  final int countdownTimer;

  const MultiplayerState({
    required this.status,
    required this.roomCode,
    required this.lobbyPlayers,
    required this.chatMessages,
    required this.searchTimer,
    required this.countdownTimer,
  });

  factory MultiplayerState.initial() {
    return const MultiplayerState(
      status: MultiplayerStatus.idle,
      roomCode: '',
      lobbyPlayers: [],
      chatMessages: [],
      searchTimer: 0,
      countdownTimer: 3,
    );
  }

  MultiplayerState copyWith({
    MultiplayerStatus? status,
    String? roomCode,
    List<String>? lobbyPlayers,
    List<ChatMessage>? chatMessages,
    int? searchTimer,
    int? countdownTimer,
  }) {
    return MultiplayerState(
      status: status ?? this.status,
      roomCode: roomCode ?? this.roomCode,
      lobbyPlayers: lobbyPlayers ?? this.lobbyPlayers,
      chatMessages: chatMessages ?? this.chatMessages,
      searchTimer: searchTimer ?? this.searchTimer,
      countdownTimer: countdownTimer ?? this.countdownTimer,
    );
  }
}
