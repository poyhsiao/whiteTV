import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/device/device_type.dart';
import 'package:white_tv/core/input/keyboard_handler.dart';

void main() {
  late KeyboardShortcutsHandler handler;

  setUp(() {
    handler = KeyboardShortcutsHandler();
  });

  KeyDownEvent keyDown(LogicalKeyboardKey key) {
    return KeyDownEvent(
      physicalKey: PhysicalKeyboardKey(key.keyId),
      logicalKey: key,
      timeStamp: Duration.zero,
    );
  }

  KeyUpEvent keyUp(LogicalKeyboardKey key) {
    return KeyUpEvent(
      physicalKey: PhysicalKeyboardKey(key.keyId),
      logicalKey: key,
      timeStamp: Duration.zero,
    );
  }

  group('KeyboardShortcutsHandler.handleKeyEvent', () {
    test('ignores all keys on mobile devices', () {
      expect(
        handler.handleKeyEvent(
          keyDown(LogicalKeyboardKey.space),
          DeviceType.mobile,
        ),
        KeyEventResult.ignored,
      );
      expect(
        handler.handleKeyEvent(
          keyDown(LogicalKeyboardKey.arrowRight),
          DeviceType.mobile,
        ),
        KeyEventResult.ignored,
      );
    });

    test('handles space key on tablet', () {
      final result = handler.handleKeyEvent(
        keyDown(LogicalKeyboardKey.space),
        DeviceType.tablet,
      );
      expect(result, KeyEventResult.handled);
    });

    test('handles arrow keys on desktop', () {
      expect(
        handler.handleKeyEvent(
          keyDown(LogicalKeyboardKey.arrowRight),
          DeviceType.desktop,
        ),
        KeyEventResult.handled,
      );
      expect(
        handler.handleKeyEvent(
          keyDown(LogicalKeyboardKey.arrowLeft),
          DeviceType.desktop,
        ),
        KeyEventResult.handled,
      );
    });

    test('ignores key-up events', () {
      final result = handler.handleKeyEvent(
        keyUp(LogicalKeyboardKey.space),
        DeviceType.tablet,
      );
      expect(result, KeyEventResult.ignored);
    });

    test('ignores unsupported keys on enabled devices', () {
      final result = handler.handleKeyEvent(
        keyDown(LogicalKeyboardKey.keyA),
        DeviceType.tablet,
      );
      expect(result, KeyEventResult.ignored);
    });

    test('respects FeatureFlags.enableKeyboardNavigation behavior', () {
      // FeatureFlags.enableKeyboardNavigation is a static method that returns
      // true for tablet and desktop by default. Confirm the handler defers to
      // it for tv as well as mobile.
      expect(
        handler.handleKeyEvent(
          keyDown(LogicalKeyboardKey.space),
          DeviceType.tv,
        ),
        KeyEventResult.ignored,
      );
      expect(
        handler.handleKeyEvent(
          keyDown(LogicalKeyboardKey.space),
          DeviceType.mobile,
        ),
        KeyEventResult.ignored,
      );
    });
  });
}
