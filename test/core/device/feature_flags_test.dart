import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/device/device_type.dart';
import 'package:white_tv/core/device/feature_flags.dart';

void main() {
  group('FeatureFlags', () {
    group('QR Remote Control', () {
      test('TV 平台啟用 QR Remote', () {
        expect(FeatureFlags.enableQRRemote(DeviceType.tv), isTrue);
      });

      test('Mobile 平台啟用 QR Remote', () {
        expect(FeatureFlags.enableQRRemote(DeviceType.mobile), isTrue);
      });

      test('Tablet 平台停用 QR Remote', () {
        expect(FeatureFlags.enableQRRemote(DeviceType.tablet), isFalse);
      });

      test('Desktop 平台停用 QR Remote', () {
        expect(FeatureFlags.enableQRRemote(DeviceType.desktop), isFalse);
      });
    });

    group('Siri Shortcuts', () {
      test('TV 平台停用 Siri Shortcuts', () {
        expect(FeatureFlags.enableSiriShortcuts(DeviceType.tv), isFalse);
      });

      test('Mobile 平台啟用 Siri Shortcuts', () {
        expect(FeatureFlags.enableSiriShortcuts(DeviceType.mobile), isTrue);
      });

      test('Tablet 平台停用 Siri Shortcuts', () {
        expect(FeatureFlags.enableSiriShortcuts(DeviceType.tablet), isFalse);
      });

      test('Desktop 平台停用 Siri Shortcuts', () {
        expect(FeatureFlags.enableSiriShortcuts(DeviceType.desktop), isFalse);
      });
    });

    group('Picture-in-Picture', () {
      test('TV 平台停用 PiP', () {
        expect(FeatureFlags.enablePiP(DeviceType.tv), isFalse);
      });

      test('Mobile 平台啟用 PiP', () {
        expect(FeatureFlags.enablePiP(DeviceType.mobile), isTrue);
      });

      test('Tablet 平台啟用 PiP', () {
        expect(FeatureFlags.enablePiP(DeviceType.tablet), isTrue);
      });

      test('Desktop 平台啟用 PiP', () {
        expect(FeatureFlags.enablePiP(DeviceType.desktop), isTrue);
      });
    });

    group('Handoff', () {
      test('TV 平台停用 Handoff', () {
        expect(FeatureFlags.enableHandoff(DeviceType.tv), isFalse);
      });

      test('Mobile 平台啟用 Handoff', () {
        expect(FeatureFlags.enableHandoff(DeviceType.mobile), isTrue);
      });

      test('Tablet 平台停用 Handoff', () {
        expect(FeatureFlags.enableHandoff(DeviceType.tablet), isFalse);
      });

      test('Desktop 平台停用 Handoff', () {
        expect(FeatureFlags.enableHandoff(DeviceType.desktop), isFalse);
      });
    });

    group('Keyboard Navigation', () {
      test('TV 平台停用 Keyboard Navigation', () {
        expect(FeatureFlags.enableKeyboardNavigation(DeviceType.tv), isFalse);
      });

      test('Mobile 平台停用 Keyboard Navigation', () {
        expect(FeatureFlags.enableKeyboardNavigation(DeviceType.mobile), isFalse);
      });

      test('Tablet 平台啟用 Keyboard Navigation', () {
        expect(FeatureFlags.enableKeyboardNavigation(DeviceType.tablet), isTrue);
      });

      test('Desktop 平台啟用 Keyboard Navigation', () {
        expect(FeatureFlags.enableKeyboardNavigation(DeviceType.desktop), isTrue);
      });
    });

    group('Mouse Pointer', () {
      test('TV 平台停用 Mouse Pointer', () {
        expect(FeatureFlags.enableMousePointer(DeviceType.tv), isFalse);
      });

      test('Mobile 平台停用 Mouse Pointer', () {
        expect(FeatureFlags.enableMousePointer(DeviceType.mobile), isFalse);
      });

      test('Tablet 平台啟用 Mouse Pointer', () {
        expect(FeatureFlags.enableMousePointer(DeviceType.tablet), isTrue);
      });

      test('Desktop 平台啟用 Mouse Pointer', () {
        expect(FeatureFlags.enableMousePointer(DeviceType.desktop), isTrue);
      });
    });

    group('Sidebar Navigation', () {
      test('TV 平台停用 Sidebar Navigation', () {
        expect(FeatureFlags.enableSidebarNavigation(DeviceType.tv), isFalse);
      });

      test('Mobile 平台停用 Sidebar Navigation', () {
        expect(FeatureFlags.enableSidebarNavigation(DeviceType.mobile), isFalse);
      });

      test('Tablet 平台啟用 Sidebar Navigation', () {
        expect(FeatureFlags.enableSidebarNavigation(DeviceType.tablet), isTrue);
      });

      test('Desktop 平台停用 Sidebar Navigation', () {
        expect(FeatureFlags.enableSidebarNavigation(DeviceType.desktop), isFalse);
      });
    });

    group('Dock Navigation', () {
      test('TV 平台停用 Dock Navigation', () {
        expect(FeatureFlags.enableDockNavigation(DeviceType.tv), isFalse);
      });

      test('Mobile 平台停用 Dock Navigation', () {
        expect(FeatureFlags.enableDockNavigation(DeviceType.mobile), isFalse);
      });

      test('Tablet 平台停用 Dock Navigation', () {
        expect(FeatureFlags.enableDockNavigation(DeviceType.tablet), isFalse);
      });

      test('Desktop 平台啟用 Dock Navigation', () {
        expect(FeatureFlags.enableDockNavigation(DeviceType.desktop), isTrue);
      });
    });
  });
}
