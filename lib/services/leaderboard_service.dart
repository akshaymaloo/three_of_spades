import 'package:cloud_firestore/cloud_firestore.dart';

// ---------------------------------------------------------------------------
// LeaderboardEntry – single row in the leaderboard table.
// ---------------------------------------------------------------------------

class LeaderboardEntry {
  final int rank;
  final String name;
  final int coins;
  final int gamesWon;
  final String? avatarUrl;

  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.coins,
    required this.gamesWon,
    this.avatarUrl,
  });
}

// ---------------------------------------------------------------------------
// LeaderboardPeriod – time-range filter for leaderboard queries.
// ---------------------------------------------------------------------------

enum LeaderboardPeriod { daily, allTime }

// ---------------------------------------------------------------------------
// BaseLeaderboardService – abstract contract.
// ---------------------------------------------------------------------------

abstract class BaseLeaderboardService {
  Future<List<LeaderboardEntry>> fetchTopPlayers({
    LeaderboardPeriod period = LeaderboardPeriod.allTime,
    int limit = 10,
  });

  Future<void> submitScore(String userId, int coins);
}

// ---------------------------------------------------------------------------
// MockLeaderboardService – hardcoded data for offline / dev mode.
// ---------------------------------------------------------------------------

class MockLeaderboardService implements BaseLeaderboardService {
  static const List<LeaderboardEntry> _mockPlayers = [
    LeaderboardEntry(rank: 1, name: 'SpadeSlayer', coins: 98500, gamesWon: 312),
    LeaderboardEntry(rank: 2, name: 'KaaliKing', coins: 87200, gamesWon: 278),
    LeaderboardEntry(rank: 3, name: 'NeonAce ♠', coins: 76800, gamesWon: 245),
    LeaderboardEntry(rank: 4, name: 'TrumpTrump', coins: 65400, gamesWon: 210),
    LeaderboardEntry(rank: 5, name: 'CardShark99', coins: 54100, gamesWon: 189),
    LeaderboardEntry(rank: 6, name: 'DoubleBidder', coins: 43700, gamesWon: 162),
    LeaderboardEntry(rank: 7, name: 'GoldPlayer', coins: 32900, gamesWon: 134),
    LeaderboardEntry(rank: 8, name: 'VoltTricks', coins: 21500, gamesWon: 108),
    LeaderboardEntry(rank: 9, name: 'TeeggiMaster', coins: 15200, gamesWon: 87),
    LeaderboardEntry(rank: 10, name: 'CyberDealers', coins: 9800, gamesWon: 56),
  ];

  @override
  Future<List<LeaderboardEntry>> fetchTopPlayers({
    LeaderboardPeriod period = LeaderboardPeriod.allTime,
    int limit = 10,
  }) async {
    // Simulate network latency.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _mockPlayers.take(limit).toList();
  }

  @override
  Future<void> submitScore(String userId, int coins) async {
    // No-op in mock – scores stay local.
  }
}



// ---------------------------------------------------------------------------
// LiveLeaderboardService – real Cloud Firestore leaderboard.
// ---------------------------------------------------------------------------

class LiveLeaderboardService implements BaseLeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<LeaderboardEntry>> fetchTopPlayers({
    LeaderboardPeriod period = LeaderboardPeriod.allTime,
    int limit = 10,
  }) async {
    // We order by coins descending to find the top players.
    // period can map to different collections if we store daily leaderboard documents,
    // but for simplicity we will query the main 'users' collection.
    final querySnapshot = await _firestore
        .collection('users')
        .orderBy('coins', descending: true)
        .limit(limit)
        .get();

    final entries = <LeaderboardEntry>[];
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      final doc = querySnapshot.docs[i];
      final data = doc.data();
      entries.add(LeaderboardEntry(
        rank: i + 1,
        name: data['name'] ?? 'Player',
        coins: data['coins'] ?? 0,
        gamesWon: data['gamesWon'] ?? 0,
        avatarUrl: data['avatarUrl'],
      ));
    }
    return entries;
  }

  @override
  Future<void> submitScore(String userId, int coins) async {
    // Merge updates into the user's document
    await _firestore.collection('users').doc(userId).set({
      'coins': coins,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
