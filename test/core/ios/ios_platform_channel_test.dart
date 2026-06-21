// test/core/ios/ios_platform_channel_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/ios/ios_platform_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    // Clean up mock handler after each test to prevent cross-test pollution
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.white_tv/ios'),
      null,
    );
  });

  group('IosPlatformChannel', () {
    test('startHandoff calls platform channel', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.white_tv/ios'),
        (MethodCall call) async {
          expect(call.method, 'handoff.startActivity');
          return true;
        },
      );

      final result = await IosPlatformChannel.instance.startHandoff(
        'com.white_tv.playback',
        {'contentId': '123'},
      );
      expect(result, true);
    });

    test('startHandoff returns false on platform exception', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.white_tv/ios'),
        (MethodCall call) async {
          throw PlatformException(code: 'UNAVAILABLE');
        },
      );

      final result = await IosPlatformChannel.instance.startHandoff(
        'com.white_tv.playback',
        {},
      );
      expect(result, false);
    });
  });
}
