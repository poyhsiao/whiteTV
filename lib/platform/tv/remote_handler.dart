// ARCHITECTURE §4.1: TV 平台遙控器處理
import 'package:flutter/services.dart';
import 'focus_manager.dart';

/// Player controls exposed by the UI layer for TV remote integration
// ponytail: callbacks injected at construction — keeps handler testable without PlayerStore dependency
abstract class PlayerControls {
  void play();
  void pause();
  void seekForward(Duration duration);
  void seekBackward(Duration duration);
  void nextEpisode();
  void previousEpisode();
}

/// TV 平台遙控器按鍵處理
/// 參照 UI_UX.md §16 遙控器按鍵對應
class TVRemoteHandler {
  final PlayerControls? playerControls;

  TVRemoteHandler({this.playerControls});

  /// 處理遙控器按鍵，回傳是否已處理
  /// 回傳 true 表示已消耗此按鍵，呼叫端不應再做預設處理
  bool handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    // D-pad 導航（目前僅攔截，實際 focus 移動由 FocusManager 處理）
    if (TVFocusManager.isDpadKey(event.logicalKey)) return true;

    // 播放控制
    if (isPlayerKey(event.logicalKey)) {
      _dispatchPlayerKey(event.logicalKey);
      return true;
    }

    // 音量控制（目前僅佔位）
    if (isVolumeKey(event.logicalKey)) return true;

    // 頁面導航（目前僅佔位）
    if (isNavigationKey(event.logicalKey)) return true;

    return false;
  }

  void _dispatchPlayerKey(LogicalKeyboardKey key) {
    if (playerControls == null) return;
    switch (key) {
      case LogicalKeyboardKey.mediaPlayPause:
        // toggle — not directly supported, treat as no-op to avoid double-toggle
        break;
      case LogicalKeyboardKey.mediaFastForward:
        playerControls!.seekForward(const Duration(seconds: 10));
        break;
      case LogicalKeyboardKey.mediaRewind:
        playerControls!.seekBackward(const Duration(seconds: 10));
        break;
      case LogicalKeyboardKey.mediaTrackNext:
        playerControls!.nextEpisode();
        break;
      case LogicalKeyboardKey.mediaTrackPrevious:
        playerControls!.previousEpisode();
        break;
      case LogicalKeyboardKey.mediaStop:
        playerControls!.pause();
        break;
    }
  }

  /// 判斷是否為播放控制按鍵（不含音量）
  static bool isPlayerKey(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.mediaPlayPause ||
        key == LogicalKeyboardKey.mediaFastForward ||
        key == LogicalKeyboardKey.mediaRewind ||
        key == LogicalKeyboardKey.mediaTrackNext ||
        key == LogicalKeyboardKey.mediaTrackPrevious ||
        key == LogicalKeyboardKey.mediaStop;
  }

  /// 判斷是否為音量按鍵
  static bool isVolumeKey(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.audioVolumeUp ||
        key == LogicalKeyboardKey.audioVolumeDown ||
        key == LogicalKeyboardKey.audioVolumeMute;
  }

  /// 判斷是否為頁面導航按鍵
  static bool isNavigationKey(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.browserBack ||
        key == LogicalKeyboardKey.home ||
        key == LogicalKeyboardKey.escape;
  }
}
