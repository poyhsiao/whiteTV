import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/theme/colors.dart';

void main() {
  test('background color is dark for OLED', () {
    expect(AppColors.background.computeLuminance(), lessThan(0.1));
  });

  test('accent color is warm amber', () {
    final r = (AppColors.accent.r * 255.0).round().clamp(0, 255);
    final g = (AppColors.accent.g * 255.0).round().clamp(0, 255);
    expect(r, greaterThan(200));
    expect(g, greaterThan(150));
    expect(g, lessThan(180));
  });

  test('text primary is bright', () {
    expect(AppColors.textPrimary.computeLuminance(), greaterThan(0.9));
  });
}