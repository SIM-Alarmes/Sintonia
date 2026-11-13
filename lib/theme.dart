import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const ink = Color(0xFF0D0B14);
  static const panel = Color(0xFF17141F);
  static const panel2 = Color(0xFF211D2C);
  static const line = Color(0xFF2E2940);
  static const fg = Color(0xFFF3F0FA);
  static const muted = Color(0xFFA39CB8);
  static const hot = Color(0xFFFF4F8B);
  static const cool = Color(0xFF6B5BFF);
  static const ok = Color(0xFF3DDC97);
  static const warm = Color(0xFFFFB36B);
}

ThemeData buildTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  final body = GoogleFonts.interTextTheme(base.textTheme)
      .apply(bodyColor: AppColors.fg, displayColor: AppColors.fg);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.panel,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.hot,
      secondary: AppColors.cool,
      surface: AppColors.panel,
      onSurface: AppColors.fg,
    ),
    textTheme: body.copyWith(
      headlineSmall: GoogleFonts.sora(
          fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.fg),
      titleLarge: GoogleFonts.sora(
          fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.fg),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.panel,
      indicatorColor: AppColors.hot.withOpacity(.18),
      iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
          color: s.contains(WidgetState.selected)
              ? AppColors.hot
              : AppColors.muted)),
      labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
          fontSize: 12,
          color: s.contains(WidgetState.selected)
              ? AppColors.hot
              : AppColors.muted)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.hot,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.fg,
        backgroundColor: AppColors.panel2,
        side: const BorderSide(color: AppColors.line),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.panel2,
        contentTextStyle: TextStyle(color: AppColors.fg)),
  );
}
