import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Color palette ──────────────────────────────────────────────
  static const Color bg        = Color(0xFF090C14);
  static const Color surface   = Color(0xFF0F1422);
  static const Color card      = Color(0xFF151B2E);
  static const Color border    = Color(0xFF1E2840);
  static const Color gold      = Color(0xFFE8B84B);
  static const Color goldDark  = Color(0xFFD4A032);
  static const Color purple    = Color(0xFFC084FC);
  static const Color muted     = Color(0xFF8892AA);
  static const Color textPrimary   = Color(0xFFF1F5FF);
  static const Color textSecondary = Color(0xFF8892AA);
  static const Color error     = Color(0xFFEF4444);
  static const Color success   = Color(0xFF22C55E);

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      primaryColor: gold,

      colorScheme: const ColorScheme.dark(
        background: bg,
        surface: surface,
        primary: gold,
        secondary: purple,
        error: error,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onBackground: textPrimary,
        onSurface: textPrimary,
      ),

      // Typography
      textTheme: GoogleFonts.dmSansTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: textPrimary),
          displayMedium: TextStyle(color: textPrimary),
          displaySmall: TextStyle(color: textPrimary),
          headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          headlineSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
          titleSmall: TextStyle(color: textPrimary),
          bodyLarge: TextStyle(color: textPrimary),
          bodyMedium: TextStyle(color: textSecondary),
          bodySmall: TextStyle(color: muted),
          labelLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          labelMedium: TextStyle(color: textSecondary),
          labelSmall: TextStyle(color: muted),
        ),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        hintStyle: GoogleFonts.dmSans(color: muted, fontSize: 15),
        labelStyle: GoogleFonts.dmSans(color: muted, fontSize: 15),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        errorStyle: GoogleFonts.dmSans(color: error, fontSize: 12),
      ),

      // Elevated buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
        ),
      ),

      // Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: muted,
          textStyle: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Snack bar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: GoogleFonts.dmSans(color: Colors.white, fontSize: 14),
      ),

      // Bottom sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // Tab bar
      tabBarTheme: TabBarThemeData(
        labelColor: Colors.black,
        unselectedLabelColor: muted,
        labelStyle: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
      ),

      // Divider
      dividerColor: border,

      // Card
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border),
        ),
      ),
    );
  }
}