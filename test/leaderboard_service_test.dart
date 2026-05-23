import 'package:flutter_test/flutter_test.dart';
import 'package:three_of_spades_flutter/services/leaderboard_service.dart';

void main() {
  test('MockLeaderboardService fetches top players', () async {
    final service = MockLeaderboardService();
    
    // Fetch top 5
    final entries = await service.fetchTopPlayers(limit: 5);
    expect(entries.length, equals(5));
    expect(entries.first.rank, equals(1));
    expect(entries.first.name, equals('SpadeSlayer'));
    expect(entries.first.coins, equals(98500));
    
    // Sorting order check
    for (int i = 0; i < entries.length - 1; i++) {
      expect(entries[i].coins >= entries[i + 1].coins, isTrue);
    }
  });
}
