// ARCHITECTURE §4.1: TV 平台 Focus 管理
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../../core/device/device_utils.dart';

/// TV 平台 Focus 管理器
class TVFocusManager {
  /// 判斷是否為 TV 平台
  static bool isTV(BuildContext context) => DeviceUtils.isTV(context);

  /// 標準 D-pad 按鍵
  static final dpadKeys = <LogicalKeyboardKey>{
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight,
    LogicalKeyboardKey.select,
  };
}