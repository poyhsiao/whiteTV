// ARCHITECTURE §4.1: TV 平台遙控器處理
import 'package:flutter/services.dart';
import 'focus_manager.dart';

/// TV 平台遙控器按鍵處理
/// 參照 UI_UX.md §16 遙控器按鍵對應
class TVRemoteHandler {
  /// 處理遙控器按鍵，回傳是否已處理
  /// 回傳 true 表示已消耗此按鍵，呼叫端不應再做預設處理
  static bool handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    // D-pad 導航（目前僅攔截，實際 focus 移動由 FocusManager 處理）
    if (TVFocusManager.isDpadKey(event.logicalKey)) return true;

    // 播放控制（目前僅佔位，日後串接 PlayerStore）
    if (_isPlayerKey(event.logicalKey)) return true;

    // 音量控制（目前僅佔位）
    if (_isVolumeKey(event.logicalKey)) return true;

    // 頁面導航（目前僅佔位）
    if (_isNavigationKey(event.logicalKey)) return true;

    return false;
  }

  /// 判斷是否為播放控制按鍵（不含音量）
  static bool _isPlayerKey(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.mediaPlayPause ||
        key == LogicalKeyboardKey.mediaFastForward ||
        key == LogicalKeyboardKey.mediaRewind ||
        key == LogicalKeyboardKey.mediaTrackNext ||
        key == LogicalKeyboardKey.mediaTrackPrevious ||
        key == LogicalKeyboardKey.mediaStop;
  }

  /// 判斷是否為音量按鍵
  static bool _isVolumeKey(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.audioVolumeUp ||
        key == LogicalKeyboardKey.audioVolumeDown ||
        key == LogicalKeyboardKey.audioVolumeMute;
  }

  /// 判斷是否為頁面導航按鍵
  static bool _isNavigationKey(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.browserBack ||
        key == LogicalKeyboardKey.home ||
        key == LogicalKeyboardKey.escape;
  }
}
