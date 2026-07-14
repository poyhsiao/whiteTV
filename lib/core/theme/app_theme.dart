import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

/// whiteTV 主題設定

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.secondary,
          surface: AppColors.cardBackground,
          error: AppColors.error,
        ),
        textTheme: TextTheme(
          headlineLarge: AppTypography.headline,
          headlineMedium: AppTypography.title,
          titleMedium: AppTypography.subtitle,
          bodyMedium: AppTypography.body,
          bodySmall: AppTypography.caption,
          labelLarge: AppTypography.button,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: AppColors.cardBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.glassBorder),
          ),
        ),
      );

  // ponytail: light theme per UI_UX.md §13.1 — inverted warm palette
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Color(0xFFF5F0E8), // warm off-white
        colorScheme: ColorScheme.light(
          primary: AppColors.accent,
          secondary: AppColors.secondary,
          surface: const Color(0xFFFFFFFF),
          error: AppColors.error,
        ),
        textTheme: TextTheme(
          headlineLarge: AppTypography.headline.copyWith(color: const Color(0xFF1A1A1A)),
          headlineMedium: AppTypography.title.copyWith(color: const Color(0xFF1A1A1A)),
          titleMedium: AppTypography.subtitle.copyWith(color: const Color(0xFF1A1A1A)),
          bodyMedium: AppTypography.body.copyWith(color: const Color(0xFF1A1A1A)),
          bodySmall: AppTypography.caption.copyWith(color: const Color(0xFF666666)),
          labelLarge: AppTypography.button,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F0E8),
          foregroundColor: Color(0xFF1A1A1A),
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      );
}