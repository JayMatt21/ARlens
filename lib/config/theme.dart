import 'package:flutter/material.dart';

class AppTheme {
  // Palette
  static const Color primaryBlue = Color(0xFF4FC3F7);
  static const Color primaryDarkBlue = Color(0xFF29B6F6);
  static const Color accentBlue = Color(0xFF0288D1);
  static const Color backgroundGrey = Color(0xFFF2F6FA);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textLight = Color(0xFF6B7280);

  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: backgroundGrey,
      primaryColor: primaryBlue,
      colorScheme: base.colorScheme.copyWith(
        primary: primaryBlue,
        secondary: accentBlue,
        surface: backgroundGrey,
        onPrimary: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
      ),

      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(8),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primaryDarkBlue),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primaryBlue)),
        labelStyle: const TextStyle(color: textDark),
      ),

      dividerColor: Colors.grey.shade200,

      textTheme: base.textTheme.apply(bodyColor: textDark, displayColor: textDark).copyWith(
        headlineSmall: const TextStyle(fontWeight: FontWeight.w700, color: textDark),
        titleMedium: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}