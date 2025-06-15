import 'package:flutter/material.dart';

class AppTheme {
  // Main colors
  static const Color primaryColor = Color(0xFF3D5AFE);
  static const Color secondaryColor = Color(0xFF7DE2FF);
  static const Color backgroundColor = Colors.white;
  static const Color darkBackgroundColor = Color(0xFF121212);

  // Text colors
  static const Color textPrimaryColor = Color(0xFF121212);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color textWhiteColor = Colors.white;

  // Status colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFE53935);
  static const Color warningColor = Color(0xFFFFB300);
  static const Color infoColor = Color(0xFF2196F3);

  // Card and surface colors
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;

  // Gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFF7DE2FF),
    Color(0xFF5D7EFF),
  ];

  // Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      background: backgroundColor,
      surface: Colors.white,
      error: Colors.red,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: textPrimaryColor,
      elevation: 0,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: textWhiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: primaryColor),
      ),
    ),
  );

  // Dark theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      background: darkBackgroundColor,
      surface: darkBackgroundColor,
      error: errorColor,
    ),
    scaffoldBackgroundColor: darkBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackgroundColor,
      foregroundColor: textWhiteColor,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textWhiteColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: textWhiteColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade800,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: primaryColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: textWhiteColor,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: textWhiteColor,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: textWhiteColor,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        color: textWhiteColor,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: textWhiteColor,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: textWhiteColor,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(color: textWhiteColor, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(
        color: textWhiteColor,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(color: textWhiteColor, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: textWhiteColor),
      bodyMedium: TextStyle(color: textWhiteColor),
      bodySmall: TextStyle(color: Colors.grey),
      labelLarge: TextStyle(color: textWhiteColor, fontWeight: FontWeight.w600),
      labelMedium: TextStyle(color: textWhiteColor),
      labelSmall: TextStyle(color: Colors.grey),
    ),
  );
}
