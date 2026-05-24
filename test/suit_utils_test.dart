import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:three_of_spades_flutter/core/suit_utils.dart';

void main() {
  group('Suit Utils Tests', () {
    test('getSuitSymbol returns correct Unicode symbols', () {
      expect(getSuitSymbol('S'), '♠');
      expect(getSuitSymbol('H'), '♥');
      expect(getSuitSymbol('C'), '♣');
      expect(getSuitSymbol('D'), '♦');
      expect(getSuitSymbol('X'), '?');
      expect(getSuitSymbol(''), '?');
    });

    test('getSuitColor returns correct Colors', () {
      expect(getSuitColor('S'), Colors.white);
      expect(getSuitColor('H'), Colors.red);
      expect(getSuitColor('C'), Colors.white);
      expect(getSuitColor('D'), Colors.red);
      expect(getSuitColor('X'), Colors.white);
    });
  });
}
