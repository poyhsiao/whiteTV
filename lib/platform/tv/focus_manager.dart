// ARCHITECTURE §4.1: TV 平台 Focus 管理
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../../core/device/device_utils.dart';

/// Focus 移動方向枚舉
enum FocusMoveDirection { up, down, left, right, unknown }

/// TV 平台 Focus 管理器
/// 參照 UI_UX.md §8.2 Focus 管理
class TVFocusManager {
  /// 判斷是否為 TV 平台
  static bool isTV(BuildContext context) => DeviceUtils.isTV(context);

  /// 標準 D-pad 按鍵集合（以 unmodifiableSet 避免每次複製）
  // ponytail: 全局常量 collection，記憶體固定，不隨訪問複製
  static final dpadKeys = Set.unmodifiable(<LogicalKeyboardKey>{
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight,
    LogicalKeyboardKey.select,
  });

  /// 根據按鍵獲取 Focus 移動方向
  static FocusMoveDirection getNextFocus(
    FocusNode currentFocus,
    LogicalKeyboardKey key,
  ) {
    switch (key) {
      case LogicalKeyboardKey.arrowUp:
        return FocusMoveDirection.up;
      case LogicalKeyboardKey.arrowDown:
        return FocusMoveDirection.down;
      case LogicalKeyboardKey.arrowLeft:
        return FocusMoveDirection.left;
      case LogicalKeyboardKey.arrowRight:
        return FocusMoveDirection.right;
      default:
        return FocusMoveDirection.unknown;
    }
  }

  /// 判斷是否為 D-pad 按鍵
  static bool isDpadKey(LogicalKeyboardKey key) => dpadKeys.contains(key);
}
