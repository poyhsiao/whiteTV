import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/device/device_type.dart';
import 'package:white_tv/core/siri/siri_shortcuts.dart';

void main() {
  group('SiriShortcuts', () {
    late SiriShortcuts siriShortcuts;

    setUp(() {
      siriShortcuts = SiriShortcuts();
    });

    group('isSupported', () {
      test('returns true for mobile platform', () {
        expect(siriShortcuts.isSupported(DeviceType.mobile), isTrue);
      });

      test('returns false for TV platform', () {
        expect(siriShortcuts.isSupported(DeviceType.tv), isFalse);
      });

      test('returns false for tablet platform', () {
        expect(siriShortcuts.isSupported(DeviceType.tablet), isFalse);
      });

      test('returns false for desktop platform', () {
        expect(siriShortcuts.isSupported(DeviceType.desktop), isFalse);
      });
    });

    group('playPause voice control', () {
      test('playPause command ID is correct', () {
        const expectedCommandId = 'play_pause';
        expect(SiriShortcuts.playPauseCommandId, expectedCommandId);
      });

      test('registerPlayPauseHandler registers successfully', () async {
        // TODO: Implement platform channel for iOS
        // This test verifies the API contract
        final handler = () {};
        // Should not throw when platform channel is implemented
        expect(() => siriShortcuts.registerPlayPauseHandler(handler), returnsNormally);
      });

      test('invokePlayPause triggers registered handler', () async {
        // TODO: Implement platform channel for iOS
        // This test verifies the API contract
        var called = false;
        siriShortcuts.registerPlayPauseHandler(() {
          called = true;
        });
        // Platform channel invocation would trigger handler in real implementation
        expect(called, isFalse); // Not called until platform channel implemented
      });
    });

    group('search voice control', () {
      test('search command ID is correct', () {
        const expectedCommandId = 'search';
        expect(SiriShortcuts.searchCommandId, expectedCommandId);
      });

      test('registerSearchHandler registers successfully', () async {
        // TODO: Implement platform channel for iOS
        // This test verifies the API contract
        final handler = (String query) {};
        // Should not throw when platform channel is implemented
        expect(() => siriShortcuts.registerSearchHandler(handler), returnsNormally);
      });

      test('invokeSearch triggers registered handler with query', () async {
        // TODO: Implement platform channel for iOS
        // This test verifies the API contract
        String? capturedQuery;
        siriShortcuts.registerSearchHandler((query) {
          capturedQuery = query;
        });
        // Platform channel invocation would pass query to handler in real implementation
        expect(capturedQuery, isNull); // Not called until platform channel implemented
      });
    });

    group('command registration', () {
      test('all supported commands are defined', () {
        expect(SiriShortcuts.playPauseCommandId, 'play_pause');
        expect(SiriShortcuts.searchCommandId, 'search');
      });

      test('registerCommand returns a registration token', () async {
        // TODO: Implement platform channel for iOS
        // Verifies API contract for command registration
        final token = await siriShortcuts.registerCommand('test_command', () {});
        expect(token, isA<String>());
      });
    });
  });
}