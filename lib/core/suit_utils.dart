import 'package:flutter/material.dart';

String getSuitSymbol(String suitChar) {
  switch (suitChar) {
    case 'S':
      return '♠';
    case 'H':
      return '♥';
    case 'C':
      return '♣';
    case 'D':
      return '♦';
    default:
      return '?';
  }
}

Color getSuitColor(String suitChar) {
  if (suitChar == 'H' || suitChar == 'D') {
    return Colors.red;
  }
  return Colors.white;
}
