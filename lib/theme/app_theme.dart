import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Theme Colors
  static const primaryColor = Color(0xFF1E3A8A); // Deep navy blue
  static const secondaryColor = Color(0xFFF59E0B); // Warm amber
  static const accentColor = Color(0xFF4F46E5); // Indigo accent
  static const errorColor = Color(0xFFE11D48); // Rose red
  static const backgroundColor = Color(0xFFFAFAFA); // Off-white
  static const surfaceColor = Color(0xFFFFFFFF); // Pure white
  static const textColor = Color(0xFF1F2937); // Dark gray text

  // Dark Theme Colors
  static const primaryColorDark = Color(0xFF2563EB); // Brighter navy
  static const secondaryColorDark = Color(0xFFFBBF24); // Brighter amber
  static const darkBackground = Color(0xFF0F172A); // Deep navy background
  static const darkSurface = Color(0xFF1E293B); // Navy surface
  static const darkText = Color(0xFFF8FAFC); // Light text

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      error: errorColor,
      surface: surfaceColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textColor,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: primaryColorDark,
      secondary: secondaryColorDark,
      tertiary: accentColor,
      error: errorColor,
      surface: darkSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkText,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}
