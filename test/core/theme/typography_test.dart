import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/theme/typography.dart';

void main() {
  group('AppTypography', () {
    testWidgets('headline is bold and 32pt', (tester) async {
      expect(AppTypography.headline.fontSize, 32);
      expect(AppTypography.headline.fontWeight, FontWeight.bold);
    });

    testWidgets('title is w600 and 24pt', (tester) async {
      expect(AppTypography.title.fontSize, 24);
      expect(AppTypography.title.fontWeight, FontWeight.w600);
    });

    testWidgets('subtitle is w500 and 16pt', (tester) async {
      expect(AppTypography.subtitle.fontSize, 16);
      expect(AppTypography.subtitle.fontWeight, FontWeight.w500);
    });

    testWidgets('body is normal weight and 14pt', (tester) async {
      expect(AppTypography.body.fontSize, 14);
      expect(AppTypography.body.fontWeight, FontWeight.normal);
    });

    testWidgets('button is w600 with letter-spacing', (tester) async {
      expect(AppTypography.button.fontSize, 14);
      expect(AppTypography.button.fontWeight, FontWeight.w600);
      expect(AppTypography.button.letterSpacing, 0.5);
    });

    testWidgets('all styles return non-null TextStyle', (tester) async {
      expect(AppTypography.headline, isNotNull);
      expect(AppTypography.title, isNotNull);
      expect(AppTypography.subtitle, isNotNull);
      expect(AppTypography.body, isNotNull);
      expect(AppTypography.caption, isNotNull);
      expect(AppTypography.button, isNotNull);
    });
  });
}
