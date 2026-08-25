import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1B5BFF);
  static const Color primaryDark = Color(0xFF07195C);
  static const Color accent = Color(0xFF22D07A);
  static const Color background = Color(0xFF07101F);
  static const Color card = Color(0xFF0F1620);
}

final ThemeData appTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  cardColor: AppColors.card,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
  ),
  textTheme: GoogleFonts.interTextTheme(
    const TextTheme(bodyLarge: TextStyle(color: Colors.white)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
);
