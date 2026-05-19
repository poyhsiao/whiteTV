import 'package:flutter/material.dart';

/// whiteTV 色彩系統 - Warm Entertainment + Glass/Frosted
/// 參照: docs/spec/UI_UX.md Section 1.2

class AppColors {
  AppColors._();

  // 主背景：深暖灰，保護 OLED
  // oklch(15% 0.02 30) ≈ #1A1A1A
  static const Color background = Color(0xFF1A1A1A);

  // 卡片底色：毛玻璃效果
  // oklch(95% 0.01 60 / 0.7)
  static const Color cardBackground = Color(0xB3F5F5F5);

  // 強調色：琥珀/金色
  // oklch(75% 0.15 70) ≈ #E6A23C
  static const Color accent = Color(0xFFE6A23C);

  // 次要強調：珊瑚橘
  // oklch(65% 0.12 45) ≈ #FF7B54
  static const Color secondary = Color(0xFFFF7B54);

  // 文字主色：暖白
  // oklch(98% 0.01 60) ≈ #FAFAFA
  static const Color textPrimary = Color(0xFFFAFAFA);

  // 文字次色：啞暖灰
  // oklch(70% 0.02 30) ≈ #B3B3B3
  static const Color textSecondary = Color(0xFFB3B3B3);

  // 直播/警報/CTA
  static const Color live = Color(0xFFFF7B54);

  // 成功
  static const Color success = Color(0xFF67C23A);

  // 錯誤
  static const Color error = Color(0xFFE74C3C);

  // 毛玻璃邊框
  static const Color glassBorder = Color(0x33FFFFFF);

  // 來源狀態
  static const Color sourceAvailable = Color(0xFF67C23A);
  static const Color sourceUnavailable = Color(0xFFE74C3C);
  static const Color sourceTesting = Color(0xFFE6A23C);
}