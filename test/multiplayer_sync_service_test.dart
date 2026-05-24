import 'package:flutter_test/flutter_test.dart';
import 'package:three_of_spades_flutter/services/multiplayer_sync_service.dart';

void main() {
  test('MockMultiplayerSyncService room creation and joining', () async {
    final service = MockMultiplayerSyncService();

    // Create room
    final code = await service.createRoom('HostPlayer');
    expect(code, startsWith('TS-'));
    expect(code.length, equals(9)); // TS-XXXXXX (3 + 6 = 9)

    // Get lobby players
    var players = await service.getLobbyPlayers(code);
    expect(players, equals(['HostPlayer']));

    // Join room
    var success = await service.joinRoom(code, 'Player2');
    expect(success, isTrue);
    players = await service.getLobbyPlayers(code);
    expect(players, equals(['HostPlayer', 'Player2']));

    // Join more players
    await service.joinRoom(code, 'Player3');
    await service.joinRoom(code, 'Player4');
    players = await service.getLobbyPlayers(code);
    expect(players.length, equals(4));

    // Try to join fifth player
    success = await service.joinRoom(code, 'Player5');
    expect(success, isFalse); // Max 4 players

    // Broadcast action (does nothing but should not throw)
    await service.broadcastGameAction(code, {'action': 'bid'});

    // Listen to game state (empty stream)
    final stream = service.listenToGameState(code);
    final isStreamEmpty = await stream.isEmpty;
    expect(isStreamEmpty, isTrue);

    // Send chat (does nothing but should not throw)
    await service.sendChat(code, 'HostPlayer', 'Hello');

    // Listen to chat (empty stream)
    final chatStream = service.listenToChat(code);
    final isChatStreamEmpty = await chatStream.isEmpty;
    expect(isChatStreamEmpty, isTrue);

    // Listen to lobby players (empty stream)
    final lobbyStream = service.listenToLobbyPlayers(code);
    final isLobbyStreamEmpty = await lobbyStream.isEmpty;
    expect(isLobbyStreamEmpty, isTrue);

    // Leave room
    await service.leaveRoom(code);
    players = await service.getLobbyPlayers(code);
    expect(players, isEmpty);
  });
}
