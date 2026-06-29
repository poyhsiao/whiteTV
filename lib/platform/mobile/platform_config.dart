// ARCHITECTURE §4.1: Mobile 平台特定配置
import 'package:flutter/widgets.dart';
import '../../core/device/device_utils.dart';

class MobilePlatformConfig {
  static bool isMobile(BuildContext context) => DeviceUtils.isMobile(context);
}