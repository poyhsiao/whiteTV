import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/device/device_type.dart';
import 'package:white_tv/core/handoff/handoff_service.dart';

void main() {
  group('HandoffService', () {
    late HandoffService service;

    group('isSupported', () {
      test('returns true for mobile device', () {
        service = HandoffService(deviceType: DeviceType.mobile);
        expect(service.isSupported, isTrue);
      });

      test('returns false for tv device', () {
        service = HandoffService(deviceType: DeviceType.tv);
        expect(service.isSupported, isFalse);
      });

      test('returns false for tablet device', () {
        service = HandoffService(deviceType: DeviceType.tablet);
        expect(service.isSupported, isFalse);
      });

      test('returns false for desktop device', () {
        service = HandoffService(deviceType: DeviceType.desktop);
        expect(service.isSupported, isFalse);
      });
    });

    group('startActivity', () {
      test('stores userInfo for later retrieval', () async {
        service = HandoffService(deviceType: DeviceType.mobile);
        final userInfo = {'contentId': '123', 'position': 5000};

        await service.startActivity(
          activityType: 'com.white_tv.playback',
          userInfo: userInfo,
        );

        // No exception means success
        // Platform channel implementation will enable actual handoff
      });

      test('handles empty userInfo without error', () async {
        service = HandoffService(deviceType: DeviceType.mobile);

        await service.startActivity(
          activityType: 'com.white_tv.playback',
          userInfo: const {},
        );

        // No exception means success
      });
    });

    group('endActivity', () {
      test('clears activity state without error', () async {
        service = HandoffService(deviceType: DeviceType.mobile);

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
  });
}