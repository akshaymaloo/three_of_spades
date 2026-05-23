import 'package:flutter/material.dart';

class GameTheme {
  // Theme Palette
  static const Color darkBackground = Color(0xFF121212); // Clean dark charcoal
  static const Color cardTableColor = Color(0xFF0F3E2B); // Classic forest green felt look
  
  // Classic solid accents (replacing neon colors)
  static const Color neonCyan = Color(0xFF2196F3);  // Standard Blue
  static const Color neonGreen = Color(0xFF2E7D32); // Standard Green
  static const Color neonPink = Color(0xFFD32F2F);  // Standard Red
  static const Color goldAccent = Color(0xFFFFC107); // Standard Gold
  
  // Text Colors
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFFB0B0B0); // Lighter, clearer gray

  // Gradients
  static const LinearGradient neonCyanGradient = LinearGradient(
    colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonPinkGradient = LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFFC62828)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient tableGradient = RadialGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF0D3E1A)],
    radius: 1.2,
  );

  static Gradient tableGradientForTheme(String theme) {
    switch (theme) {
      case 'blue':
        return const RadialGradient(colors: [Color(0xFF1565C0), Color(0xFF0D47A1)], radius: 1.2);
      case 'red':
        return const RadialGradient(colors: [Color(0xFFC62828), Color(0xFF8E0000)], radius: 1.2);
      case 'purple':
        return const RadialGradient(colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)], radius: 1.2);
      case 'orange':
        return const RadialGradient(colors: [Color(0xFFEF6C00), Color(0xFFE65100)], radius: 1.2);
      case 'brown':
        return const RadialGradient(colors: [Color(0xFF4E342E), Color(0xFF3E2723)], radius: 1.2);
      case 'pink':
        return const RadialGradient(colors: [Color(0xFFAD1457), Color(0xFF880E4F)], radius: 1.2);
      case 'yellow':
        return const RadialGradient(colors: [Color(0xFFF9A825), Color(0xFFF57F17)], radius: 1.2);
      case 'green':
      default:
        return tableGradient;
    }
  }

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF1E1E1E), Color(0xFF121212)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Soft Standard Shadows (replacing neon glows)
  static List<BoxShadow> neonGlow(Color color, {double blurRadius = 8}) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.25),
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ];
  }

  // Modern Flat Card Decoration (replacing glassmorphism)
  static BoxDecoration glassDecoration({
    double opacity = 0.08,
    double borderOpacity = 0.15,
    double radius = 16,
    Color borderColor = Colors.white,
  }) {
    return BoxDecoration(
      color: const Color(0xFF1E1E1E), // Solid dark grey card background
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.08),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
