import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/theme/app_theme.dart';
import 'package:white_tv/core/theme/colors.dart';

void main() {
  testWidgets('AppTheme.darkTheme returns a configured ThemeData', (
    tester,
  ) async {
    final theme = AppTheme.darkTheme;

    expect(theme, isNotNull);
    expect(theme, isA<ThemeData>());
    expect(theme.useMaterial3, isTrue);
    expect(theme.brightness, Brightness.dark);
  });

  testWidgets('configures background and color scheme with app colors', (
    tester,
  ) async {
    final theme = AppTheme.darkTheme;

    expect(theme.scaffoldBackgroundColor, AppColors.background);

    final scheme = theme.colorScheme;
    expect(scheme.primary, AppColors.accent);
    expect(scheme.secondary, AppColors.secondary);
    expect(scheme.surface, AppColors.cardBackground);
    expect(scheme.error, AppColors.error);
  });

  testWidgets('textTheme exposes headline, title, and body styles', (
    tester,
  ) async {
    final theme = AppTheme.darkTheme;
    final textTheme = theme.textTheme;

    expect(textTheme.headlineLarge, isNotNull);
    expect(textTheme.headlineMedium, isNotNull);
    expect(textTheme.titleMedium, isNotNull);
    expect(textTheme.bodyMedium, isNotNull);
  });
}
