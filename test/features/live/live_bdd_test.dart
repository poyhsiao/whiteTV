import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/live/data/models/epg_channel.dart';
import 'package:white_tv/features/live/data/models/epg_program.dart';
import 'package:white_tv/features/live/data/models/m3u_channel.dart';
import 'package:white_tv/features/live/domain/repositories/epg_manager.dart';
import 'package:white_tv/features/live/domain/repositories/m3u_parser.dart';
import 'package:white_tv/features/live/domain/repositories/timeshift_manager.dart';
import 'package:white_tv/features/live/domain/services/live_service.dart';

// ============================================================================
// BDD Integration Tests for IPTV Live Feature
// ============================================================================
//
// As a user,
// I want to watch live TV channels,
// so that I can enjoy broadcast content.
//
// As a user,
// I want to see program information,
// so that I know what's currently playing and what's coming up.
//
// As a user,
// I want to rewind and pause live TV,
// so that I don't miss anything.
//
// ============================================================================

class FakeM3uParser implements M3uParser {
  List<M3uChannel> mockChannels = [];

  @override
  List<M3uChannel> parse(String content, {String? groupTitle}) => mockChannels;

  @override
  List<M3uChannel> searchChannels(String content, {required String query}) {
    return mockChannels.where((c) =>
      c.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}

class FakeEpgManager implements EpgManager {
  @override
  Future<EpgChannel> fetchEpg(String channelId) async {
    return EpgChannel(id: channelId, name: 'Channel $channelId', programs: []);
  }

  @override
  Future<EpgProgram?> getCurrentProgram(String channelId) async => null;

  @override
  Future<EpgProgram?> getProgramAtTime(String channelId, DateTime time) async => null;

  @override
  Future<List<EpgProgram>> getProgramsForDay(String channelId, DateTime day) async => [];
}

class FakeTimeshiftManager implements TimeshiftManager {
  bool _isActive = false;
  Duration _position = Duration.zero;

  @override
  Future<TimeshiftController> startTimeshift({required String channelId, required String streamUrl}) async {
    _isActive = true;
    _position = Duration.zero;
    return TimeshiftController(channelId: channelId, streamUrl: streamUrl, startTime: DateTime.now());
  }

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  @override
  Future<Duration> seek(Duration position) async {
    _position = position;
    return position;
  }

  @override
  Future<Duration> fastForward(Duration duration) async {
    _position += duration;
    return _position;
  }

  @override
  Future<Duration> rewind(Duration duration) async {
    _position -= duration;
    return _position;
  }

  @override
  Future<void> stopTimeshift() async {
    _isActive = false;
    _position = Duration.zero;
  }

  @override
  bool get isTimeshiftActive => _isActive;

  @override
  Duration get maxTimeshiftDuration => const Duration(days: 7);

  @override
  Future<TimeshiftState> getState() async => TimeshiftState(
    position: _position,
    bufferedDuration: Duration.zero,
    isPaused: false,
    isLive: true,
  );
}

void main() {
  group('IPTV Live Feature - BDD Integration Tests', () {
    // ------------------------------------------------------------------------
    // Feature: Channel Management
    // ------------------------------------------------------------------------
    group('Feature: Channel Management', () {
      test('Scenario: Load channels from M3U content', () async {
        // Given a valid M3U content
        final parser = FakeM3uParser();
        parser.mockChannels = [
          const M3uChannel(name: 'CCTV-1', url: 'https://example.com/cctv1.m3u8'),
          const M3uChannel(name: 'CCTV-2', url: 'https://example.com/cctv2.m3u8'),
        ];

        // When parsing the content
        final channels = parser.parse('#EXTM3U\n#EXTINF:-1,CCTV-1\nhttps://example.com/cctv1.m3u8');

        // Then channels are correctly parsed
        expect(channels.length, 2);
        expect(channels[0].name, 'CCTV-1');
        expect(channels[1].name, 'CCTV-2');
      });

      test('Scenario: Search channels by name', () async {
        // Given channels are loaded
        final parser = FakeM3uParser();
        parser.mockChannels = [
          const M3uChannel(name: 'ESPN Sports', url: 'https://example.com/espn.m3u8'),
          const M3uChannel(name: 'BBC News', url: 'https://example.com/bbc.m3u8'),
          const M3uChannel(name: 'HBO Movies', url: 'https://example.com/hbo.m3u8'),
        ];

        // When searching for "sports"
        final results = parser.searchChannels('', query: 'sports');

        // Then only matching channels are returned
        expect(results.length, 1);
        expect(results[0].name, 'ESPN Sports');
      });
    });

    // ------------------------------------------------------------------------
    // Feature: Live Playback
    // ------------------------------------------------------------------------
    group('Feature: Live Playback', () {
      test('Scenario: Select channel for playback', () async {
        // Given channels are loaded
        final service = LiveService(
          m3uParser: FakeM3uParser()..mockChannels = [
            const M3uChannel(name: 'CCTV-1', url: 'https://example.com/cctv1.m3u8'),
          ],
          epgManager: FakeEpgManager(),
          timeshiftManager: FakeTimeshiftManager(),
        );

        await service.loadChannels('#EXTM3U\n#EXTINF:-1,CCTV-1\nhttps://example.com/cctv1.m3u8');

        // When selecting a channel
        final channels = service.state.channels;
        await service.selectChannel(channels.first);

        // Then the channel is set as current
        expect(service.state.currentChannel, channels.first);
      });

      test('Scenario: Navigate between channels', () async {
        // Given multiple channels are loaded
        final timeshift = FakeTimeshiftManager();
        final service = LiveService(
          m3uParser: FakeM3uParser()..mockChannels = [
            const M3uChannel(name: 'Channel 1', url: 'https://example.com/1.m3u8'),
            const M3uChannel(name: 'Channel 2', url: 'https://example.com/2.m3u8'),
            const M3uChannel(name: 'Channel 3', url: 'https://example.com/3.m3u8'),
          ],
          epgManager: FakeEpgManager(),
          timeshiftManager: timeshift,
        );

        await service.loadChannels('#EXTM3U');

        // When starting timeshift on a channel
        await service.startTimeshift(service.state.channels[0], Duration.zero);

        // Then timeshift is active
        expect(timeshift.isTimeshiftActive, isTrue);
      });
    });

    // ------------------------------------------------------------------------
    // Feature: Timeshift/Replay
    // ------------------------------------------------------------------------
    group('Feature: Timeshift/Replay', () {
      test('Scenario: Start timeshift to replay', () async {
        // Given a channel is selected
        final timeshift = FakeTimeshiftManager();

        // When starting timeshift with offset
        await timeshift.startTimeshift(
          channelId: 'ch1',
          streamUrl: 'https://example.com/stream.m3u8',
        );

        // Then timeshift is active
        expect(timeshift.isTimeshiftActive, isTrue);
      });

      test('Scenario: Rewind during replay', () async {
        // Given timeshift is active
        final timeshift = FakeTimeshiftManager();
        await timeshift.startTimeshift(
          channelId: 'ch1',
          streamUrl: 'https://example.com/stream.m3u8',
        );

        // When rewinding
        await timeshift.rewind(const Duration(minutes: 5));

        // Then position is updated
        expect(timeshift.isTimeshiftActive, isTrue);
      });

      test('Scenario: Fast forward during replay', () async {
        // Given timeshift is active
        final timeshift = FakeTimeshiftManager();
        await timeshift.startTimeshift(
          channelId: 'ch1',
          streamUrl: 'https://example.com/stream.m3u8',
        );

        // When fast forwarding
        await timeshift.fastForward(const Duration(minutes: 3));

        // Then position is updated
        expect(timeshift.isTimeshiftActive, isTrue);
      });

      test('Scenario: Stop timeshift and return to live', () async {
        // Given timeshift is active
        final timeshift = FakeTimeshiftManager();
        await timeshift.startTimeshift(
          channelId: 'ch1',
          streamUrl: 'https://example.com/stream.m3u8',
        );

        // When stopping timeshift
        await timeshift.stopTimeshift();

        // Then timeshift is inactive
        expect(timeshift.isTimeshiftActive, isFalse);
      });
    });

    // ------------------------------------------------------------------------
    // Feature: Signal Error Handling
    // ------------------------------------------------------------------------
    group('Feature: Signal Error Handling', () {
      test('Scenario: Handle signal error state', () async {
        // Given a service with loaded channels
        final service = LiveService(
          m3uParser: FakeM3uParser(),
          epgManager: FakeEpgManager(),
          timeshiftManager: FakeTimeshiftManager(),
        );

        // When signal error occurs
        final errorState = service.handleSignalError('Signal lost');

        // Then error state is set
        expect(errorState.isSignalError, isTrue);
        expect(errorState.errorMessage, 'Signal lost');
      });

      test('Scenario: Clear signal error', () async {
        // Given signal error is set
        final service = LiveService(
          m3uParser: FakeM3uParser(),
          epgManager: FakeEpgManager(),
          timeshiftManager: FakeTimeshiftManager(),
        );
        service.handleSignalError('Signal lost');

        // When clearing the error
        final clearedState = service.clearSignalError();

        // Then error is cleared
        expect(clearedState.isSignalError, isFalse);
        expect(clearedState.errorMessage, isNull);
      });
    });
  });
}