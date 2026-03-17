import 'package:flutter/material.dart';

/// Central place for Edica theme colors (inspired by the logo).
class EdicaPalette {
  // Logo / brand core
  static const Color navy = Color(0xFF001D3D);
  static const Color indigo = Color(0xFF6366F1);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color sky = Color(0xFF4CC9F0);
  static const Color green = Color(0xFF34D399);

  // Dark page background (logo-based)
  static const Color bgTop = Color(0xFF001D3D); // navy
  static const Color bgMid = Color(0xFF0B1026); // deep blue/purple
  static const Color bgBottom = Color(0xFF070A14); // near-black

  // Dark surfaces
  static const Color surface = Color(0xFF0B1220);
  static const Color surface2 = Color(0xFF0F1B33);
  static const Color onSurface = Color(0xFFEAF0FF);
  static const Color onSurfaceMuted = Color(0xFFB8C4E6);

  /// Returns a lighter "tint" of a color by mixing it with white.
  static Color tint(Color c, [double amount = 0.75]) {
    final a = amount.clamp(0.0, 1.0);
    return Color.lerp(c, Colors.white, a)!;
  }

  /// Returns a darker "shade" of a color by mixing it with black.
  static Color shade(Color c, [double amount = 0.15]) {
    final a = amount.clamp(0.0, 1.0);
    return Color.lerp(c, Colors.black, a)!;
  }
}

