import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
// RELIQ DESIGN SYSTEM — B/W
// Font: Plus Jakarta Sans (via Google Fonts)
// No color accents. Contrast IS the accent.
// ─────────────────────────────────────────────

class ReliqTheme {
  ReliqTheme._();

  // ── Light palette ──────────────────────────
  static const Color _lightBg = Color(0xFFFAFAFA);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightSurface2 = Color(0xFFF4F4F4);
  static const Color _lightBorder = Color(0xFFE8E8E8);
  static const Color _lightText1 = Color(0xFF0D0D0D);
  static const Color _lightText2 = Color(0xFF6B6B6B);
  static const Color _lightText3 = Color(0xFFABABAB);
  static const Color _lightInk = Color(0xFF0D0D0D);
  static const Color _lightInkPress = Color(0xFF2E2E2E);

  // ── Dark palette ───────────────────────────
  static const Color _darkBg = Color(0xFF0A0A0A);
  static const Color _darkSurface = Color(0xFF141414);
  static const Color _darkSurface2 = Color(0xFF1E1E1E);
  static const Color _darkBorder = Color(0xFF2A2A2A);
  static const Color _darkText1 = Color(0xFFF5F5F5);
  static const Color _darkText2 = Color(0xFF8A8A8A);
  static const Color _darkText3 = Color(0xFF555555);
  static const Color _darkInk = Color(0xFFF5F5F5);
  static const Color _darkInkPress = Color(0xFFCCCCCC);

  // ── Shared ─────────────────────────────────
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF2E7D32);

  // ── Typography helper ──────────────────────
  static TextTheme _textTheme(Color t1, Color t2, Color t3) {
    return TextTheme(
      // Headings
      displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: t1,
          letterSpacing: -0.5),
      displayMedium: GoogleFonts.plusJakartaSans(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: t1,
          letterSpacing: -0.3),
      displaySmall: GoogleFonts.plusJakartaSans(
          fontSize: 22, fontWeight: FontWeight.w600, color: t1),
      headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 18, fontWeight: FontWeight.w600, color: t1),
      headlineSmall: GoogleFonts.plusJakartaSans(
          fontSize: 16, fontWeight: FontWeight.w600, color: t1),
      titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 15, fontWeight: FontWeight.w600, color: t1),
      titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14, fontWeight: FontWeight.w500, color: t1),
      titleSmall: GoogleFonts.plusJakartaSans(
          fontSize: 13, fontWeight: FontWeight.w500, color: t2),
      // Body
      bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 15, fontWeight: FontWeight.w400, color: t1, height: 1.6),
      bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14, fontWeight: FontWeight.w400, color: t1, height: 1.5),
      bodySmall: GoogleFonts.plusJakartaSans(
          fontSize: 12, fontWeight: FontWeight.w400, color: t2, height: 1.4),
      // Labels
      labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14, fontWeight: FontWeight.w600, color: t1),
      labelMedium: GoogleFonts.plusJakartaSans(
          fontSize: 12, fontWeight: FontWeight.w500, color: t2),
      labelSmall: GoogleFonts.plusJakartaSans(
          fontSize: 11, fontWeight: FontWeight.w400, color: t3),
    );
  }

  // ── Light theme ────────────────────────────
  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: _lightBg,
    primaryColor: _lightInk,
    colorScheme: const ColorScheme.light(
      primary: _lightInk,
      secondary: _lightInkPress,
      surface: _lightSurface,
      error: error,
      onPrimary: _lightSurface,
      onSurface: _lightText1,
    ),
    textTheme: _textTheme(_lightText1, _lightText2, _lightText3),
    appBarTheme: AppBarTheme(
      backgroundColor: _lightSurface,
      foregroundColor: _lightText1,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: _lightBorder,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: _lightText1,
      ),
      iconTheme: const IconThemeData(color: _lightText1, size: 22),
    ),
    cardTheme: CardThemeData(
      color: _lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _lightBorder),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: _lightBorder,
      thickness: 1,
      space: 1,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightInk,
        foregroundColor: _lightSurface,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _lightInk,
        side: const BorderSide(color: _lightBorder, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _lightInk,
        textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightSurface2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _lightInk, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: error),
      ),
      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: _lightText3),
      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: _lightText2),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _lightSurface,
      selectedItemColor: _lightInk,
      unselectedItemColor: _lightText3,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle:
          TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _lightSurface2,
      selectedColor: _lightInk,
      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: _lightText1),
      secondaryLabelStyle:
          GoogleFonts.plusJakartaSans(fontSize: 13, color: _lightSurface),
      side: const BorderSide(color: _lightBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),
    iconTheme: const IconThemeData(color: _lightText1, size: 22),
    splashColor: Colors.black.withOpacity(0.04),
    highlightColor: Colors.black.withOpacity(0.02),
  );

  // ── Dark theme ─────────────────────────────
  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _darkBg,
    primaryColor: _darkInk,
    colorScheme: const ColorScheme.dark(
      primary: _darkInk,
      secondary: _darkInkPress,
      surface: _darkSurface,
      error: error,
      onPrimary: _darkBg,
      onSurface: _darkText1,
    ),
    textTheme: _textTheme(_darkText1, _darkText2, _darkText3),
    appBarTheme: AppBarTheme(
      backgroundColor: _darkSurface,
      foregroundColor: _darkText1,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: _darkBorder,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: _darkText1,
      ),
      iconTheme: const IconThemeData(color: _darkText1, size: 22),
    ),
    cardTheme: CardThemeData(
      color: _darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _darkBorder),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: _darkBorder,
      thickness: 1,
      space: 1,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkInk,
        foregroundColor: _darkBg,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _darkInk,
        side: const BorderSide(color: _darkBorder, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _darkInk,
        textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurface2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _darkInk, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: error),
      ),
      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: _darkText3),
      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: _darkText2),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _darkSurface,
      selectedItemColor: _darkInk,
      unselectedItemColor: _darkText3,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle:
          TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _darkSurface2,
      selectedColor: _darkInk,
      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: _darkText1),
      secondaryLabelStyle:
          GoogleFonts.plusJakartaSans(fontSize: 13, color: _darkBg),
      side: const BorderSide(color: _darkBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),
    iconTheme: const IconThemeData(color: _darkText1, size: 22),
    splashColor: Colors.white.withOpacity(0.04),
    highlightColor: Colors.white.withOpacity(0.02),
  );

  // ── Convenience getters ────────────────────
  // Use these in screens instead of hardcoding colors
  static Color bg(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  static Color surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;
  static Color surface2(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _darkSurface2
          : _lightSurface2;
  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _darkBorder
          : _lightBorder;
  static Color text1(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _darkText1
          : _lightText1;
  static Color text2(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _darkText2
          : _lightText2;
  static Color text3(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _darkText3
          : _lightText3;
  static Color ink(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _darkInk : _lightInk;
  static Color inkInverse(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _darkBg : _lightSurface;
}
