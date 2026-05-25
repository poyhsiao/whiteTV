import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/device/platform_utils.dart';

void main() {
  group('PlatformType', () {
    test('包含所有預期的平台類型', () {
      expect(PlatformType.values, contains(PlatformType.ios));
      expect(PlatformType.values, contains(PlatformType.android));
      expect(PlatformType.values, contains(PlatformType.macos));
      expect(PlatformType.values, contains(PlatformType.windows));
      expect(PlatformType.values, contains(PlatformType.linux));
      expect(PlatformType.values, contains(PlatformType.web));
      expect(PlatformType.values, contains(PlatformType.tvos));
      expect(PlatformType.values, contains(PlatformType.googleTV));
    });

    test('PlatformType 總數為 8', () {
      expect(PlatformType.values.length, 8);
    });
  });

  group('PlatformType extension', () {
    test('isApplePlatform 返回 true 當是 ios 或 macos 或 tvos', () {
      expect(PlatformType.ios.isApplePlatform, isTrue);
      expect(PlatformType.macos.isApplePlatform, isTrue);
      expect(PlatformType.tvos.isApplePlatform, isTrue);
    });

    test('isApplePlatform 返回 false 當不是 Apple 平台', () {
      expect(PlatformType.android.isApplePlatform, isFalse);
      expect(PlatformType.windows.isApplePlatform, isFalse);
      expect(PlatformType.linux.isApplePlatform, isFalse);
      expect(PlatformType.web.isApplePlatform, isFalse);
      expect(PlatformType.googleTV.isApplePlatform, isFalse);
    });

    test('isMobilePlatform 返回 true 當是 ios 或 android 或 googleTV', () {
      expect(PlatformType.ios.isMobilePlatform, isTrue);
      expect(PlatformType.android.isMobilePlatform, isTrue);
      expect(PlatformType.googleTV.isMobilePlatform, isTrue);
    });

    test('isMobilePlatform 返回 false 當不是 mobile 平台', () {
      expect(PlatformType.macos.isMobilePlatform, isFalse);
      expect(PlatformType.windows.isMobilePlatform, isFalse);
      expect(PlatformType.linux.isMobilePlatform, isFalse);
      expect(PlatformType.web.isMobilePlatform, isFalse);
      expect(PlatformType.tvos.isMobilePlatform, isFalse);
    });

    test('isDesktopPlatform 返回 true 當是 desktop 平台', () {
      expect(PlatformType.macos.isDesktopPlatform, isTrue);
      expect(PlatformType.windows.isDesktopPlatform, isTrue);
      expect(PlatformType.linux.isDesktopPlatform, isTrue);
    });

    test('isDesktopPlatform 返回 false 當不是 desktop 平台', () {
      expect(PlatformType.ios.isDesktopPlatform, isFalse);
      expect(PlatformType.android.isDesktopPlatform, isFalse);
      expect(PlatformType.tvos.isDesktopPlatform, isFalse);
      expect(PlatformType.googleTV.isDesktopPlatform, isFalse);
      expect(PlatformType.web.isDesktopPlatform, isFalse);
    });
  });

  group('getCurrentPlatform', () {
    test('在所有平台上 getCurrentPlatform 不返回 null', () {
      final platform = getCurrentPlatform();
      expect(platform, isNotNull);
      expect(PlatformType.values, contains(platform));
    });
  });
}