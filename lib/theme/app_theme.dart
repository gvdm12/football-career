import 'package:flutter/material.dart';

class AppTheme {
  static const background = Color(0xFF06190D);
  static const backgroundLight = Color(0xFF0A2513);

  static const primary = Color(0xFF36B84A);
  static const primaryDark = Color(0xFF1B5427);

  static const border = Color(0xFF164B24);
  static const textPrimary = Color(0xFFE8F0E8);
  static const textSecondary = Color(0xFF6E9B76);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,

      colorScheme: const ColorScheme.dark(
        primary: primary,
        surface: background,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.transparent,
        hintStyle: const TextStyle(color: textSecondary, fontSize: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
