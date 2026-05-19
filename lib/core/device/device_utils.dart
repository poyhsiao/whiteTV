import 'package:flutter/material.dart';

/// 設備類型列舉
enum DeviceType { tv, mobile, tablet }

/// 設備檢測工具
/// 參照: docs/spec/ARCHITECTURE.md Section 4.3

class DeviceUtils {
  DeviceUtils._();

  /// 根據螢幕寬度判斷設備類型
  /// TV: >= 1024px
  /// Tablet: 768px - 1023px
  /// Mobile: < 768px
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1024) return DeviceType.tv;
    if (width >= 768) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  /// 是否為 TV 設備
  static bool isTV(BuildContext context) =>
      getDeviceType(context) == DeviceType.tv;

  /// 是否為 Mobile 設備
  static bool isMobile(BuildContext context) =>
      getDeviceType(context) == DeviceType.mobile;

  /// 是否為 Tablet 設備
  static bool isTablet(BuildContext context) =>
      getDeviceType(context) == DeviceType.tablet;

  /// TV 設備的 D-pad導航間距
  static double getFocusPadding(BuildContext context) {
    if (isTV(context)) return 8.0;
    return 0.0;
  }
}