import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/device/device_type.dart';

void main() {
  group('DeviceType', () {
    test('包含所有預期的設備類型', () {
      expect(DeviceType.values, contains(DeviceType.tv));
      expect(DeviceType.values, contains(DeviceType.mobile));
      expect(DeviceType.values, contains(DeviceType.tablet));
      expect(DeviceType.values, contains(DeviceType.desktop));
    });

    test('DeviceType.desktop 是獨立的成員', () {
      final desktop = DeviceType.desktop;
      expect(desktop, isNot(DeviceType.tv));
      expect(desktop, isNot(DeviceType.mobile));
      expect(desktop, isNot(DeviceType.tablet));
    });

    test('DeviceType 總數為 4', () {
      expect(DeviceType.values.length, 4);
    });
  });

  group('DeviceType extension', () {
    test('isTV 返回 true 當 deviceType 是 tv', () {
      expect(DeviceType.tv.isTV, isTrue);
    });

    test('isMobile 返回 true 當 deviceType 是 mobile', () {
      expect(DeviceType.mobile.isMobile, isTrue);
    });

    test('isTablet 返回 true 當 deviceType 是 tablet', () {
      expect(DeviceType.tablet.isTablet, isTrue);
    });

    test('isDesktop 返回 true 當 deviceType 是 desktop', () {
      expect(DeviceType.desktop.isDesktop, isTrue);
    });

    test('其他類型 isDesktop 返回 false', () {
      expect(DeviceType.tv.isDesktop, isFalse);
      expect(DeviceType.mobile.isDesktop, isFalse);
      expect(DeviceType.tablet.isDesktop, isFalse);
    });
  });
}