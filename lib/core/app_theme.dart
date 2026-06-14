import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.stadiumDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.skyBlue,
        secondary: AppColors.electricBlue,
        surface: AppColors.cardDark,
        onPrimary: AppColors.pureWhite,
        onSecondary: AppColors.pureWhite,
        onSurface: AppColors.pureWhite,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 48,
          fontWeight: FontWeight.w900,
          color: AppColors.pureWhite,
          letterSpacing: -2,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: AppColors.pureWhite,
          letterSpacing: -1.5,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.pureWhite,
          letterSpacing: -1,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.pureWhite,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.pureWhite,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.pureWhite,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: AppColors.softWhite,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.silver,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.skyBlue,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
