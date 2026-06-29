// Behavioral test for platform/ stubs (ARCHITECTURE §4.1)
// Verifies: TVFocusManager, MobilePlatformConfig, WebPlatformConfig APIs
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/platform/mobile/platform_config.dart';
import 'package:white_tv/platform/tv/focus_manager.dart';
import 'package:white_tv/platform/web/platform_config.dart';

void main() {
  test('TVFocusManager.dpadKeys includes navigation keys', () {
    expect(TVFocusManager.dpadKeys, isNotEmpty);
    expect(TVFocusManager.dpadKeys, contains(LogicalKeyboardKey.arrowUp));
    expect(TVFocusManager.dpadKeys, contains(LogicalKeyboardKey.arrowDown));
    expect(TVFocusManager.dpadKeys, contains(LogicalKeyboardKey.arrowLeft));
    expect(TVFocusManager.dpadKeys, contains(LogicalKeyboardKey.arrowRight));
  });

  test('MobilePlatformConfig.isMobile is a callable function', () {
    expect(MobilePlatformConfig.isMobile, isA<Function>());
  });

  test('WebPlatformConfig.isWeb returns false on native test platform', () {
    expect(WebPlatformConfig.isWeb, isFalse);
  });
}