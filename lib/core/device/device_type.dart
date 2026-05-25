/// 設備類型列舉
/// 參照: docs/superpowers/specs/2026-05-25-ios-macos-design.md
enum DeviceType {
  /// Android TV / Google TV
  tv,

  /// iPhone / Android Phone
  mobile,

  /// iPad / Android Tablet
  tablet,

  /// macOS / Windows / Linux
  desktop,
}

/// DeviceType 擴展方法
extension DeviceTypeExtension on DeviceType {
  /// 是否為 TV 設備
  bool get isTV => this == DeviceType.tv;

  /// 是否為 Mobile 設備
  bool get isMobile => this == DeviceType.mobile;

  /// 是否為 Tablet 設備
  bool get isTablet => this == DeviceType.tablet;

  /// 是否為 Desktop 設備
  bool get isDesktop => this == DeviceType.desktop;
}