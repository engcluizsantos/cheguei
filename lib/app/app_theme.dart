import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ============================
  // Cores da aplicação
  // ============================

  static const Color primary = Color(0xFF7C3AED);

  static const Color primaryDark = Color(0xFF5B21B6);

  static const Color primaryLight = Color(0xFF8B5CF6);

  static const Color background = Color(0xFFF8F7FC);

  static const Color surface = Colors.white;

  static const Color success = Color(0xFF22C55E);

  static const Color error = Color(0xFFEF4444);

  static const Color textPrimary = Color(0xFF1F2937);

  static const Color textSecondary = Color(0xFF6B7280);

  // Espaçamentos

  static const double padding = 16;

  static const double borderRadius = 14;

  static const double cardRadius = 16;

  // ============================
  // Tema Claro
  // ============================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      brightness: Brightness.light,

      scaffoldBackgroundColor: background,

      primaryColor: primary,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: primaryLight,
        surface: surface,
        error: error,
        brightness: Brightness.light,
      ),

      textTheme: GoogleFonts.poppinsTextTheme(),

      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 2),
        ),

        hintStyle: GoogleFonts.poppins(color: textSecondary),
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
