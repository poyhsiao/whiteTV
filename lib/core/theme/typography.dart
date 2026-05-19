import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// whiteTV 字體系統
/// 參照: docs/spec/UI_UX.md

class AppTypography {
  AppTypography._();

  static TextStyle get _base => GoogleFonts.notoSansTc(
        color: AppColors.textPrimary,
      );

  // 大標題：用於頁面標題
  static TextStyle get headline => _base.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      );

  // 中標題：用於區塊標題
  static TextStyle get title => _base.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      );

  // 小標題：用於卡片標題
  static TextStyle get subtitle => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  // 內文
  static TextStyle get body => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      );

  // 說明文字
  static TextStyle get caption => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      );

  // 按鈕文字
  static TextStyle get button => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );
}