// ARCHITECTURE §4.1: TV 平台遙控器處理
import 'package:flutter/services.dart';

/// TV 平台遙控器按鍵處理
class TVRemoteHandler {
  /// 處理遙控器按鍵，回傳是否已處理
  static bool handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    return false;
  }
}