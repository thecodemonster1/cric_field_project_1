import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const MaterialColor primarySwatch = Colors.green;
  static final Color primary = Colors.green[700]!;
  static final Color primaryLight = Colors.green[400]!;
  static final Color primaryDark = Colors.green[900]!;

  // Secondary colors
  static final Color secondary = Colors.amber[500]!;
  static final Color secondaryLight = Colors.amber[300]!;
  static final Color secondaryDark = Colors.amber[700]!;

  // Neutral colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static final Color grey100 = Colors.grey[100]!;
  static final Color grey200 = Colors.grey[200]!;
  static final Color grey300 = Colors.grey[300]!;
  static final Color grey600 = Colors.grey[600]!;
  static final Color grey700 = Colors.grey[700]!;

  // Cricket field specific colors
  static const Color fieldGreen = Colors.green;
  static const Color pitchBrown = Colors.brown;
  static const Color fieldingHotspot = Color.fromARGB(255, 206, 0, 0);

  // Status colors
  static const Color error = Colors.red;
  static const Color success = Colors.green;
  static const Color warning = Colors.orange;
  static const Color info = Colors.blue;

  // static const  googleRed = Colors.redAccent;
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      useMaterial3: true,
    );
  }
}
