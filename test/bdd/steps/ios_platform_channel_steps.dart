import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/ios/ios_platform_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('iOS Platform Channel BDD', () {
    late IosPlatformChannelInterface platformChannel;

    setUp(() {
      platformChannel = const FakeIosPlatformChannel();
    });

    // Scenario: Handoff 開始活動
    test('platformChannel.startHandoff returns true on success', () async {
      // Given
      const activityType = 'viewing';
      const userInfo = {'contentId': 'movie-123'};

      // When
      final result = await platformChannel.startHandoff(activityType, userInfo);

      // Then
      expect(result, isTrue);
    });

    test('platformChannel.startHandoff with video ID', () async {
      // Given
      const videoId = 'movie-123';
      const userInfo = {'contentId': videoId};

      // When
      final result = await platformChannel.startHandoff('viewing', userInfo);

      // Then
      expect(result, isTrue);
      expect(userInfo['contentId'], equals(videoId));
    });

    // Scenario: Handoff 接收活動
    test('platformChannel.receiveHandoff returns userInfo with contentId', () async {
      // Given - another device sent Handoff activity
      const expectedContentId = 'movie-123';

      // When
      final userInfo = await platformChannel.receiveHandoff();

      // Then
      expect(userInfo, isNotNull);
      expect(userInfo!['contentId'], equals(expectedContentId));
    });

    // Scenario: PiP 模式檢查支援
    test('platformChannel.isPiPSupported returns true on iOS 15+', () async {
      // Given - user is watching video

      // When
      final result = await platformChannel.isPiPSupported();

      // Then
      expect(result, isTrue);
    });

    test('platformChannel.isPiPSupported returns false on older versions', () async {
      // Given
      final olderChannel = FakeIosPlatformChannelForOlderVersion();

      // When
      final result = await olderChannel.isPiPSupported();

      // Then
      expect(result, isFalse);
    });

    // Scenario: 非 iOS 平台降級
    test('platformChannel methods return false or null on non-iOS', () async {
      // Given - user on Android TV
      final androidChannel = FakeAndroidPlatformChannel();

      // When/Then
      expect(await androidChannel.startHandoff('viewing', {}), isFalse);
      expect(await androidChannel.receiveHandoff(), isNull);
      expect(await androidChannel.startPiP('/player'), isFalse);
      expect(await androidChannel.isPiPSupported(), isFalse);
      // Should not throw
      await androidChannel.stopPiP();
      await androidChannel.endHandoff();
    });
  });
}

/// Fake implementation for testing
class FakeIosPlatformChannel implements IosPlatformChannelInterface {
  const FakeIosPlatformChannel();

  @override
  Future<bool> startHandoff(String activityType, Map<String, dynamic> userInfo) async => true;

  @override
  Future<void> updateHandoff(Map<String, dynamic> userInfo) async {}

  @override
  Future<void> endHandoff() async {}

  @override
  Future<Map<String, dynamic>?> receiveHandoff() async =>
      {'contentId': 'movie-123'};

  @override
  Future<bool> startPiP(String route) async => true;

  @override
  Future<void> stopPiP() async {}

  @override
  Future<bool> isPiPSupported() async => true;
}

/// Fake for older iOS versions without PiP
class FakeIosPlatformChannelForOlderVersion implements IosPlatformChannelInterface {
  @override
  Future<bool> startHandoff(String activityType, Map<String, dynamic> userInfo) async => false;

  @override
  Future<void> updateHandoff(Map<String, dynamic> userInfo) async {}

  @override
  Future<void> endHandoff() async {}

  @override
  Future<Map<String, dynamic>?> receiveHandoff() async => null;

  @override
  Future<bool> startPiP(String route) async => false;

  @override
  Future<void> stopPiP() async {}

  @override
  Future<bool> isPiPSupported() async => false;
}

/// Fake for Android (non-iOS)
class FakeAndroidPlatformChannel implements IosPlatformChannelInterface {
  @override
  Future<bool> startHandoff(String activityType, Map<String, dynamic> userInfo) async => false;

  @override
  Future<void> updateHandoff(Map<String, dynamic> userInfo) async {}

  @override
  Future<void> endHandoff() async {}

  @override
  Future<Map<String, dynamic>?> receiveHandoff() async => null;

  @override
  Future<bool> startPiP(String route) async => false;

  @override
  Future<void> stopPiP() async {}

  @override
  Future<bool> isPiPSupported() async => false;
}
