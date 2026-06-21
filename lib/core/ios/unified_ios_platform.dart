// lib/core/ios/unified_ios_platform.dart
import 'dart:io' show Platform;
import 'package:white_tv/core/ios/ios_platform_channel.dart';
import 'package:white_tv/core/handoff/handoff_service.dart';

/// 統一 iOS 平台服務
/// 封裝 Handoff、PiP 等 iOS 特定功能
class UnifiedIosPlatform {
  UnifiedIosPlatform._();

  /// 預設使用 IosPlatformChannel singleton
  static IosPlatformChannelInterface _channel = IosPlatformChannel.instance;

  /// 替換 platform channel 實現（用於測試）
  static void setPlatformChannel(IosPlatformChannelInterface channel) {
    _channel = channel;
  }

  /// 恢復預設 IosPlatformChannel
  static void resetPlatformChannel() {
    _channel = IosPlatformChannel.instance;
  }

  /// 是否為 iOS 平台
  static bool get isIos => Platform.isIOS;

  /// 是否為 macOS 平台
  static bool get isMacos => Platform.isMacOS;

  /// 是否支援原生功能
  static bool get isNativeSupported => isIos || isMacos;

  // ==================== Handoff ====================

  /// 開始播放內容的 Handoff
  static Future<bool> startPlaybackHandoff({
    required String contentId,
    required String title,
    Duration position = Duration.zero,
    String? episodeId,
  }) {
    return _channel.startHandoff(
      'com.white_tv.playback',
      {
        'contentId': contentId,
        'title': title,
        'position': position.inMilliseconds,
        if (episodeId != null) 'episodeId': episodeId,
      },
    );
  }

  /// 更新當前播放 Handoff 狀態
  static Future<void> updatePlaybackHandoff({
    required String contentId,
    Duration position = Duration.zero,
  }) {
    return _channel.updateHandoff({
      'contentId': contentId,
      'position': position.inMilliseconds,
    });
  }

  /// 結束播放 Handoff
  static Future<void> endPlaybackHandoff() {
    return _channel.endHandoff();
  }

  /// 獲取待處理的播放內容
  static Future<PlaybackHandoffInfo?> getPendingPlayback() async {
    final userInfo = await _channel.receiveHandoff();
    if (userInfo == null) return null;

    try {
      return PlaybackHandoffInfo(
        contentId: userInfo['contentId'] as String,
        title: userInfo['title'] as String,
        position: Duration(
          milliseconds: userInfo['position'] as int? ?? 0,
        ),
        episodeId: userInfo['episodeId'] as String?,
      );
    } on TypeError {
      // 資料格式不符預期，回傳 null
      return null;
    } on ArgumentError {
      // 參數錯誤，回傳 null
      return null;
    }
  }

  // ==================== PiP ====================

  /// 啟動畫中畫模式
  static Future<bool> startPiP(String route) {
    return _channel.startPiP(route);
  }

  /// 停止畫中畫模式
  static Future<void> stopPiP() {
    return _channel.stopPiP();
  }

  /// 檢查是否支援 PiP
  static Future<bool> isPiPSupported() {
    return _channel.isPiPSupported();
  }
}
