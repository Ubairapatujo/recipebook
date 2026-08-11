import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Warm editorial pantry palette.
  static const Color primaryColor = Color(0xFFE2674A);
  static const Color primaryLight = Color(0xFFF19A72);
  static const Color primaryDark = Color(0xFFB94E39);
  static const Color accentColor = Color(0xFFAEBB7D);
  static const Color ink = Color(0xFF4B3025);
  static const Color mutedInk = Color(0xFF7E6555);
  static const Color paper = Color(0xFFF7F0E0);
  static const Color paperLight = Color(0xFFFFF8E9);
  static const Color paperDark = Color(0xFF211914);
  static const Color cardDark = Color(0xFF30231D);
  static const Color border = Color(0xFFDECBAA);

  static TextTheme _textTheme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final foreground = dark ? const Color(0xFFFFF8E9) : ink;
    final secondary = dark ? const Color(0xFFD4BFA8) : mutedInk;

    return GoogleFonts.dmSansTextTheme(
      TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 64,
          height: 0.98,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 48,
          height: 1.05,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 32,
          height: 1.1,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 17,
          height: 1.55,
          color: secondary,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 14,
          height: 1.45,
          color: secondary,
        ),
        bodySmall: GoogleFonts.dmSans(
          fontSize: 12,
          height: 1.35,
          color: secondary,
        ),
        labelLarge: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
        labelSmall: GoogleFonts.dmMono(
          fontSize: 10,
          letterSpacing: 1.8,
          color: secondary,
        ),
      ),
    );
  }

  static ThemeData _buildTheme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final background = dark ? paperDark : paper;
    final surface = dark ? cardDark : paperLight;
    final foreground = dark ? const Color(0xFFFFF8E9) : ink;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
        primary: primaryColor,
        secondary: accentColor,
        surface: surface,
        onSurface: foreground,
      ),
      textTheme: _textTheme(brightness),
      fontFamily: GoogleFonts.dmSans().fontFamily,
      dividerColor: dark ? const Color(0xFF604A3A) : border,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: foreground,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: dark ? const Color(0xFF604A3A) : border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          side: BorderSide(color: dark ? const Color(0xFF806451) : border),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        hintStyle: GoogleFonts.dmSans(
          fontSize: 14,
          color: dark ? const Color(0xFFB89E89) : const Color(0xFFAE947E),
        ),
        labelStyle: GoogleFonts.dmSans(fontSize: 14, color: mutedInk),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide:
              BorderSide(color: dark ? const Color(0xFF604A3A) : border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide:
              BorderSide(color: dark ? const Color(0xFF604A3A) : border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: ink,
        labelStyle: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
        secondaryLabelStyle: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        side: BorderSide(color: dark ? const Color(0xFF604A3A) : border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primaryColor.withOpacity(0.14),
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);
}
