import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_of_spades_flutter/models/multiplayer_state.dart';
import 'package:three_of_spades_flutter/providers/multiplayer_notifier.dart';
import 'package:three_of_spades_flutter/providers/stats_provider.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'guest_name': 'TestHero',
      'guest_coins': 8800,
    });
  });

  Future<ProviderContainer> createInitializedContainer() async {
    final container = ProviderContainer();
    // Force lazy initialization of statsProvider
    container.read(statsProvider);
    // Allow async _loadStats to complete
    await Future.delayed(const Duration(milliseconds: 100));
    return container;
  }

  group('Multiplayer Logic Tests', () {
    test('Initial state is idle with empty values', () async {
      final container = await createInitializedContainer();
      addTearDown(container.dispose);

      final state = container.read(multiplayerProvider);
      expect(state.status, MultiplayerStatus.idle);
      expect(state.roomCode, isEmpty);
      expect(state.lobbyPlayers, isEmpty);
      expect(state.chatMessages, isEmpty);
      expect(state.searchTimer, 0);
      expect(state.countdownTimer, 3);
    });

    test('startMatchmaking transitions status to searching and populates user name', () async {
      final container = await createInitializedContainer();
      addTearDown(container.dispose);

      final stats = container.read(statsProvider);
      expect(stats.name, 'TestHero');

      final notifier = container.read(multiplayerProvider.notifier);
      notifier.startMatchmaking();

      final state = container.read(multiplayerProvider);
      expect(state.status, MultiplayerStatus.searching);
      expect(state.lobbyPlayers, contains('TestHero'));
      expect(state.searchTimer, 0);

      // Cancel matchmaking to clean up timers
      notifier.cancelMatchmaking();
    });

    test('createPrivateRoom generates code and initializes room', () async {
      final container = await createInitializedContainer();
      addTearDown(container.dispose);

      final notifier = container.read(multiplayerProvider.notifier);
      notifier.createPrivateRoom();

      final state = container.read(multiplayerProvider);
      expect(state.status, MultiplayerStatus.found);
      expect(state.roomCode, startsWith('TS-'));
      expect(state.lobbyPlayers, contains('TestHero'));
    });

    test('fillWithBots adds bots to reach exactly 4 players', () async {
      final container = await createInitializedContainer();
      addTearDown(container.dispose);

      final notifier = container.read(multiplayerProvider.notifier);
      notifier.createPrivateRoom();

      notifier.fillWithBots();

      final state = container.read(multiplayerProvider);
      expect(state.lobbyPlayers.length, 4);
      expect(state.lobbyPlayers[0], 'TestHero');
      expect(state.lobbyPlayers[1], contains('[Bot]'));
    });

    test('sendMessage appends user message to chatMessages list', () async {
      final container = await createInitializedContainer();
      addTearDown(container.dispose);

      final notifier = container.read(multiplayerProvider.notifier);
      notifier.createPrivateRoom();

      notifier.sendMessage('Hello card game fans!');

      final state = container.read(multiplayerProvider);
      expect(state.chatMessages.length, 1);
      expect(state.chatMessages.first.sender, 'TestHero');
      expect(state.chatMessages.first.text, 'Hello card game fans!');
      expect(state.chatMessages.first.isSystem, isFalse);
    });

    test('triggerSystemMessage appends system message to chatMessages list', () async {
      final container = await createInitializedContainer();
      addTearDown(container.dispose);

      final notifier = container.read(multiplayerProvider.notifier);
      notifier.triggerSystemMessage('Round 1: SpadeMaster is the contractor!');

      final state = container.read(multiplayerProvider);
      expect(state.chatMessages.length, 1);
      expect(state.chatMessages.first.sender, 'System');
      expect(state.chatMessages.first.text, 'Round 1: SpadeMaster is the contractor!');
      expect(state.chatMessages.first.isSystem, isTrue);
    });

    test('triggerPeerReaction sends random emoji reaction', () async {
      final container = await createInitializedContainer();
      addTearDown(container.dispose);

      final notifier = container.read(multiplayerProvider.notifier);
      notifier.createPrivateRoom();
      
      // Add a dummy lobby player so there is someone to react
      notifier.joinPrivateRoom('TS-123456');
      // Wait for the room to join
      await Future.delayed(const Duration(milliseconds: 1600));

      final stateBefore = container.read(multiplayerProvider);
      expect(stateBefore.lobbyPlayers.length, 4);

      notifier.triggerPeerReaction();

      final stateAfter = container.read(multiplayerProvider);
      expect(stateAfter.chatMessages.length, 1);
      expect(stateAfter.chatMessages.first.sender, isNot('TestHero'));
      expect(stateAfter.chatMessages.first.sender, isNot('System'));
    });
  });
}
