import 'package:flutter/material.dart';

class AppTheme {
  static const Color accentColor = Color(0xFF009688); // Teal
  static const Color backgroundColorLight = Color(0xFFF5F7F8);
  static const Color backgroundColorDark = Color(0xFF121212);
  static const Color cardColorLight = Colors.white;
  static const Color cardColorDark = Color(0xFF1E1E1E);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: accentColor,
      scaffoldBackgroundColor: backgroundColorLight,
      cardColor: cardColorLight,
      colorScheme: ColorScheme.light(
        primary: accentColor,
        secondary: accentColor,
        surface: cardColorLight,
        background: backgroundColorLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColorLight,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardColorLight,
        selectedItemColor: accentColor,
        unselectedItemColor: Colors.grey,
        elevation: 8,
      ),
      cardTheme: CardTheme(
        color: cardColorLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: accentColor,
      scaffoldBackgroundColor: backgroundColorDark,
      cardColor: cardColorDark,
      colorScheme: ColorScheme.dark(
        primary: accentColor,
        secondary: accentColor,
        surface: cardColorDark,
        background: backgroundColorDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColorDark,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardColorDark,
        selectedItemColor: accentColor,
        unselectedItemColor: Colors.grey,
        elevation: 8,
      ),
      cardTheme: CardTheme(
        color: cardColorDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
      ),
    );
  }
}
