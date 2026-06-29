// ARCHITECTURE §4.1: Web 平台特定配置
import 'package:flutter/foundation.dart';

class WebPlatformConfig {
  /// Web 平台透過 kIsWeb 判斷（避免依賴 DeviceUtils 需 context）
  static bool get isWeb => kIsWeb;
}