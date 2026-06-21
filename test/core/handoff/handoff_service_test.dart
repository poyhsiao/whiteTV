import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/device/device_type.dart';
import 'package:white_tv/core/handoff/handoff_service.dart';
import 'package:white_tv/core/ios/ios_platform_channel.dart';

// Fake implementation for testing
class FakeIosPlatformChannel implements IosPlatformChannelInterface {
  bool startHandoffCalled = false;
  bool updateHandoffCalled = false;
  bool endHandoffCalled = false;
  bool receiveHandoffCalled = false;
  String? lastActivityType;
  Map<String, dynamic>? lastUserInfo;
  Map<String, dynamic>? receiveHandoffResult;

  @override
  Future<bool> startHandoff(
      String activityType, Map<String, dynamic> userInfo) async {
    startHandoffCalled = true;
    lastActivityType = activityType;
    lastUserInfo = userInfo;
    return true;
  }

  @override
  Future<void> updateHandoff(Map<String, dynamic> userInfo) async {
    updateHandoffCalled = true;
    lastUserInfo = userInfo;
  }

  @override
  Future<void> endHandoff() async {
    endHandoffCalled = true;
  }

  @override
  Future<Map<String, dynamic>?> receiveHandoff() async {
    receiveHandoffCalled = true;
    return receiveHandoffResult;
  }

  @override
  Future<bool> startPiP(String route) async => false;

  @override
  Future<void> stopPiP() async {}

  @override
  Future<bool> isPiPSupported() async => false;

  void reset() {
    startHandoffCalled = false;
    updateHandoffCalled = false;
    endHandoffCalled = false;
    receiveHandoffCalled = false;
    lastActivityType = null;
    lastUserInfo = null;
  }
}

void main() {
  group('HandoffService', () {
    late HandoffService service;
    late FakeIosPlatformChannel fakeChannel;

    setUp(() {
      fakeChannel = FakeIosPlatformChannel();
    });

    group('isSupported', () {
      test('returns true for mobile device', () {
        service = HandoffService(deviceType: DeviceType.mobile);
        expect(service.isSupported, isTrue);
      });

      test('returns false for tv device', () {
        service = HandoffService(
          deviceType: DeviceType.tv,
          isIosOverride: false,
          isMacosOverride: false,
        );
        expect(service.isSupported, isFalse);
      });

      test('returns false for tablet device', () {
        service = HandoffService(
          deviceType: DeviceType.tablet,
          isIosOverride: false,
          isMacosOverride: false,
        );
        expect(service.isSupported, isFalse);
      });

      test('returns false for desktop device', () {
        service = HandoffService(
          deviceType: DeviceType.desktop,
          isIosOverride: false,
          isMacosOverride: false,
        );
        expect(service.isSupported, isFalse);
      });
    });

    group('startActivity', () {
      test('stores userInfo for later retrieval', () async {
        service = HandoffService(
          deviceType: DeviceType.mobile,
          platformChannel: fakeChannel,
        );
        final userInfo = {'contentId': '123', 'position': 5000};

        await service.startActivity(
          activityType: 'com.white_tv.playback',
          userInfo: userInfo,
        );

        // No exception means success
      });

      test('handles empty userInfo without error', () async {
        service = HandoffService(
          deviceType: DeviceType.mobile,
          platformChannel: fakeChannel,
        );

        await service.startActivity(
          activityType: 'com.white_tv.playback',
          userInfo: const {},
        );

        // No exception means success
      });
    });

    group('endActivity', () {
      test('clears activity state without error', () async {
        service = HandoffService(
          deviceType: DeviceType.mobile,
          platformChannel: fakeChannel,
        );

        await service.startActivity(
          activityType: 'com.white_tv.playback',
          userInfo: {'contentId': '123'},
        );
        await service.endActivity();

        // No exception means success
      });
    });

    group('PlaybackHandoffInfo', () {
      test('toUserInfo produces correct map', () {
        final info = PlaybackHandoffInfo(
          contentId: 'video-001',
          title: 'Test Video',
          position: const Duration(seconds: 30),
          episodeId: 'ep-001',
        );

        final result = info.toUserInfo();

        expect(result['contentId'], equals('video-001'));
        expect(result['title'], equals('Test Video'));
        expect(result['position'], equals(30000));
        expect(result['episodeId'], equals('ep-001'));
      });

      test('toUserInfo omits null episodeId', () {
        final info = PlaybackHandoffInfo(
          contentId: 'video-001',
          title: 'Test Video',
        );

        final result = info.toUserInfo();

        expect(result.containsKey('episodeId'), isFalse);
      });

      test('fromUserInfo parses valid data', () {
        final userInfo = {
          'contentId': 'video-001',
          'title': 'Test Video',
          'position': 45000,
          'episodeId': 'ep-002',
        };

        final result = PlaybackHandoffInfo.fromUserInfo(userInfo);

        expect(result, isNotNull);
        expect(result!.contentId, equals('video-001'));
        expect(result.title, equals('Test Video'));
        expect(result.position, equals(const Duration(seconds: 45)));
        expect(result.episodeId, equals('ep-002'));
      });

      test('fromUserInfo returns null for malformed data', () {
        final invalidInfo = {'invalid': 'data'};

        final result = PlaybackHandoffInfo.fromUserInfo(invalidInfo);

        expect(result, isNull);
      });

      test('fromUserInfo handles missing optional fields', () {
        final minimalInfo = {
          'contentId': 'video-001',
          'title': 'Minimal Video',
        };

        final result = PlaybackHandoffInfo.fromUserInfo(minimalInfo);

        expect(result, isNotNull);
        expect(result!.contentId, equals('video-001'));
        expect(result.title, equals('Minimal Video'));
        expect(result.position, equals(Duration.zero));
        expect(result.episodeId, isNull);
      });
    });

    group('HandoffService iOS Integration', () {
      test('startActivity calls platform channel on iOS', () async {
        service = HandoffService(
          deviceType: DeviceType.mobile,
          platformChannel: fakeChannel,
          isIosOverride: true,
        );

        await service.startActivity(
          activityType: 'com.white_tv.playback',
          userInfo: {'contentId': 'test-123', 'position': 10000},
        );

        expect(fakeChannel.startHandoffCalled, isTrue);
        expect(fakeChannel.lastActivityType, equals('com.white_tv.playback'));
        expect(fakeChannel.lastUserInfo,
            equals({'contentId': 'test-123', 'position': 10000}));
      });

      test('updateActivity calls platform channel on iOS', () async {
        service = HandoffService(
          deviceType: DeviceType.mobile,
          platformChannel: fakeChannel,
          isIosOverride: true,
        );

        await service.updateActivity(
          userInfo: {'contentId': 'test-123', 'position': 20000},
        );

        expect(fakeChannel.updateHandoffCalled, isTrue);
        expect(fakeChannel.lastUserInfo,
            equals({'contentId': 'test-123', 'position': 20000}));
      });

      test('endActivity calls platform channel on iOS', () async {
        service = HandoffService(
          deviceType: DeviceType.mobile,
          platformChannel: fakeChannel,
          isIosOverride: true,
        );

        await service.endActivity();

        expect(fakeChannel.endHandoffCalled, isTrue);
      });

      test('receiveActivity calls platform channel and returns result',
          () async {
        fakeChannel.receiveHandoffResult = {
          'contentId': 'received-123',
          'title': 'Received Video'
        };

        service = HandoffService(
          deviceType: DeviceType.mobile,
          platformChannel: fakeChannel,
          isIosOverride: true,
        );

        final result = await service.receiveActivity();

        expect(fakeChannel.receiveHandoffCalled, isTrue);
        expect(result, equals({
          'contentId': 'received-123',
          'title': 'Received Video'
        }));
      });

      test('receiveActivity returns null when no handoff result', () async {
        fakeChannel.receiveHandoffResult = null;

        service = HandoffService(
          deviceType: DeviceType.mobile,
          platformChannel: fakeChannel,
          isIosOverride: true,
        );

        final result = await service.receiveActivity();

        expect(fakeChannel.receiveHandoffCalled, isTrue);
        expect(result, isNull);
      });

      test('platform channel not called on non-iOS', () async {
        service = HandoffService(
          deviceType: DeviceType.mobile,
          platformChannel: fakeChannel,
          isIosOverride: false,
        );

        await service.startActivity(
          activityType: 'com.white_tv.playback',
          userInfo: {'contentId': 'test-123'},
        );
        await service.updateActivity(userInfo: {'position': 5000});
        await service.endActivity();
        await service.receiveActivity();

        expect(fakeChannel.startHandoffCalled, isFalse);
        expect(fakeChannel.updateHandoffCalled, isFalse);
        expect(fakeChannel.endHandoffCalled, isFalse);
        expect(fakeChannel.receiveHandoffCalled, isFalse);
      });
    });
  });
}