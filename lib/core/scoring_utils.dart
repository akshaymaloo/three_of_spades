List<int> calculateCoinDeltas({
  required int winningBid,
  required int bidderIndex,
  required int partnerIndex,
  required bool isBidWon,
}) {
  final deltas = List<int>.filled(4, 0);
  final bid = winningBid;
  if (isBidWon) {
    final bidderGain = bid * 2;
    deltas[bidderIndex] = bidderGain;
    if (bidderIndex == partnerIndex) {
      // Lone wolf
      final defenderLoss = (bidderGain / 3).floor();
      for (int i = 0; i < 4; i++) {
        if (i != bidderIndex) {
          deltas[i] = -defenderLoss;
        }
      }
    } else {
      // Alliance
      final partnerGain = bid;
      deltas[partnerIndex] = partnerGain;
      final totalGain = bidderGain + partnerGain;
      final defenderLoss = (totalGain / 2).floor();
      for (int i = 0; i < 4; i++) {
        if (i != bidderIndex && i != partnerIndex) {
          deltas[i] = -defenderLoss;
        }
      }
    }
  } else {
    final bidderLoss = (bid * 1.5).floor();
    deltas[bidderIndex] = -bidderLoss;
    if (bidderIndex == partnerIndex) {
      // Lone wolf
      final defenderGain = (bidderLoss / 3).floor();
      for (int i = 0; i < 4; i++) {
        if (i != bidderIndex) {
          deltas[i] = defenderGain;
        }
      }
    } else {
      // Alliance
      final partnerLoss = (bid * 0.75).floor();
      deltas[partnerIndex] = -partnerLoss;
      final totalLoss = bidderLoss + partnerLoss;
      final defenderGain = (totalLoss / 2).floor();
      for (int i = 0; i < 4; i++) {
        if (i != bidderIndex && i != partnerIndex) {
          deltas[i] = defenderGain;
        }
      }
    }
  }
  return deltas;
}
