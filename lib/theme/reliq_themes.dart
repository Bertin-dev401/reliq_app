import 'package:flutter/material.dart';

class ReliqThemes {
  static ThemeData white = ThemeData(
    useMaterial3: true,
    primaryColor: const Color(0xFF6C63FF),
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF6C63FF),
      secondary: Color(0xFF4CAF50),
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF2D3748),
      elevation: 0,
    ),
  );

  static ThemeData gold = ThemeData(
    useMaterial3: true,
    primaryColor: const Color(0xFFC9A84C),
    scaffoldBackgroundColor: const Color(0xFF0D0A04),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFC9A84C),
      secondary: Color(0xFFE8C96A),
      surface: Color(0xFF1A1208),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1208),
      foregroundColor: Color(0xFFC9A84C),
      elevation: 0,
    ),
  );

  static ThemeData sageGreen = ThemeData(
    useMaterial3: true,
    primaryColor: const Color(0xFF7BAE8A),
    scaffoldBackgroundColor: const Color(0xFF0A0F0B),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF7BAE8A),
      secondary: Color(0xFFA2C9AD),
      surface: Color(0xFF111A13),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF111A13),
      foregroundColor: Color(0xFF7BAE8A),
      elevation: 0,
    ),
  );

  static ThemeData warmOffWhite = ThemeData(
    useMaterial3: true,
    primaryColor: const Color(0xFFB07D40),
    scaffoldBackgroundColor: const Color(0xFFF0E8D5),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFB07D40),
      secondary: Color(0xFFD4A05C),
      surface: Color(0xFFE8DEC8),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFE8DEC8),
      foregroundColor: Color(0xFF2C1F0A),
      elevation: 0,
    ),
  );

  static ThemeData deepNavy = ThemeData(
    useMaterial3: true,
    primaryColor: const Color(0xFF6B9FD4),
    scaffoldBackgroundColor: const Color(0xFF050C18),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF6B9FD4),
      secondary: Color(0xFF8FC3F0),
      surface: Color(0xFF0A1628),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0A1628),
      foregroundColor: Color(0xFF6B9FD4),
      elevation: 0,
    ),
  );

  static ThemeData softCream = ThemeData(
    useMaterial3: true,
    primaryColor: const Color(0xFFC47E4A),
    scaffoldBackgroundColor: const Color(0xFFFAF4EB),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFC47E4A),
      secondary: Color(0xFFE0A070),
      surface: Color(0xFFF0E5D0),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF0E5D0),
      foregroundColor: Color(0xFF3A2710),
      elevation: 0,
    ),
  );

  static ThemeData gentleGreen = ThemeData(
    useMaterial3: true,
    primaryColor: const Color(0xFF5BA87A),
    scaffoldBackgroundColor: const Color(0xFF06100A),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF5BA87A),
      secondary: Color(0xFF80C99C),
      surface: Color(0xFF0B1A10),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0B1A10),
      foregroundColor: Color(0xFF5BA87A),
      elevation: 0,
    ),
  );

  static ThemeData skyBlue = ThemeData(
    useMaterial3: true,
    primaryColor: const Color(0xFF4AACE0),
    scaffoldBackgroundColor: const Color(0xFF040C18),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF4AACE0),
      secondary: Color(0xFF78C8F0),
      surface: Color(0xFF081428),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF081428),
      foregroundColor: Color(0xFF4AACE0),
      elevation: 0,
    ),
  );

  static const Map<String, String> themeNames = {
    'gold':      'Gold (Default)',
    'sage':      'Soft Sage Green',
    'offwhite':  'Warm Off-White',
    'navy':      'Deep Navy',
    'softcream': 'Soft Cream',
    'green':     'Gentle Green',
    'sky':       'Sky Blue',
  };

  static const Map<String, Color> themePrimaryColors = {
    'gold':      Color(0xFFC9A84C),
    'sage':      Color(0xFF7BAE8A),
    'offwhite':  Color(0xFFB07D40),
    'navy':      Color(0xFF6B9FD4),
    'softcream': Color(0xFFC47E4A),
    'green':     Color(0xFF5BA87A),
    'sky':       Color(0xFF4AACE0),
  };

  static ThemeData getTheme(String key) {
    switch (key) {
      case 'sage':      return sageGreen;
      case 'offwhite':  return warmOffWhite;
      case 'navy':      return deepNavy;
      case 'softcream': return softCream;
      case 'green':     return gentleGreen;
      case 'sky':       return skyBlue;
      case 'gold':      return gold;
      default:          return white;
    }
  }
}
