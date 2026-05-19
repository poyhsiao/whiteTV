import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/theme/colors.dart';

void main() {
  test('background color is dark for OLED', () {
    expect(AppColors.background.computeLuminance(), lessThan(0.1));
  });

  test('accent color is warm amber', () {
    expect(AppColors.accent.red, greaterThan(200));
    expect(AppColors.accent.green, greaterThan(150));
    expect(AppColors.accent.green, lessThan(180));
  });

  test('text primary is bright', () {
    expect(AppColors.textPrimary.computeLuminance(), greaterThan(0.9));
  });
}