import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/device/device_type.dart';
import 'package:white_tv/core/siri/siri_shortcuts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SiriShortcuts', () {
    late SiriShortcuts siri;

    setUp(() {
      siri = SiriShortcuts();
    });

    group('isSupported', () {
      test('returns true for mobile device', () {
        expect(siri.isSupported(DeviceType.mobile), isTrue);
      });

      test('returns false for TV device', () {
        expect(siri.isSupported(DeviceType.tv), isFalse);
      });

      test('returns false for tablet device', () {
        expect(siri.isSupported(DeviceType.tablet), isFalse);
      });

      test('returns false for desktop device', () {
        expect(siri.isSupported(DeviceType.desktop), isFalse);
      });
    });

    group('registerPlayPauseHandler', () {
      test('does not throw when called (stub implementation)', () {
        expect(
          () => siri.registerPlayPauseHandler(() {}),
          returnsNormally,
        );
      });
    });

    group('invokePlayPause', () {
      test('does not throw when called without handler (stub implementation)', () {
        expect(() => siri.invokePlayPause(), returnsNormally);
      });
    });

    group('registerSearchHandler', () {
      test('does not throw when called (stub implementation)', () {
        expect(
          () => siri.registerSearchHandler((query) {}),
          returnsNormally,
        );
      });
    });

    group('invokeSearch', () {
      test('does not throw when called without handler (stub implementation)', () {
        expect(
          () => siri.invokeSearch('test query'),
          returnsNormally,
        );
      });
    });

    group('registerCommand', () {
      test('returns registration token string', () async {
        final token = await siri.registerCommand('test_command', () {});
        expect(token, isA<String>());
        expect(token, contains('test_command'));
      });

      test('returns unique tokens for different commands', () async {
        final token1 = await siri.registerCommand('cmd1', () {});
        final token2 = await siri.registerCommand('cmd2', () {});
        expect(token1, isNot(equals(token2)));
      });
    });

    group('unregisterCommand', () {
      test('does not throw when called (stub implementation)', () async {
        await siri.unregisterCommand('any_token');
        // No exception means success
      });
    });

    group('updateSuggestions', () {
      test('does not throw when called with empty list', () async {
        await siri.updateSuggestions([]);
      });

      test('does not throw when called with command list', () async {
        await siri.updateSuggestions(['play_pause', 'search']);
      });
    });

    group('command IDs', () {
      test('playPauseCommandId is defined', () {
        expect(SiriShortcuts.playPauseCommandId, equals('play_pause'));
      });

      test('searchCommandId is defined', () {
        expect(SiriShortcuts.searchCommandId, equals('search'));
      });
    });
  });
}
