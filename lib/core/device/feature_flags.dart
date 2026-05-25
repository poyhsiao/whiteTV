import 'device_type.dart';

/// 設備功能開關
/// 根據設備類型控制各功能的啟用/停用
class FeatureFlags {
  FeatureFlags._();

  /// QR Remote Control - TV 和 Mobile 平台啟用
  static bool enableQRRemote(DeviceType type) =>
      type == DeviceType.tv || type == DeviceType.mobile;

  /// Siri Shortcuts - 僅 Mobile (iOS) 啟用
  static bool enableSiriShortcuts(DeviceType type) =>
      type == DeviceType.mobile;

  /// Picture-in-Picture - Mobile, Tablet, Desktop 啟用
  static bool enablePiP(DeviceType type) =>
      type == DeviceType.mobile ||
      type == DeviceType.tablet ||
      type == DeviceType.desktop;

  /// Handoff - 僅 Mobile 啟用
  static bool enableHandoff(DeviceType type) =>
      type == DeviceType.mobile;

  /// Keyboard Navigation - Tablet 和 Desktop 啟用
  static bool enableKeyboardNavigation(DeviceType type) =>
      type == DeviceType.tablet || type == DeviceType.desktop;

  /// Mouse Pointer - Tablet 和 Desktop 啟用
  static bool enableMousePointer(DeviceType type) =>
      type == DeviceType.tablet || type == DeviceType.desktop;

  /// Sidebar Navigation - 僅 Tablet 啟用 (iPad 左側邊欄)
  static bool enableSidebarNavigation(DeviceType type) =>
      type == DeviceType.tablet;

  /// Dock Navigation - 僅 Desktop 啟用 (macOS Dock)
  static bool enableDockNavigation(DeviceType type) =>
      type == DeviceType.desktop;
}