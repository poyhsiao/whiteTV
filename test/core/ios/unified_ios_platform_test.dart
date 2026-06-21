// test/core/ios/unified_ios_platform_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/ios/unified_ios_platform.dart';
import 'package:white_tv/core/handoff/handoff_service.dart';
import 'mock_ios_platform_channel.dart';

void main() {
  late MockIosPlatformChannel mockChannel;

  setUp(() {
    mockChannel = MockIosPlatformChannel();
    UnifiedIosPlatform.setPlatformChannel(mockChannel);
  });

  tearDown(() {
    UnifiedIosPlatform.resetPlatformChannel();
  });

  group('UnifiedIosPlatform', () {
    // ==================== Static Getters ====================

    test('isNativeSupported equals isIos || isMacos', () {
      expect(
        UnifiedIosPlatform.isNativeSupported,
        equals(UnifiedIosPlatform.isIos || UnifiedIosPlatform.isMacos),
      );
    });

    // ==================== startPlaybackHandoff ====================

    group('startPlaybackHandoff', () {
      test('calls channel with correct activity type and user info', () async {
        final result = await UnifiedIosPlatform.startPlaybackHandoff(
          contentId: 'movie-123',
          title: 'Test Movie',
          position: const Duration(seconds: 120),
          episodeId: 'ep-1',
        );

        expect(result, isTrue);
        expect(mockChannel.startHandoffCalled, isTrue);
        expect(mockChannel.lastActivityType, 'com.white_tv.playback');
        expect(mockChannel.lastUserInfo, {
          'contentId': 'movie-123',
          'title': 'Test Movie',
          'position': 120000,
          'episodeId': 'ep-1',
        });
      });

      test('calls channel without optional episodeId', () async {
        await UnifiedIosPlatform.startPlaybackHandoff(
          contentId: 'movie-456',
          title: 'Another Movie',
          position: Duration.zero,
        );

        expect(mockChannel.lastActivityType, 'com.white_tv.playback');
        expect(mockChannel.lastUserInfo, {
          'contentId': 'movie-456',
          'title': 'Another Movie',
          'position': 0,
        });
        expect(mockChannel.lastUserInfo!.containsKey('episodeId'), isFalse);
      });

      test('returns false when channel returns false', () async {
        mockChannel.shouldStartHandoffSucceed = false;

        final result = await UnifiedIosPlatform.startPlaybackHandoff(
          contentId: 'movie-123',
          title: 'Test',
        );

        expect(result, isFalse);
      });
    });

    // ==================== updatePlaybackHandoff ====================

    group('updatePlaybackHandoff', () {
      test('calls channel with correct user info', () async {
        await UnifiedIosPlatform.updatePlaybackHandoff(
          contentId: 'movie-123',
          position: const Duration(seconds: 300),
        );

        expect(mockChannel.updateHandoffCalled, isTrue);
        expect(mockChannel.lastUpdateInfo, {
          'contentId': 'movie-123',
          'position': 300000,
        });
      });

      test('uses zero position when not specified', () async {
        await UnifiedIosPlatform.updatePlaybackHandoff(
          contentId: 'movie-123',
        );

        expect(mockChannel.lastUpdateInfo, {
          'contentId': 'movie-123',
          'position': 0,
        });
      });
    });

    // ==================== endPlaybackHandoff ====================

    group('endPlaybackHandoff', () {
      test('calls channel endHandoff', () async {
        await UnifiedIosPlatform.endPlaybackHandoff();

        expect(mockChannel.endHandoffCalled, isTrue);
      });
    });

    // ==================== getPendingPlayback ====================

    group('getPendingPlayback', () {
      test('returns PlaybackHandoffInfo when channel returns data', () async {
        mockChannel.receiveHandoffResult = {
          'contentId': 'movie-789',
          'title': 'Resumed Movie',
          'position': 60000,
          'episodeId': 'ep-5',
        };

        final result = await UnifiedIosPlatform.getPendingPlayback();

        expect(result, isNotNull);
        expect(result!.contentId, 'movie-789');
        expect(result.title, 'Resumed Movie');
        expect(result.position, const Duration(seconds: 60));
        expect(result.episodeId, 'ep-5');
      });

      test('returns null when channel returns null', () async {
        mockChannel.receiveHandoffResult = null;

        final result = await UnifiedIosPlatform.getPendingPlayback();

        expect(result, isNull);
      });

      test('returns null when data has invalid contentId type', () async {
        mockChannel.receiveHandoffResult = {
          'contentId': 123, // should be String
          'title': 'Test',
          'position': 0,
        };

        final result = await UnifiedIosPlatform.getPendingPlayback();

        expect(result, isNull);
      });

      test('returns null when data has invalid title type', () async {
        mockChannel.receiveHandoffResult = {
          'contentId': 'movie-123',
          'title': 456, // should be String
          'position': 0,
        };

        final result = await UnifiedIosPlatform.getPendingPlayback();

        expect(result, isNull);
      });

      test('handles null position gracefully', () async {
        mockChannel.receiveHandoffResult = {
          'contentId': 'movie-123',
          'title': 'Test',
          'position': null,
        };

        final result = await UnifiedIosPlatform.getPendingPlayback();

        expect(result, isNotNull);
        expect(result!.position, Duration.zero);
      });

      test('handles missing episodeId', () async {
        mockChannel.receiveHandoffResult = {
          'contentId': 'movie-123',
          'title': 'Test',
          'position': 30000,
        };

        final result = await UnifiedIosPlatform.getPendingPlayback();

        expect(result, isNotNull);
        expect(result!.episodeId, isNull);
      });
    });

    // ==================== startPiP ====================

    group('startPiP', () {
      test('calls channel with route', () async {
        final result = await UnifiedIosPlatform.startPiP('/player/123');

        expect(result, isTrue);
        expect(mockChannel.startPiPCalled, isTrue);
        expect(mockChannel.lastPiPRoute, '/player/123');
      });

      test('returns false when channel returns false', () async {
        mockChannel.shouldStartPiPSucceed = false;

        final result = await UnifiedIosPlatform.startPiP('/player/123');

        expect(result, isFalse);
      });
    });

    // ==================== stopPiP ====================

    group('stopPiP', () {
      test('calls channel stopPiP', () async {
        await UnifiedIosPlatform.stopPiP();

        expect(mockChannel.stopPiPCalled, isTrue);
      });
    });

    // ==================== isPiPSupported ====================

    group('isPiPSupported', () {
      test('returns true when channel returns true', () async {
        mockChannel.piPSupportedResult = true;

        final result = await UnifiedIosPlatform.isPiPSupported();

        expect(result, isTrue);
        expect(mockChannel.isPiPSupportedCalled, isTrue);
      });

      test('returns false when channel returns false', () async {
        mockChannel.piPSupportedResult = false;

        final result = await UnifiedIosPlatform.isPiPSupported();

        expect(result, isFalse);
      });
    });

    // ==================== Integration Tests ====================

    group('integration', () {
      test('can perform full handoff lifecycle', () async {
        // Start handoff
        await UnifiedIosPlatform.startPlaybackHandoff(
          contentId: 'movie-123',
          title: 'Test Movie',
        );
        expect(mockChannel.startHandoffCallCount, 1);

        // Update handoff
        await UnifiedIosPlatform.updatePlaybackHandoff(
          contentId: 'movie-123',
          position: const Duration(seconds: 60),
        );
        expect(mockChannel.updateHandoffCallCount, 1);

        // End handoff
        await UnifiedIosPlatform.endPlaybackHandoff();
        expect(mockChannel.endHandoffCallCount, 1);
      });

      test('can perform full PiP lifecycle', () async {
        // Check support
        await UnifiedIosPlatform.isPiPSupported();
        expect(mockChannel.isPiPSupportedCallCount, 1);

        // Start PiP
        await UnifiedIosPlatform.startPiP('/player/123');
        expect(mockChannel.startPiPCallCount, 1);

        // Stop PiP
        await UnifiedIosPlatform.stopPiP();
        expect(mockChannel.stopPiPCallCount, 1);
      });
    });
  });

  group('PlaybackHandoffInfo', () {
    test('can be constructed with all fields', () {
      const info = PlaybackHandoffInfo(
        contentId: 'test-id',
        title: 'Test Title',
        position: Duration(seconds: 120),
        episodeId: 'ep-1',
      );
      expect(info.contentId, 'test-id');
      expect(info.title, 'Test Title');
      expect(info.position, const Duration(seconds: 120));
      expect(info.episodeId, 'ep-1');
    });

    test('position defaults to zero', () {
      const info = PlaybackHandoffInfo(
        contentId: 'test-id',
        title: 'Test Title',
      );
      expect(info.position, Duration.zero);
      expect(info.episodeId, isNull);
    });

    test('equality works correctly', () {
      const info1 = PlaybackHandoffInfo(
        contentId: 'test-id',
        title: 'Test Title',
        position: Duration(seconds: 120),
        episodeId: 'ep-1',
      );
      const info2 = PlaybackHandoffInfo(
        contentId: 'test-id',
        title: 'Test Title',
        position: Duration(seconds: 120),
        episodeId: 'ep-1',
      );
      const info3 = PlaybackHandoffInfo(
        contentId: 'different-id',
        title: 'Test Title',
        position: Duration(seconds: 120),
        episodeId: 'ep-1',
      );

      expect(info1, equals(info2));
      expect(info1, isNot(equals(info3)));
    });

    test('hashCode is consistent with equality', () {
      const info1 = PlaybackHandoffInfo(
        contentId: 'test-id',
        title: 'Test Title',
        position: Duration(seconds: 120),
        episodeId: 'ep-1',
      );
      const info2 = PlaybackHandoffInfo(
        contentId: 'test-id',
        title: 'Test Title',
        position: Duration(seconds: 120),
        episodeId: 'ep-1',
      );

      expect(info1.hashCode, equals(info2.hashCode));
    });
  });
}
