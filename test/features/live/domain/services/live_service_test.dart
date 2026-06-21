import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/live/domain/services/live_service.dart';
import 'package:white_tv/features/live/domain/repositories/m3u_parser.dart';
import 'package:white_tv/features/live/domain/repositories/epg_manager.dart';
import 'package:white_tv/features/live/domain/repositories/timeshift_manager.dart';
import 'package:white_tv/features/live/data/models/m3u_channel.dart';
import 'package:white_tv/features/live/data/models/epg_channel.dart';
import 'package:white_tv/features/live/data/models/epg_program.dart';
import 'package:white_tv/features/live/domain/models/live_state.dart';

void main() {
  group('LiveService', () {
    late LiveService liveService;
    late MockM3uParser m3uParser;
    late MockEpgManager epgManager;
    late MockTimeshiftManager timeshiftManager;

    setUp(() {
      m3uParser = MockM3uParser();
      epgManager = MockEpgManager();
      timeshiftManager = MockTimeshiftManager();
      liveService = LiveService(
        m3uParser: m3uParser,
        epgManager: epgManager,
        timeshiftManager: timeshiftManager,
      );
    });

    test('loads channels from m3u content', () async {
      const m3uContent = '''#EXTM3U
#EXTINF:-1 tvg-name="Channel 1",Channel 1
https://example.com/stream1.m3u8
''';
      m3uParser.mockChannels = [
        const M3uChannel(name: 'Channel 1', url: 'https://example.com/stream1.m3u8'),
      ];

      final state = await liveService.loadChannels(m3uContent);

      expect(state.channels.length, 1);
      expect(state.channels.first.name, 'Channel 1');
      expect(state.status, LiveStatus.loaded);
    });

    test('selects channel for playback', () async {
      const channel = M3uChannel(name: 'Test', url: 'https://example.com/test.m3u8');

      final state = await liveService.selectChannel(channel);

      expect(state.currentChannel, channel);
      expect(state.status, LiveStatus.loaded);
    });

    test('enters timeshift mode when replay is requested', () async {
      const channel = M3uChannel(name: 'Test', url: 'https://example.com/test.m3u8');

      final state = await liveService.startTimeshift(channel, const Duration(minutes: -10));

      expect(state.status, LiveStatus.timeshift);
    });

    test('exits timeshift mode and returns to live', () async {
      const channel = M3uChannel(name: 'Test', url: 'https://example.com/test.m3u8');

      await liveService.startTimeshift(channel, const Duration(minutes: -10));
      final state = await liveService.stopTimeshift();

      expect(state.status, LiveStatus.loaded);
      expect(state.timeshiftPosition, isNull);
    });

    test('handles signal error state', () async {
      const channel = M3uChannel(name: 'Test', url: 'https://example.com/test.m3u8');

      await liveService.selectChannel(channel);
      final errorState = liveService.handleSignalError('Signal lost');

      expect(errorState.isSignalError, isTrue);
      expect(errorState.errorMessage, 'Signal lost');
    });

    test('clears signal error and continues', () async {
      const channel = M3uChannel(name: 'Test', url: 'https://example.com/test.m3u8');

      await liveService.selectChannel(channel);
      liveService.handleSignalError('Signal lost');
      final state = liveService.clearSignalError();

      expect(state.isSignalError, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('searches channels by query', () async {
      const m3uContent = '''#EXTM3U
#EXTINF:-1 tvg-name="ESPN Sports",Sports Channel
https://example.com/sports.m3u8
#EXTINF:-1 tvg-name="BBC News",News Channel
https://example.com/news.m3u8
''';
      m3uParser.mockChannels = [
        const M3uChannel(name: 'ESPN Sports', url: 'https://example.com/sports.m3u8'),
        const M3uChannel(name: 'BBC News', url: 'https://example.com/news.m3u8'),
      ];

      await liveService.loadChannels(m3uContent);
      final results = liveService.searchChannels('sports');

      expect(results.length, 1);
      expect(results.first.name, 'ESPN Sports');
    });
  });
}

class MockM3uParser implements M3uParser {
  List<M3uChannel> mockChannels = [];

  @override
  List<M3uChannel> parse(String content, {String? groupTitle}) => mockChannels;

  @override
  List<M3uChannel> searchChannels(String content, {required String query}) {
    final queryLower = query.toLowerCase();
    return mockChannels.where((channel) {
      return channel.name.toLowerCase().contains(queryLower) ||
          (channel.groupTitle?.toLowerCase().contains(queryLower) ?? false);
    }).toList();
  }
}

class MockEpgManager implements EpgManager {
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

class MockTimeshiftManager implements TimeshiftManager {
  @override
  Future<TimeshiftController> startTimeshift({required String channelId, required String streamUrl}) async {
    return TimeshiftController(channelId: channelId, streamUrl: streamUrl, startTime: DateTime.now());
  }

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  @override
  Future<Duration> seek(Duration position) async => position;

  @override
  Future<Duration> fastForward(Duration duration) async => duration;

  @override
  Future<Duration> rewind(Duration duration) async => Duration.zero - duration;

  @override
  Future<void> stopTimeshift() async {}

  @override
  bool get isTimeshiftActive => false;

  @override
  Duration get maxTimeshiftDuration => const Duration(days: 7);

  @override
  Future<TimeshiftState> getState() async => const TimeshiftState(
    position: Duration.zero,
    bufferedDuration: Duration.zero,
    isPaused: false,
    isLive: true,
  );

  @override
  Future<bool> isServiceSideSupported(String channelId) async => false;

  @override
  Future<String?> getServiceSideStream(
    String channelId,
    Duration startOffset,
    Duration endOffset,
  ) async => null;

  @override
  Future<void> startClientBuffer(String channelId, Duration duration) async {}

  @override
  Future<void> stopClientBuffer() async {}
}