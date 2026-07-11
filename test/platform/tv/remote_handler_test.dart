import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/platform/tv/remote_handler.dart';

void main() {
  group('TVRemoteHandler', () {
    group('D-pad Navigation', () {
      test('handles arrow up key', () {
        final event = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.arrowUp,
          logicalKey: LogicalKeyboardKey.arrowUp,
          timeStamp: Duration.zero,
        );
        expect(TVRemoteHandler.handleKey(event), isTrue);
      });

      test('handles arrow down key', () {
        final event = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.arrowDown,
          logicalKey: LogicalKeyboardKey.arrowDown,
          timeStamp: Duration.zero,
        );
        expect(TVRemoteHandler.handleKey(event), isTrue);
      });

      test('handles arrow left key', () {
        final event = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.arrowLeft,
          logicalKey: LogicalKeyboardKey.arrowLeft,
          timeStamp: Duration.zero,
        );
        expect(TVRemoteHandler.handleKey(event), isTrue);
      });

      test('handles arrow right key', () {
        final event = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.arrowRight,
          logicalKey: LogicalKeyboardKey.arrowRight,
          timeStamp: Duration.zero,
        );
        expect(TVRemoteHandler.handleKey(event), isTrue);
      });

      test('handles select key', () {
        final event = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.select,
          logicalKey: LogicalKeyboardKey.select,
          timeStamp: Duration.zero,
        );
        expect(TVRemoteHandler.handleKey(event), isTrue);
      });
    });

    group('Player Controls', () {
      test('handles play key', () {
        final event = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.mediaPlayPause,
          logicalKey: LogicalKeyboardKey.mediaPlayPause,
          timeStamp: Duration.zero,
        );
        expect(TVRemoteHandler.handleKey(event), isTrue);
      });

      test('handles fast forward key', () {
        final event = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.mediaFastForward,
          logicalKey: LogicalKeyboardKey.mediaFastForward,
          timeStamp: Duration.zero,
        );
        expect(TVRemoteHandler.handleKey(event), isTrue);
      });

      test('handles rewind key', () {
        final event = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.mediaRewind,
          logicalKey: LogicalKeyboardKey.mediaRewind,
          timeStamp: Duration.zero,
        );
        expect(TVRemoteHandler.handleKey(event), isTrue);
      });

      test('handles volume up key', () {
        final event = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.audioVolumeUp,
          logicalKey: LogicalKeyboardKey.audioVolumeUp,
          timeStamp: Duration.zero,
        );
        expect(TVRemoteHandler.handleKey(event), isTrue);
      });

      test('handles volume down key', () {
        final event = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.audioVolumeDown,
          logicalKey: LogicalKeyboardKey.audioVolumeDown,
          timeStamp: Duration.zero,
        );
        expect(TVRemoteHandler.handleKey(event), isTrue);
      });

      test('handles mute key', () {
        final event = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.audioVolumeMute,
          logicalKey: LogicalKeyboardKey.audioVolumeMute,
          timeStamp: Duration.zero,
        );
        expect(TVRemoteHandler.handleKey(event), isTrue);
      });
    });

    group('Page Navigation', () {
      test('handles back key', () {
        final event = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.browserBack,
          logicalKey: LogicalKeyboardKey.browserBack,
          timeStamp: Duration.zero,
        );
        expect(TVRemoteHandler.handleKey(event), isTrue);
      });

      test('handles home key', () {
        final event = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.home,
          logicalKey: LogicalKeyboardKey.home,
          timeStamp: Duration.zero,
        );
        expect(TVRemoteHandler.handleKey(event), isTrue);
      });
    });

    group('KeyEvent type filtering', () {
      test('ignores KeyUpEvent', () {
        final event = KeyUpEvent(
          physicalKey: PhysicalKeyboardKey.arrowUp,
          logicalKey: LogicalKeyboardKey.arrowUp,
          timeStamp: Duration.zero,
        );
        expect(TVRemoteHandler.handleKey(event), isFalse);
      });

      test('ignores KeyRepeatEvent', () {
        final event = KeyRepeatEvent(
          physicalKey: PhysicalKeyboardKey.arrowUp,
          logicalKey: LogicalKeyboardKey.arrowUp,
          timeStamp: Duration.zero,
        );
        expect(TVRemoteHandler.handleKey(event), isFalse);
      });
    });
  });
}
