import 'package:white_tv/core/device/device_type.dart';
import 'package:white_tv/core/ios/unified_ios_platform.dart';
import 'package:white_tv/core/ios/ios_platform_channel.dart';

/// Handoff 服務介面
/// 支援 iOS/macOS Universal Clipboard 和 Handoff 功能
///
/// 實現狀態：
/// - [x] iOS 平台通道需使用 MethodChannel 調用原生 API
/// - [ ] macOS 平台通道需使用 platform view 或 MethodChannel
/// - [ ] 需處理 NSUserActivity 和 UISearchSuggestion 的平台特定實作
///
/// 參考：docs/superpowers/specs/2026-05-25-ios-macos-design.md
abstract interface class IHandoffService {
  /// 當前是否支援 Handoff
  /// 根據設備類型和平台綜合判斷
  bool get isSupported;

  /// 開始一個 Handoff 活動
  /// [activityType] - 活動類型，如 "com.example.app.playVideo"
  /// [userInfo] - 攜帶的用戶信息，用於在另一設備還原狀態
  Future<void> startActivity({
    required String activityType,
    required Map<String, dynamic> userInfo,
  });

  /// 更新當前活動的狀態
  /// [userInfo] - 更新的用戶信息
  Future<void> updateActivity({
    required Map<String, dynamic> userInfo,
  });

  /// 結束當前活動
  Future<void> endActivity();

  /// 接收來自另一設備的 Handoff 活動
  /// 返回接收到的 userInfo，如果無待處理活動返回 null
  Future<Map<String, dynamic>?> receiveActivity();
}

/// 播放內容的 Handoff 活動信息
class PlaybackHandoffInfo {
  const PlaybackHandoffInfo({
    required this.contentId,
    required this.title,
    this.position = Duration.zero,
    this.episodeId,
  });

  final String contentId;
  final String title;
  final Duration position;
  final String? episodeId;

  Map<String, dynamic> toUserInfo() => {
        'contentId': contentId,
        'title': title,
        'position': position.inMilliseconds,
        if (episodeId != null) 'episodeId': episodeId,
      };

  static PlaybackHandoffInfo? fromUserInfo(Map<String, dynamic> info) {
    try {
      return PlaybackHandoffInfo(
        contentId: info['contentId'] as String,
        title: info['title'] as String,
        position: Duration(milliseconds: info['position'] as int? ?? 0),
        episodeId: info['episodeId'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaybackHandoffInfo &&
          runtimeType == other.runtimeType &&
          contentId == other.contentId &&
          title == other.title &&
          position == other.position &&
          episodeId == other.episodeId;

  @override
  int get hashCode =>
      contentId.hashCode ^
      title.hashCode ^
      position.hashCode ^
      episodeId.hashCode;
}

/// Handoff 服務實現
///
/// 功能：
/// - 僅在 Mobile 平台啟用（FeatureFlags.enableHandoff）
/// - 通過平台通道與 iOS/macOS 原生 API 交互
/// - 支援影片播放狀態的跨設備繼續
///
/// iOS 实现计划：
/// - 使用 FlutterMethodChannel 调用原生 NSUserActivity
/// - 注册 App Delegate 中的 NSUserActivity 处理
///
/// macOS 实现计划：
/// - 使用 FlutterMethodChannel 调用原生 NSUserActivity
/// - 注册 App Delegate 中的 NSUserActivity 处理
class HandoffService implements IHandoffService {
  /// Creates HandoffService with optional platform channel injection for testing.
  ///
  /// [deviceType] - Required device type for fallback support
  /// [platformChannel] - Optional platform channel (defaults to IosPlatformChannel.instance)
  /// [isIosOverride] - Optional override for iOS detection (for testing on non-iOS)
  /// [isMacosOverride] - Optional override for macOS detection (for testing on non-macOS)
  HandoffService({
    required this.deviceType,
    IosPlatformChannelInterface? platformChannel,
    bool? isIosOverride,
    bool? isMacosOverride,
  })  : _platformChannel = platformChannel ?? IosPlatformChannel.instance,
        _isIosOverride = isIosOverride,
        _isMacosOverride = isMacosOverride;

  /// Platform channel instance (allows test injection)
  final IosPlatformChannelInterface _platformChannel;

  /// iOS override for testing (null means use platform detection)
  final bool? _isIosOverride;

  /// macOS override for testing (null means use platform detection)
  final bool? _isMacosOverride;

  final DeviceType deviceType;

  /// Whether running on iOS (with optional override for testing)
  bool get _isIos => _isIosOverride ?? UnifiedIosPlatform.isIos;

  /// Whether running on macOS (with optional override for testing)
  bool get _isMacos => _isMacosOverride ?? UnifiedIosPlatform.isMacos;

  @override
  bool get isSupported {
    // iOS/macOS 原生效能檢測
    if (_isIos || _isMacos) {
      return true;
    }
    // 行動裝置平台
    return deviceType == DeviceType.mobile;
  }

  @override
  Future<void> startActivity({
    required String activityType,
    required Map<String, dynamic> userInfo,
  }) async {
    // 如果是 iOS 平台，調用原生實現
    if (_isIos) {
      await _platformChannel.startHandoff(activityType, userInfo);
    }
  }

  @override
  Future<void> updateActivity({
    required Map<String, dynamic> userInfo,
  }) async {
    if (_isIos) {
      await _platformChannel.updateHandoff(userInfo);
    }
  }

  @override
  Future<void> endActivity() async {
    if (_isIos) {
      await _platformChannel.endHandoff();
    }
  }

  @override
  Future<Map<String, dynamic>?> receiveActivity() async {
    if (_isIos) {
      return await _platformChannel.receiveHandoff();
    }
    return null;
  }

  /// 方便方法：開始播放內容的 Handoff
  Future<void> startPlaybackHandoff(PlaybackHandoffInfo info) {
    return startActivity(
      activityType: 'com.white_tv.playback',
      userInfo: info.toUserInfo(),
    );
  }

  /// 方便方法：獲取待處理的播放內容
  Future<PlaybackHandoffInfo?> getPendingPlayback() async {
    final userInfo = await receiveActivity();
    if (userInfo == null) return null;
    return PlaybackHandoffInfo.fromUserInfo(userInfo);
  }
}