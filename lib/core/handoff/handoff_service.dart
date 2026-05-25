import 'package:flutter/services.dart';
import 'package:white_tv/core/device/device_type.dart';

/// Handoff 服務介面
/// 支援 iOS/macOS Universal Clipboard 和 Handoff 功能
///
/// 實現狀態：
/// - [ ] iOS 平台通道需使用 MethodChannel 調用原生 API
/// - [ ] macOS 平台通道需使用 platform view 或 MethodChannel
/// - [ ] 需處理 NSUserActivity 和 UISearchSuggestion 的平台特定實作
///
/// TODO: 實現 iOS platform channel (MethodChannel)
/// TODO: 實現 macOS platform channel (MethodChannel)
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
  HandoffService({required this.deviceType});

  final DeviceType deviceType;

  // TODO: 實現 iOS/macOS platform channel
  // 使用 MethodChannel 與原生代碼通信
  // ignore: unused_field (platform channel for future native implementation)
  static const MethodChannel _channel = MethodChannel('com.white_tv/handoff');

  // 當前活動的用戶信息緩存
  // ignore: unused_field (user info cache for future handoff implementation)
  Map<String, dynamic>? _currentActivityUserInfo;

  @override
  bool get isSupported {
    // TODO: 平台通道實現後需調用原生方法確認
    // 目前僅根據設備類型初步判斷
    return deviceType == DeviceType.mobile;
  }

  @override
  Future<void> startActivity({
    required String activityType,
    required Map<String, dynamic> userInfo,
  }) async {
    // TODO: 調用原生 API 開始 Handoff 活動
    // await _channel.invokeMethod('startActivity', {
    //   'activityType': activityType,
    //   'userInfo': userInfo,
    // });
    _currentActivityUserInfo = userInfo;
  }

  @override
  Future<void> updateActivity({
    required Map<String, dynamic> userInfo,
  }) async {
    // TODO: 調用原生 API 更新活動狀態
    // await _channel.invokeMethod('updateActivity', {
    //   'userInfo': userInfo,
    // });
    _currentActivityUserInfo = userInfo;
  }

  @override
  Future<void> endActivity() async {
    // TODO: 調用原生 API 結束活動
    // await _channel.invokeMethod('endActivity');
    _currentActivityUserInfo = null;
  }

  @override
  Future<Map<String, dynamic>?> receiveActivity() async {
    // TODO: 調用原生 API 接收來自其他設備的活動
    // final result = await _channel.invokeMethod<Map>('receiveActivity');
    // return result?.cast<String, dynamic>();
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