import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/device/device_type.dart';
import 'package:white_tv/core/input/keyboard_handler.dart';

void main() {
  group('KeyboardShortcutsHandler', () {
    late KeyboardShortcutsHandler handler;

    setUp(() {
      handler = KeyboardShortcutsHandler();
    });

    group('FeatureFlags.enableKeyboardNavigation gating', () {
      test('returns KeyEventResult.skipAndDismissUri for Space on tablet when feature is enabled', () {
        // FeatureFlags.enableKeyboardNavigation(tablet) == true
        // Space key should trigger play/pause
        final event = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.space,
          logicalKey: LogicalKeyboardKey.space,
          timeStamp: Duration.zero,
        );
        final result = handler.handleKeyEvent(event, DeviceType.tablet);
        expect(result, KeyEventResult.handled);
      });

      test('returns KeyEventResult.ignored for Space on TV when feature is disabled', () {
        // FeatureFlags.enableKeyboardNavigation(tv) == false
        // Keyboard navigation is only enabled for tablet and desktop
        final event = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.space,
          logicalKey: LogicalKeyboardKey.space,
          timeStamp: Duration.zero,
        );
        final result = handler.handleKeyEvent(event, DeviceType.tv);
        expect(result, KeyEventResult.ignored);
      });

      test('returns KeyEventResult.ignored for Space on mobile when feature is disabled', () {
        // FeatureFlags.enableKeyboardNavigation(mobile) == false
        final event = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.space,
          logicalKey: LogicalKeyboardKey.space,
          timeStamp: Duration.zero,
        );
        final result = handler.handleKeyEvent(event, DeviceType.mobile);
        expect(result, KeyEventResult.ignored);
      });

      test('allows arrow key seek on desktop when feature is enabled', () {
        // FeatureFlags.enableKeyboardNavigation(desktop) == true
        final event = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.arrowRight,
          logicalKey: LogicalKeyboardKey.arrowRight,
          timeStamp: Duration.zero,
        );
        final result = handler.handleKeyEvent(event, DeviceType.desktop);
        expect(result, KeyEventResult.handled);
      });

      test('returns KeyEventResult.ignored for arrow keys on mobile when feature is disabled', () {
        final event = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.arrowRight,
          logicalKey: LogicalKeyboardKey.arrowRight,
          timeStamp: Duration.zero,
        );
        final result = handler.handleKeyEvent(event, DeviceType.mobile);
        expect(result, KeyEventResult.ignored);
      });
    });

    group('Player controls - Space (play/pause)', () {
      test('Space key triggers play/pause on tablet', () {
        final event = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.space,
          logicalKey: LogicalKeyboardKey.space,
          timeStamp: Duration.zero,
        );
        final result = handler.handleKeyEvent(event, DeviceType.tablet);
        expect(result, KeyEventResult.handled);
      });

      test('Space key triggers play/pause on desktop', () {
        final event = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.space,
          logicalKey: LogicalKeyboardKey.space,
          timeStamp: Duration.zero,
        );
        final result = handler.handleKeyEvent(event, DeviceType.desktop);
        expect(result, KeyEventResult.handled);
      });

      test('Space key is ignored on TV device type', () {
        final event = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.space,
          logicalKey: LogicalKeyboardKey.space,
          timeStamp: Duration.zero,
        );
        final result = handler.handleKeyEvent(event, DeviceType.tv);
        expect(result, KeyEventResult.ignored);
      });
    });

    group('Player controls - Arrow keys (seek)', () {
      test('ArrowRight key seeks forward on tablet', () {
        final event = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.arrowRight,
          logicalKey: LogicalKeyboardKey.arrowRight,
          timeStamp: Duration.zero,
        );
        final result = handler.handleKeyEvent(event, DeviceType.tablet);
        expect(result, KeyEventResult.handled);
      });

      test('ArrowLeft key seeks backward on tablet', () {
        final event = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.arrowLeft,
          logicalKey: LogicalKeyboardKey.arrowLeft,
          timeStamp: Duration.zero,
        );
        final result = handler.handleKeyEvent(event, DeviceType.tablet);
        expect(result, KeyEventResult.handled);
      });

      test('ArrowRight key seeks forward on desktop', () {
        final event = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.arrowRight,
          logicalKey: LogicalKeyboardKey.arrowRight,
          timeStamp: Duration.zero,
        );
        final result = handler.handleKeyEvent(event, DeviceType.desktop);
        expect(result, KeyEventResult.handled);
      });

      test('ArrowLeft key seeks backward on desktop', () {
        final event = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.arrowLeft,
          logicalKey: LogicalKeyboardKey.arrowLeft,
          timeStamp: Duration.zero,
        );
        final result = handler.handleKeyEvent(event, DeviceType.desktop);
        expect(result, KeyEventResult.handled);
      });

      test('Arrow keys are ignored on TV device type', () {
        final event = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.arrowRight,
          logicalKey: LogicalKeyboardKey.arrowRight,
          timeStamp: Duration.zero,
        );
        final result = handler.handleKeyEvent(event, DeviceType.tv);
        expect(result, KeyEventResult.ignored);
      });
    });

    group('Non-player keys', () {
      test('Other keys return KeyEventResult.ignored', () {
        final event = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.keyA,
          logicalKey: LogicalKeyboardKey.keyA,
          timeStamp: Duration.zero,
        );
        final result = handler.handleKeyEvent(event, DeviceType.tablet);
        expect(result, KeyEventResult.ignored);
      });
    });
  });
}