import 'package:flutter/material.dart';

class GameTheme {
  // Theme Palette
  static const Color darkBackground = Color(0xFF0F0F16);
  static const Color cardTableColor = Color(0xFF0A2B1D); // Deep green felt look
  
  // Neon accents
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color neonPink = Color(0xFFE040FB);
  static const Color goldAccent = Color(0xFFffd700);
  
  // Text Colors
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFF8F8F9E);

  // Gradients
  static const LinearGradient neonCyanGradient = LinearGradient(
    colors: [Color(0xFF00B0FF), Color(0xFF00E5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonPinkGradient = LinearGradient(
    colors: [Color(0xFFD500F9), Color(0xFFF500FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient tableGradient = RadialGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF0A2510)],
    radius: 1.2,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF101018), Color(0xFF07070A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Neon Shadow Effects
  static List<BoxShadow> neonGlow(Color color, {double blurRadius = 8}) {
    return [
      BoxShadow(
        color: color.withOpacity(0.4),
        blurRadius: blurRadius,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: color.withOpacity(0.2),
        blurRadius: blurRadius * 2,
        spreadRadius: 2,
      ),
    ];
  }

  // Glassmorphism Box Decoration helper
  static BoxDecoration glassDecoration({
    double opacity = 0.08,
    double borderOpacity = 0.15,
    double radius = 16,
    Color borderColor = Colors.white,
  }) {
    return BoxDecoration(
      color: Colors.white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor.withOpacity(borderOpacity),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 10,
          spreadRadius: -2,
        ),
      ],
    );
  }
}
