import 'package:flutter/material.dart';

class AppTheme {
  static final dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0B1020),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF58A6FF),
      secondary: Color(0xFF7EE787),
      surface: Color(0xFF111827),
    ),
    cardTheme: CardTheme(
      color: Colors.white.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
    ),
  );
}
