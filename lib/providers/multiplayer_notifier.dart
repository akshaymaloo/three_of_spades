import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/multiplayer_state.dart';
import 'game_notifier.dart';
import 'stats_provider.dart';
import 'config_provider.dart';
import 'service_providers.dart';

class MultiplayerNotifier extends Notifier<MultiplayerState> {
  Timer? _searchTimer;
  Timer? _countdownTimer;
  final List<Timer> _simulatedTimers = [];
  final Random _random = Random();

  StreamSubscription? _lobbyPlayersSubscription;
  StreamSubscription? _chatSubscription;
  StreamSubscription? _gameStateSubscription;

  @override
  MultiplayerState build() {
    ref.onDispose(() {
      _searchTimer?.cancel();
      _countdownTimer?.cancel();
      _clearSimulatedTimers();
      _lobbyPlayersSubscription?.cancel();
      _chatSubscription?.cancel();
      _gameStateSubscription?.cancel();
    });
    return MultiplayerState.initial();
  }

  void _clearSimulatedTimers() {
    for (final timer in _simulatedTimers) {
      timer.cancel();
    }
    _simulatedTimers.clear();
  }

  void startMatchmaking() {
    _searchTimer?.cancel();
    _countdownTimer?.cancel();
    _clearSimulatedTimers();
    _lobbyPlayersSubscription?.cancel();

    final config = ref.read(configProvider);
    if (config.onlineMode) {
      _startMatchmakingLive();
      return;
    }

    final userName = ref.read(statsProvider).value?.name ?? 'Guest Player';
    state = MultiplayerState.initial().copyWith(
      status: MultiplayerStatus.searching,
      lobbyPlayers: [userName],
    );

    int elapsedSeconds = 0;
    _searchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
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

  Future<void> _startMatchmakingLive() async {
    final userName = ref.read(statsProvider).value?.name ?? 'Guest Player';
    state = MultiplayerState.initial().copyWith(
      status: MultiplayerStatus.searching,
      lobbyPlayers: [userName],
    );

    try {
      final service = ref.read(multiplayerSyncServiceProvider);

      // Query rooms
      final firestore = FirebaseFirestore.instance;
      final roomsQuery = await firestore
          .collection('rooms')
          .where('status', isEqualTo: 'waiting')
          .orderBy('createdAt', descending: false)
          .limit(10)
          .get();

      String? joinedCode;
      for (final doc in roomsQuery.docs) {
        final code = doc.data()['code'] as String;
        final success = await service.joinRoom(code, userName);
        if (success) {
          joinedCode = code;
          break;
        }
      }

      if (joinedCode == null) {
        joinedCode = await service.createRoom(userName);
      }

      state = state.copyWith(roomCode: joinedCode);
      _startListeningToChat(joinedCode);

      _lobbyPlayersSubscription = service.listenToLobbyPlayers(joinedCode).listen((players) {
        state = state.copyWith(lobbyPlayers: players);
        if (players.length == 4 && state.status == MultiplayerStatus.searching) {
          _startStartCountdownLive(joinedCode!);
        }
      });
    } catch (e, stack) {
      debugPrint('Failed live matchmaking: $e\n$stack');
      triggerSystemMessage('Connection failed. Switching to Simulation Mode.');
      // fallback to mock
      ref.read(configProvider.notifier).setFirebaseAvailable(false);
      startMatchmaking();
    }
  }

  void _startStartCountdownLive(String code) {
    _searchTimer?.cancel();
    state = state.copyWith(
      status: MultiplayerStatus.found,
      countdownTimer: 3,
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentCount = state.countdownTimer - 1;
      state = state.copyWith(countdownTimer: currentCount);

      if (currentCount <= 0) {
        _countdownTimer?.cancel();
        _startGameplayLive(code);
      }
    });
  }

  void _startGameplayLive(String code) {
    state = state.copyWith(status: MultiplayerStatus.playing);
    final players = state.lobbyPlayers;
    ref.read(gameProvider.notifier).startNewMultiplayerGame(players);
  }

  void cancelMatchmaking() {
    _searchTimer?.cancel();
    _countdownTimer?.cancel();
    _clearSimulatedTimers();
    _lobbyPlayersSubscription?.cancel();
    _chatSubscription?.cancel();

    final config = ref.read(configProvider);
    if (config.onlineMode && state.roomCode != null) {
      ref.read(multiplayerSyncServiceProvider).leaveRoom(state.roomCode!);
    }

    state = MultiplayerState.initial();
  }

  void createPrivateRoom() {
    _searchTimer?.cancel();
    _countdownTimer?.cancel();
    _clearSimulatedTimers();
    _lobbyPlayersSubscription?.cancel();

    final userName = ref.read(statsProvider).value?.name ?? 'Guest Player';
    final config = ref.read(configProvider);

    if (config.onlineMode) {
      _createPrivateRoomLive(userName);
      return;
    }

    final code = 'TS-${_random.nextInt(900000) + 100000}';
    state = MultiplayerState.initial().copyWith(
      status: MultiplayerStatus.found,
      roomCode: code,
      lobbyPlayers: [userName],
    );

    // Simulate other players joining the private room after short delays
    _simulatedTimers.add(Timer(const Duration(seconds: 2), () {
      if (state.roomCode == code && state.lobbyPlayers.length < 4) {
        _addLobbyPlayer(_randomPeerName());
      }
    }));
    _simulatedTimers.add(Timer(const Duration(seconds: 4), () {
      if (state.roomCode == code && state.lobbyPlayers.length < 4) {
        _addLobbyPlayer(_randomPeerName());
      }
    }));
    _simulatedTimers.add(Timer(const Duration(seconds: 5), () {
      if (state.roomCode == code && state.lobbyPlayers.length < 4) {
        _addLobbyPlayer(_randomPeerName());
      }
    }));
  }

  Future<void> _createPrivateRoomLive(String userName) async {
    try {
      final service = ref.read(multiplayerSyncServiceProvider);
      final code = await service.createRoom(userName);
      state = MultiplayerState.initial().copyWith(
        status: MultiplayerStatus.found,
        roomCode: code,
        lobbyPlayers: [userName],
      );
      _startListeningToChat(code);

      _lobbyPlayersSubscription = service.listenToLobbyPlayers(code).listen((players) {
        state = state.copyWith(lobbyPlayers: players);
      });
    } catch (e, stack) {
      debugPrint('Failed to create private room live: $e\n$stack');
      triggerSystemMessage('Connection failed. Switching to Simulation Mode.');
      ref.read(configProvider.notifier).setFirebaseAvailable(false);
      createPrivateRoom();
    }
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
    _clearSimulatedTimers();
    _lobbyPlayersSubscription?.cancel();

    final userName = ref.read(statsProvider).value?.name ?? 'Guest Player';
    final config = ref.read(configProvider);

    if (config.onlineMode) {
      _joinPrivateRoomLive(code, userName);
      return;
    }

    state = MultiplayerState.initial().copyWith(
      status: MultiplayerStatus.searching,
      roomCode: code,
      lobbyPlayers: [userName],
    );

    // Simulate quick loading and joining room with existing players
    _simulatedTimers.add(Timer(const Duration(milliseconds: 1500), () {
      state = state.copyWith(
        status: MultiplayerStatus.found,
        lobbyPlayers: [userName, _randomPeerName(), _randomPeerName(), _randomPeerName()],
      );
    }));
  }

  Future<void> _joinPrivateRoomLive(String code, String userName) async {
    state = MultiplayerState.initial().copyWith(
      status: MultiplayerStatus.searching,
      roomCode: code,
      lobbyPlayers: [userName],
    );

    try {
      final service = ref.read(multiplayerSyncServiceProvider);
      final success = await service.joinRoom(code, userName);
      if (success) {
        state = state.copyWith(
          status: MultiplayerStatus.found,
        );
        _startListeningToChat(code);

        _lobbyPlayersSubscription = service.listenToLobbyPlayers(code).listen((players) {
          state = state.copyWith(lobbyPlayers: players);
        });
      } else {
        triggerSystemMessage('Failed to join room: Room full or does not exist.');
        state = MultiplayerState.initial();
      }
    } catch (e, stack) {
      debugPrint('Failed to join private room live: $e\n$stack');
      triggerSystemMessage('Connection failed. Switching to Simulation Mode.');
      ref.read(configProvider.notifier).setFirebaseAvailable(false);
      joinPrivateRoom(code);
    }
  }

  void _startListeningToChat(String code) {
    _chatSubscription?.cancel();
    final service = ref.read(multiplayerSyncServiceProvider);
    _chatSubscription = service.listenToChat(code).listen((chatMap) {
      if (chatMap.isNotEmpty) {
        final newMsg = ChatMessage(
          sender: chatMap['sender'] as String,
          text: chatMap['text'] as String,
          timestamp: chatMap['timestamp'] as DateTime,
        );
        if (!state.chatMessages.any((m) =>
            m.sender == newMsg.sender &&
            m.text == newMsg.text &&
            m.timestamp.difference(newMsg.timestamp).inSeconds.abs() < 2)) {
          state = state.copyWith(
            chatMessages: [...state.chatMessages, newMsg],
          );
        }
      }
    });
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final userName = ref.read(statsProvider).value?.name ?? 'Guest Player';
    final userMsg = ChatMessage(
      sender: userName,
      text: text,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      chatMessages: [...state.chatMessages, userMsg],
    );

    final config = ref.read(configProvider);
    if (config.onlineMode && state.roomCode != null) {
      ref.read(multiplayerSyncServiceProvider).sendChat(state.roomCode!, userName, text);
      return;
    }

    // Trigger simulated reply from other players in mock mode
    _simulatedTimers.add(Timer(Duration(milliseconds: 1000 + _random.nextInt(1500)), () {
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
    }));
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
    final userName = ref.read(statsProvider).value?.name ?? 'Guest Player';
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
    _clearSimulatedTimers();
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

final multiplayerProvider = NotifierProvider<MultiplayerNotifier, MultiplayerState>(() {
  return MultiplayerNotifier();
});
