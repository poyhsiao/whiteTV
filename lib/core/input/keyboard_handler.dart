import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:white_tv/core/device/device_type.dart';
import 'package:white_tv/core/device/feature_flags.dart';

/// 全域鍵盤快捷鍵處理器
/// 針對 player 控制項（播放/暫停、搜尋）提供快捷鍵支援
/// 只在 tablet 和 desktop 平台上啟用（由 FeatureFlags.enableKeyboardNavigation 控制）
class KeyboardShortcutsHandler {
  /// Callback for player control commands
  void Function(PlayerCommand)? onPlayerCommand;

  /// 處理鍵盤事件
  ///
  /// [event] - Flutter 鍵盤事件
  /// [deviceType] - 當前設備類型
  ///
  /// 返回 [KeyEventResult.handled] 表示已處理快捷鍵
  /// 返回 [KeyEventResult.ignored] 表示未處理（功能關閉或不支持的按鍵）
  KeyEventResult handleKeyEvent(KeyEvent event, DeviceType deviceType) {
    // 只在 tablet 和 desktop 上啟用鍵盤導航
    if (!FeatureFlags.enableKeyboardNavigation(deviceType)) {
      return KeyEventResult.ignored;
    }

    // 只處理按下事件
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    // Space = 播放/暫停
    if (event.logicalKey == LogicalKeyboardKey.space) {
      onPlayerCommand?.call(PlayerCommand.playPause);
      return KeyEventResult.handled;
    }

    // 方向鍵 = 搜尋
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      onPlayerCommand?.call(PlayerCommand.seekForward);
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      onPlayerCommand?.call(PlayerCommand.seekBackward);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }
}

/// Player control commands
enum PlayerCommand {
  playPause,
  seekForward,
  seekBackward,
}