import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/multiplayer_state.dart';
import 'game_notifier.dart';
import 'stats_provider.dart';

class MultiplayerNotifier extends StateNotifier<MultiplayerState> {
  final Ref ref;
  Timer? _searchTimer;
  Timer? _countdownTimer;
  final Random _random = Random();

  MultiplayerNotifier(this.ref) : super(MultiplayerState.initial());

  @override
  void dispose() {
    _searchTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void startMatchmaking() {
    _searchTimer?.cancel();
    _countdownTimer?.cancel();

    final userName = ref.read(statsProvider).name;
    state = MultiplayerState.initial().copyWith(
      status: MultiplayerStatus.searching,
      lobbyPlayers: [userName],
    );

    int elapsedSeconds = 0;
    _searchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      elapsedSeconds++;
      state = state.copyWith(searchTimer: elapsedSeconds);

      // Simulate player joining
      if (elapsedSeconds == 1) {
        _addLobbyPlayer(_randomPeerName());
      } else if (elapsedSeconds == 3) {
        _addLobbyPlayer(_randomPeerName());
      } else if (elapsedSeconds == 4) {
        _addLobbyPlayer(_randomPeerName());
        _startStartCountdown();
      }
    });
  }

  void cancelMatchmaking() {
    _searchTimer?.cancel();
    _countdownTimer?.cancel();
    state = MultiplayerState.initial();
  }

  void createPrivateRoom() {
    _searchTimer?.cancel();
    _countdownTimer?.cancel();

    final userName = ref.read(statsProvider).name;
    final code = 'TS-${_random.nextInt(900000) + 100000}';
    state = MultiplayerState.initial().copyWith(
      status: MultiplayerStatus.found,
      roomCode: code,
      lobbyPlayers: [userName],
    );

    // Simulate other players joining the private room after short delays
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && state.roomCode == code && state.lobbyPlayers.length < 4) {
        _addLobbyPlayer(_randomPeerName());
      }
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && state.roomCode == code && state.lobbyPlayers.length < 4) {
        _addLobbyPlayer(_randomPeerName());
      }
    });
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && state.roomCode == code && state.lobbyPlayers.length < 4) {
        _addLobbyPlayer(_randomPeerName());
      }
    });
  }

  void fillWithBots() {
    if (state.lobbyPlayers.length >= 4) return;
    final currentPlayers = List<String>.from(state.lobbyPlayers);
    while (currentPlayers.length < 4) {
      currentPlayers.add('${_randomPeerName()} [Bot]');
    }
    state = state.copyWith(lobbyPlayers: currentPlayers);
  }

  void joinPrivateRoom(String code) {
    _searchTimer?.cancel();
    _countdownTimer?.cancel();

    final userName = ref.read(statsProvider).name;
    state = MultiplayerState.initial().copyWith(
      status: MultiplayerStatus.searching,
      roomCode: code,
      lobbyPlayers: [userName],
    );

    // Simulate quick loading and joining room with existing players
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      state = state.copyWith(
        status: MultiplayerStatus.found,
        lobbyPlayers: [userName, _randomPeerName(), _randomPeerName(), _randomPeerName()],
      );
    });
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final userName = ref.read(statsProvider).name;
    final userMsg = ChatMessage(
      sender: userName,
      text: text,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      chatMessages: [...state.chatMessages, userMsg],
    );

    // Trigger simulated reply from other players
    Future.delayed(Duration(milliseconds: 1000 + _random.nextInt(1500)), () {
      if (!mounted) return;
      final peers = state.lobbyPlayers.where((name) => name != userName).toList();
      if (peers.isNotEmpty) {
        final responder = peers[_random.nextInt(peers.length)];
        final replyText = _generateChatResponse(text);
        final peerMsg = ChatMessage(
          sender: responder,
          text: replyText,
          timestamp: DateTime.now(),
        );
        state = state.copyWith(
          chatMessages: [...state.chatMessages, peerMsg],
        );
      }
    });
  }

  void triggerSystemMessage(String text) {
    final sysMsg = ChatMessage(
      sender: 'System',
      text: text,
      timestamp: DateTime.now(),
      isSystem: true,
    );
    state = state.copyWith(
      chatMessages: [...state.chatMessages, sysMsg],
    );
  }

  void triggerPeerReaction() {
    final userName = ref.read(statsProvider).name;
    final peers = state.lobbyPlayers.where((name) => name != userName).toList();
    if (peers.isEmpty) return;
    
    final responder = peers[_random.nextInt(peers.length)];
    final reaction = _randomReaction();
    final msg = ChatMessage(
      sender: responder,
      text: reaction,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(chatMessages: [...state.chatMessages, msg]);
  }

  void startGameDirectly() {
    _searchTimer?.cancel();
    _countdownTimer?.cancel();
    _startGameplay();
  }

  void _addLobbyPlayer(String name) {
    if (state.lobbyPlayers.length >= 4) return;
    state = state.copyWith(
      lobbyPlayers: [...state.lobbyPlayers, name],
    );
  }

  void _startStartCountdown() {
    _searchTimer?.cancel();
    state = state.copyWith(
      status: MultiplayerStatus.found,
      countdownTimer: 3,
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final currentCount = state.countdownTimer - 1;
      state = state.copyWith(countdownTimer: currentCount);

      if (currentCount <= 0) {
        _countdownTimer?.cancel();
        _startGameplay();
      }
    });
  }

  void _startGameplay() {
    state = state.copyWith(status: MultiplayerStatus.playing);
    
    // Fill up players list to 4 if somehow smaller
    final currentPlayers = List<String>.from(state.lobbyPlayers);
    while (currentPlayers.length < 4) {
      currentPlayers.add(_randomPeerName());
    }

    // Configure the GameNotifier with custom player names
    ref.read(gameProvider.notifier).startNewMultiplayerGame(currentPlayers);
  }

  String _randomPeerName() {
    final list = [
      'NeonAce ♠',
      'CardShark99',
      'KaaliKing',
      'TeeggiMaster',
      'SpadeSlayer',
      'DoubleBidder',
      'TrumpTrump',
      'GoldPlayer',
      'CyberDealers',
      'VoltTricks',
    ];
    return list[_random.nextInt(list.length)];
  }

  String _randomReaction() {
    final list = ['🔥', '😂', '😭', '👍', '😎', '😮', '♠', '🎉'];
    return list[_random.nextInt(list.length)];
  }

  String _generateChatResponse(String originalMessage) {
    final clean = originalMessage.toLowerCase().trim();
    if (clean.contains('hello') || clean.contains('hi') || clean.contains('hey')) {
      return ['Hey there!', 'Hello!', 'Whats up!', 'Gl hf!'][_random.nextInt(4)];
    }
    if (clean.contains('gl') || clean.contains('hf') || clean.contains('good luck')) {
      return ['Glhf!', 'Thanks, you too!', 'May the best player win!'][_random.nextInt(3)];
    }
    if (clean.contains('win') || clean.contains('lose') || clean.contains('kaali')) {
      return ['I will get Kaali!', 'Let\'s see!', 'No way, I am bidding high!'][_random.nextInt(3)];
    }
    return ['Nice!', 'Let\'s go!', '♠', '👍', 'Haha', 'Nice cards!'][_random.nextInt(6)];
  }
}

final multiplayerProvider = StateNotifierProvider<MultiplayerNotifier, MultiplayerState>((ref) {
  return MultiplayerNotifier(ref);
});
