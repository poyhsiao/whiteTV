import 'package:flutter/material.dart';

import 'device_type.dart';

/// 設備檢測工具
/// 參照: docs/spec/ARCHITECTURE.md Section 4.3
/// 參照: docs/superpowers/specs/2026-05-25-ios-macos-design.md

class DeviceUtils {
  DeviceUtils._();

  /// 根據螢幕寬度判斷設備類型
  /// TV: >= 1024px
  /// Desktop: >= 1024px (with mouse/keyboard, window-based)
  /// Tablet: 768px - 1023px
  /// Mobile: < 768px
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Desktop: >= 1024px with keyboard/mouse (macOS/Windows/Linux)
    // Check if platform detection shows desktop
    if (width >= 1024) {
      // TODO: 整合平台檢測以區分 TV vs Desktop
      // 暫時用 width >= 1200 作為 Desktop 判斷（更嚴格的桌面體驗）
      if (width >= 1200) {
        return DeviceType.desktop;
      }
      return DeviceType.tv;
    }
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

  /// 是否為 Desktop 設備
  static bool isDesktop(BuildContext context) =>
      getDeviceType(context) == DeviceType.desktop;

  /// TV 設備的 D-pad 導航間距
  static double getFocusPadding(BuildContext context) {
    if (isTV(context)) return 8.0;
    return 0.0;
  }

  /// 檢查是否需要滑鼠支援（Desktop 或 Tablet with mouse）
  static bool needsMouseSupport(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.desktop || deviceType == DeviceType.tablet;
  }
}