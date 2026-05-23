import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

// ---------------------------------------------------------------------------
// BaseMultiplayerSyncService – abstract contract for real-time multiplayer.
// ---------------------------------------------------------------------------

abstract class BaseMultiplayerSyncService {
  Future<String> createRoom(String hostName);
  Future<bool> joinRoom(String code, String playerName);
  Future<void> leaveRoom(String code);
  Future<List<String>> getLobbyPlayers(String code);
  Future<void> broadcastGameAction(
      String code, Map<String, dynamic> action);
  Stream<Map<String, dynamic>> listenToGameState(String code);
  Future<void> sendChat(String code, String sender, String text);
  Stream<Map<String, dynamic>> listenToChat(String code);
  Stream<List<String>> listenToLobbyPlayers(String code);
}

// ---------------------------------------------------------------------------
// MockMultiplayerSyncService – local in-memory implementation for offline
// development and single-device testing.
// ---------------------------------------------------------------------------

class MockMultiplayerSyncService implements BaseMultiplayerSyncService {
  final Random _random = Random();

  /// Room code → list of player names.
  final Map<String, List<String>> _rooms = {};

  @override
  Future<String> createRoom(String hostName) async {
    final code = 'TS-${_random.nextInt(900000) + 100000}';
    _rooms[code] = [hostName];
    return code;
  }

  @override
  Future<bool> joinRoom(String code, String playerName) async {
    final players = _rooms[code];
    if (players == null) return false;
    if (players.length >= 4) return false;
    players.add(playerName);
    return true;
  }

  @override
  Future<void> leaveRoom(String code) async {
    _rooms.remove(code);
  }

  @override
  Future<List<String>> getLobbyPlayers(String code) async {
    return List<String>.from(_rooms[code] ?? []);
  }

  @override
  Future<void> broadcastGameAction(
      String code, Map<String, dynamic> action) async {
    // No-op in mock – actions are handled locally.
  }

  @override
  Stream<Map<String, dynamic>> listenToGameState(String code) {
    return const Stream<Map<String, dynamic>>.empty();
  }

  @override
  Future<void> sendChat(String code, String sender, String text) async {
    // No-op in mock – chat is handled locally by MultiplayerNotifier.
  }

  @override
  Stream<Map<String, dynamic>> listenToChat(String code) {
    return const Stream<Map<String, dynamic>>.empty();
  }

  @override
  Stream<List<String>> listenToLobbyPlayers(String code) {
    return const Stream<List<String>>.empty();
  }
}



// ---------------------------------------------------------------------------
// LiveMultiplayerSyncService – real Cloud Firestore integration.
// ---------------------------------------------------------------------------

class LiveMultiplayerSyncService implements BaseMultiplayerSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentReference?> _getRoomDoc(String code) async {
    final query = await _firestore
        .collection('rooms')
        .where('code', isEqualTo: code)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return query.docs.first.reference;
  }

  @override
  Future<String> createRoom(String hostName) async {
    final Random random = Random();
    final code = 'TS-${random.nextInt(900000) + 100000}';

    await _firestore.collection('rooms').add({
      'code': code,
      'players': [hostName],
      'status': 'waiting',
      'createdAt': FieldValue.serverTimestamp(),
      'gameState': <String, dynamic>{},
    });

    return code;
  }

  @override
  Future<bool> joinRoom(String code, String playerName) async {
    final docRef = await _getRoomDoc(code);
    if (docRef == null) return false;

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return false;

      final data = snapshot.data() as Map<String, dynamic>? ?? {};
      final players = List<String>.from(data['players'] ?? []);
      final status = data['status'] ?? 'waiting';

      if (players.length >= 4 || status != 'waiting') {
        return false;
      }

      players.add(playerName);
      transaction.update(docRef, {'players': players});
      return true;
    });
  }

  @override
  Future<void> leaveRoom(String code) async {
    final docRef = await _getRoomDoc(code);
    if (docRef == null) return;

    // Simple deletion or player list removal.
    // For this prototype, we'll just delete the room if the host leaves,
    // or remove the player if others remain.
    final doc = await docRef.get();
    if (!doc.exists) return;

    final data = doc.data() as Map<String, dynamic>? ?? {};
    final players = List<String>.from(data['players'] ?? []);
    if (players.length <= 1) {
      await docRef.delete();
    } else {
      // Just delete the room for simplicity to clean up
      await docRef.delete();
    }
  }

  @override
  Future<List<String>> getLobbyPlayers(String code) async {
    final docRef = await _getRoomDoc(code);
    if (docRef == null) return [];
    final doc = await docRef.get();
    if (!doc.exists) return [];
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return List<String>.from(data['players'] ?? []);
  }

  @override
  Future<void> broadcastGameAction(
      String code, Map<String, dynamic> action) async {
    final docRef = await _getRoomDoc(code);
    if (docRef == null) return;
    await docRef.update({'gameState': action});
  }

  @override
  Stream<Map<String, dynamic>> listenToGameState(String code) {
    // Return a stream that queries and maps snapshots
    return _firestore
        .collection('rooms')
        .where('code', isEqualTo: code)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return <String, dynamic>{};
      final data = snapshot.docs.first.data();
      return Map<String, dynamic>.from(data['gameState'] ?? {});
    });
  }

  @override
  Future<void> sendChat(String code, String sender, String text) async {
    final docRef = await _getRoomDoc(code);
    if (docRef == null) return;
    await docRef.collection('chat').add({
      'sender': sender,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<Map<String, dynamic>> listenToChat(String code) {
    return _firestore
        .collection('rooms')
        .where('code', isEqualTo: code)
        .limit(1)
        .snapshots()
        .asyncExpand((roomSnap) {
      if (roomSnap.docs.isEmpty) return const Stream.empty();
      final docRef = roomSnap.docs.first.reference;
      return docRef
          .collection('chat')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots()
          .map((chatSnap) {
        if (chatSnap.docs.isEmpty) return <String, dynamic>{};
        final doc = chatSnap.docs.first;
        final data = doc.data();
        return {
          'sender': data['sender'] ?? 'System',
          'text': data['text'] ?? '',
          'timestamp': (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        };
      });
    });
  }

  @override
  Stream<List<String>> listenToLobbyPlayers(String code) {
    return _firestore
        .collection('rooms')
        .where('code', isEqualTo: code)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return [];
      final data = snapshot.docs.first.data();
      return List<String>.from(data['players'] ?? []);
    });
  }
}
