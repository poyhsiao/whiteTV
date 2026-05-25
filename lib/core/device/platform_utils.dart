import 'dart:io';

/// 平台類型列舉
/// 參照: docs/superpowers/specs/2026-05-25-ios-macos-design.md
enum PlatformType {
  /// iOS (iPhone, iPad)
  ios,

  /// Android (Phone, Tablet)
  android,

  /// macOS (Desktop)
  macos,

  /// Windows (Desktop)
  windows,

  /// Linux (Desktop)
  linux,

  /// Web (Browser)
  web,

  /// Apple TV (tvOS)
  tvos,

  /// Google TV (Android TV)
  googleTV,
}

/// PlatformType 擴展方法
extension PlatformTypeExtension on PlatformType {
  /// 是否為 Apple 平台（iOS/macOS/tvOS）
  bool get isApplePlatform =>
      this == PlatformType.ios ||
      this == PlatformType.macos ||
      this == PlatformType.tvos;

  /// 是否為 Mobile 平台（iOS/Android/GoogleTV）
  bool get isMobilePlatform =>
      this == PlatformType.ios ||
      this == PlatformType.android ||
      this == PlatformType.googleTV;

  /// 是否為 Desktop 平台（macOS/Windows/Linux）
  bool get isDesktopPlatform =>
      this == PlatformType.macos ||
      this == PlatformType.windows ||
      this == PlatformType.linux;
}

/// 獲取當前運行平台
/// 在無法檢測時返回 web 作為預設值
PlatformType getCurrentPlatform() {
  if (Platform.isIOS) return PlatformType.ios;
  if (Platform.isAndroid) return PlatformType.android;
  if (Platform.isMacOS) return PlatformType.macos;
  if (Platform.isWindows) return PlatformType.windows;
  if (Platform.isLinux) return PlatformType.linux;
  // Platform.isFuchsia 可能表示 Google TV 或 Android TV
  if (Platform.isFuchsia) return PlatformType.googleTV;
  return PlatformType.web;
}