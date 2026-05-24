import 'package:flutter_test/flutter_test.dart';
import 'package:three_of_spades_flutter/core/scoring_utils.dart';

void main() {
  group('Scoring Utils Tests', () {
    test('Alliance win: bidder gets bid*2, partner gets bid, defenders lose equally', () {
      final deltas = calculateCoinDeltas(
        winningBid: 100,
        bidderIndex: 0,
        partnerIndex: 1,
        isBidWon: true,
      );

      // Bidder gets 200, Partner gets 100. Total = 300. Defenders (2, 3) lose 150 each.
      expect(deltas[0], 200);
      expect(deltas[1], 100);
      expect(deltas[2], -150);
      expect(deltas[3], -150);
    });

    test('Alliance loss: bidder loses bid*1.5, partner loses bid*0.75, defenders gain equally', () {
      final deltas = calculateCoinDeltas(
        winningBid: 100,
        bidderIndex: 0,
        partnerIndex: 1,
        isBidWon: false,
      );

      // Bidder loses 150, Partner loses 75. Total loss = 225. Defenders gain 112 each.
      expect(deltas[0], -150);
      expect(deltas[1], -75);
      expect(deltas[2], 112);
      expect(deltas[3], 112);
    });

    test('Lone wolf win: bidder gets bid*2, defenders lose equally', () {
      final deltas = calculateCoinDeltas(
        winningBid: 100,
        bidderIndex: 0,
        partnerIndex: 0,
        isBidWon: true,
      );

      // Bidder gets 200. Total gain = 200. Defenders (1, 2, 3) lose 66 each.
      expect(deltas[0], 200);
      expect(deltas[1], -66);
      expect(deltas[2], -66);
      expect(deltas[3], -66);
    });

    test('Lone wolf loss: bidder loses bid*1.5, defenders gain equally', () {
      final deltas = calculateCoinDeltas(
        winningBid: 100,
        bidderIndex: 0,
        partnerIndex: 0,
        isBidWon: false,
      );

      // Bidder loses 150. Defenders gain 50 each.
      expect(deltas[0], -150);
      expect(deltas[1], 50);
      expect(deltas[2], 50);
      expect(deltas[3], 50);
    });
  });
}
