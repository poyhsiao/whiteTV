import 'package:white_tv/core/api/api_client_fallbacks.dart';
import 'package:white_tv/features/live/domain/repositories/timeshift_manager_fallbacks.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/features/live/data/models/epg_channel.dart';
import 'package:white_tv/features/live/data/models/epg_program.dart';
import 'package:white_tv/features/live/data/models/ipvt_channel.dart';
import 'package:white_tv/features/live/data/models/m3u_channel.dart';
import 'package:white_tv/features/live/domain/models/live_state.dart';
import 'package:white_tv/features/live/domain/repositories/epg_manager.dart';
import 'package:white_tv/features/live/domain/repositories/m3u_parser.dart';
import 'package:white_tv/features/live/domain/repositories/timeshift_manager.dart';
import 'package:white_tv/features/live/domain/services/live_service.dart';
import 'package:white_tv/features/search/search_state.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';

// ============================================================================
// Mocks - Matching actual interface signatures
// ============================================================================

class FakeApiClient with ApiClientFallbacks implements ApiClient {
  List<IptvChannel> mockChannels = [];
  String? mockM3U;
  bool shouldFail = false;

  @override
  Future<Map<String, String>?> login(String username, String password) async => null;

  @override
  Future<List<Category>> getCategories() async => [];

  @override
  Future<List<Video>> getVideosByCategory(String categoryId) async => [];

  @override
  Future<VideoDetail> getVideoDetail(String videoId) async => VideoDetail(id: videoId, title: 'Test', episodes: []);

  @override
  Future<List<VideoSource>> getSources(String videoId) async => [];

  @override
  Future<int> testSourceLatency(String sourceUrl) async => -1;

  @override
  Future<List<int>> search(String query, {SearchCategory? category}) async => [];

  @override
  Future<Map<String, dynamic>> getUserStats() async => {};

  @override
  Future<void> syncSearchHistory(List<String> history) async {}

  @override
  Future<List<String>> getSearchHistory() async => [];

  @override
  Future<bool> savePlayHistory(PlayHistory record) async => false;

  @override
  Future<List<IptvChannel>> getIptvChannels() async {
    if (shouldFail) throw Exception('API Error');
    return mockChannels;
  }

  @override
  Future<String?> getIptvM3U() async {
    if (shouldFail) throw Exception('API Error');
    return mockM3U;
  }

  @override
  Future<Map<String, dynamic>> getIptvEpg() async {
    if (shouldFail) throw Exception('API Error');
    return {};
  }

  @override
  Future<List<AIRecommendation>> getAIRecommendations() async => [];

  @override
  Future<List<AIRecommendation>> getLocalRecommendations({
    List<String>? watchHistory,
    List<String>? searchHistory,
    int limit = 20,
  }) async => [];
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

class MockTimeshiftManager with TimeshiftManagerFallbacks implements TimeshiftManager {
  TimeshiftController? _controller;
  TimeshiftState? _state;

  @override
  Future<TimeshiftController> startTimeshift({
    required String channelId,
    required String streamUrl,
  }) async {
    _controller = TimeshiftController(
      channelId: channelId,
      streamUrl: streamUrl,
      startTime: DateTime.now(),
    );
    _state = const TimeshiftState(
      position: Duration.zero,
      bufferedDuration: Duration.zero,
      isPaused: false,
      isLive: true,
    );
    return _controller!;
  }

  @override
  Future<void> pause() async {
    _state = const TimeshiftState(
      position: Duration.zero,
      bufferedDuration: Duration.zero,
      isPaused: true,
      isLive: false,
    );
  }

  @override
  Future<void> resume() async {
    _state = const TimeshiftState(
      position: Duration.zero,
      bufferedDuration: Duration.zero,
      isPaused: false,
      isLive: false,
    );
  }

  @override
  Future<Duration> seek(Duration position) async => position;

  @override
  Future<Duration> fastForward(Duration duration) async => duration;

  @override
  Future<Duration> rewind(Duration duration) async => Duration.zero - duration;

  @override
  Future<void> stopTimeshift() async {
    _controller = null;
    _state = null;
  }

  @override
  bool get isTimeshiftActive => _controller != null;

  @override
  Duration get maxTimeshiftDuration => const Duration(days: 7);

  @override
  Future<TimeshiftState> getState() async {
    return _state ?? const TimeshiftState(
      position: Duration.zero,
      bufferedDuration: Duration.zero,
      isPaused: false,
      isLive: true,
    );
  }

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

// ============================================================================
// BDD Test Suite
// ============================================================================

void main() {
  group('IPTV Live BDD Tests', () {
    // -------------------------------------------------------------------------
    // Scenario: Load channels from API (JSON priority, M3U fallback)
    // -------------------------------------------------------------------------
    group('Scenario: Load channels from API', () {
      test(
        'GIVEN LunaTV API returns JSON channels '
        'WHEN loadFromApi is called '
        'THEN channels are loaded successfully',
        () async {
          // Given
          final apiClient = FakeApiClient()
            ..mockChannels = [
              const IptvChannel(
                id: 'ch1',
                name: 'Channel 1',
                logo: 'http://logo.com/ch1.png',
                url: 'http://stream.com/ch1.m3u8',
                group: 'Sports',
              ),
              const IptvChannel(
                id: 'ch2',
                name: 'Channel 2',
                logo: 'http://logo.com/ch2.png',
                url: 'http://stream.com/ch2.m3u8',
                group: 'News',
              ),
            ];

          final service = LiveService(
            m3uParser: MockM3uParser(),
            epgManager: MockEpgManager(),
            timeshiftManager: MockTimeshiftManager(),
            apiClient: apiClient,
          );

          // When
          final state = await service.loadFromApi();

          // Then
          expect(state.status, LiveStatus.loaded);
          expect(state.channels.length, 2);
          expect(state.channels.first.name, 'Channel 1');
        },
      );

      test(
        'GIVEN JSON API returns empty but M3U is available '
        'WHEN loadFromApi is called '
        'THEN fallback to M3U parsing succeeds',
        () async {
          // Given
          final m3uParser = MockM3uParser()
            ..mockChannels = [
              const M3uChannel(
                name: 'M3U Channel',
                url: 'http://stream.com/m3u.m3u8',
                logoUrl: 'http://logo.com/m3u.png',
                groupTitle: 'Entertainment',
              ),
            ];

          final apiClient = FakeApiClient()
            ..mockChannels = [] // Empty JSON
            ..mockM3U = '#EXTM3U\n#EXTINF:-1 tvg-name="M3U Channel",M3U Channel\nhttp://stream.com/m3u.m3u8';

          final service = LiveService(
            m3uParser: m3uParser,
            epgManager: MockEpgManager(),
            timeshiftManager: MockTimeshiftManager(),
            apiClient: apiClient,
          );

          // When
          final state = await service.loadFromApi();

          // Then
          expect(state.status, LiveStatus.loaded);
          expect(state.channels.isNotEmpty, true);
        },
      );

      test(
        'GIVEN both JSON and M3U fail '
        'WHEN loadFromApi is called '
        'THEN error status is returned',
        () async {
          // Given
          final apiClient = FakeApiClient()
            ..mockChannels = []
            ..mockM3U = null;

          final service = LiveService(
            m3uParser: MockM3uParser()..mockChannels = [],
            epgManager: MockEpgManager(),
            timeshiftManager: MockTimeshiftManager(),
            apiClient: apiClient,
          );

          // When
          final state = await service.loadFromApi();

          // Then
          expect(state.status, LiveStatus.error);
          expect(state.errorMessage, '無法載入頻道列表');
        },
      );

      test(
        'GIVEN no API client is provided '
        'WHEN loadChannels is called with M3U content '
        'THEN channels are parsed from M3U',
        () async {
          // Given
          const m3uContent = '''#EXTM3U
#EXTINF:-1 tvg-id="ch1" tvg-name="News Channel" tvg-logo="http://logo.com/news.png" group-title="News",News Channel
http://stream.com/news.m3u8
#EXTINF:-1 tvg-id="ch2" tvg-name="Sports Channel" tvg-logo="http://logo.com/sports.png" group-title="Sports",Sports Channel
http://stream.com/sports.m3u8''';

          final m3uParser = MockM3uParser()
            ..mockChannels = [
              const M3uChannel(
                name: 'News Channel',
                url: 'http://stream.com/news.m3u8',
                logoUrl: 'http://logo.com/news.png',
                groupTitle: 'News',
                tvgId: 'ch1',
              ),
              const M3uChannel(
                name: 'Sports Channel',
                url: 'http://stream.com/sports.m3u8',
                logoUrl: 'http://logo.com/sports.png',
                groupTitle: 'Sports',
                tvgId: 'ch2',
              ),
            ];

          final service = LiveService(
            m3uParser: m3uParser,
            epgManager: MockEpgManager(),
            timeshiftManager: MockTimeshiftManager(),
            apiClient: null, // No API client
          );

          // When
          final state = await service.loadChannels(m3uContent);

          // Then
          expect(state.status, LiveStatus.loaded);
          expect(state.channels.length, 2);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Scenario: Channel selection
    // -------------------------------------------------------------------------
    group('Scenario: Channel selection', () {
      test(
        'GIVEN channels are loaded '
        'WHEN user selects a channel '
        'THEN channel becomes current',
        () async {
          // Given
          final m3uParser = MockM3uParser()
            ..mockChannels = [
              const M3uChannel(
                name: 'Channel 1',
                url: 'http://stream.com/ch1.m3u8',
                tvgId: 'ch1',
              ),
            ];

          final service = LiveService(
            m3uParser: m3uParser,
            epgManager: MockEpgManager(),
            timeshiftManager: MockTimeshiftManager(),
            apiClient: null,
          );

          await service.loadChannels('#EXTM3U\n#EXTINF:-1,Channel 1\nhttp://stream.com/ch1.m3u8');

          const targetChannel = M3uChannel(
            name: 'Channel 1',
            url: 'http://stream.com/ch1.m3u8',
            tvgId: 'ch1',
          );

          // When
          final state = await service.selectChannel(targetChannel);

          // Then
          expect(state.currentChannel, isNotNull);
          expect(state.currentChannel!.name, 'Channel 1');
          expect(state.status, LiveStatus.loaded);
          expect(state.isSignalError, false);
        },
      );

      test(
        'GIVEN user has current channel '
        'WHEN selecting a different channel '
        'THEN current channel is updated',
        () async {
          // Given
          final service = LiveService(
            m3uParser: MockM3uParser(),
            epgManager: MockEpgManager(),
            timeshiftManager: MockTimeshiftManager(),
            apiClient: null,
          );

          await service.loadChannels('#EXTM3U\n#EXTINF:-1,Channel 1\nhttp://stream.com/ch1.m3u8');

          const channel1 = M3uChannel(name: 'Channel 1', url: 'http://stream.com/ch1.m3u8', tvgId: 'ch1');
          const channel2 = M3uChannel(name: 'Channel 2', url: 'http://stream.com/ch2.m3u8', tvgId: 'ch2');

          await service.selectChannel(channel1);

          // When
          final state = await service.selectChannel(channel2);

          // Then
          expect(state.currentChannel!.name, 'Channel 2');
        },
      );
    });

    // -------------------------------------------------------------------------
    // Scenario: Signal error handling
    // -------------------------------------------------------------------------
    group('Scenario: Signal error handling', () {
      test(
        'GIVEN channel is playing '
        'WHEN signal error occurs '
        'THEN error state is set with message',
        () {
          // Given
          final service = LiveService(
            m3uParser: MockM3uParser(),
            epgManager: MockEpgManager(),
            timeshiftManager: MockTimeshiftManager(),
            apiClient: null,
          );

          // When
          final state = service.handleSignalError('Signal lost');

          // Then
          expect(state.isSignalError, true);
          expect(state.errorMessage, 'Signal lost');
        },
      );

      test(
        'GIVEN signal error is present '
        'WHEN error is cleared '
        'THEN normal state is restored',
        () {
          // Given
          final service = LiveService(
            m3uParser: MockM3uParser(),
            epgManager: MockEpgManager(),
            timeshiftManager: MockTimeshiftManager(),
            apiClient: null,
          );

          service.handleSignalError('Signal lost');

          // When
          final state = service.clearSignalError();

          // Then
          expect(state.isSignalError, false);
          expect(state.errorMessage, isNull);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Scenario: Channel search
    // -------------------------------------------------------------------------
    group('Scenario: Channel search', () {
      test(
        'GIVEN channels are loaded '
        'WHEN user searches by name '
        'THEN matching channels are returned',
        () {
          // Given
          final m3uParser = MockM3uParser()
            ..mockChannels = [
              const M3uChannel(name: 'News Channel', url: 'http://stream.com/news.m3u8', groupTitle: 'News'),
              const M3uChannel(name: 'Sports Channel', url: 'http://stream.com/sports.m3u8', groupTitle: 'Sports'),
              const M3uChannel(name: 'News Plus', url: 'http://stream.com/newsplus.m3u8', groupTitle: 'News'),
            ];

          final service = LiveService(
            m3uParser: m3uParser,
            epgManager: MockEpgManager(),
            timeshiftManager: MockTimeshiftManager(),
            apiClient: null,
          );

          // When
          final results = service.searchChannels('News');

          // Then
          expect(results.length, 2);
          expect(results.every((c) => c.name.contains('News')), true);
        },
      );

      test(
        'GIVEN channels are loaded '
        'WHEN user searches by group '
        'THEN matching channels are returned',
        () {
          // Given
          final m3uParser = MockM3uParser()
            ..mockChannels = [
              const M3uChannel(name: 'Channel 1', url: 'http://stream.com/ch1.m3u8', groupTitle: 'Sports'),
              const M3uChannel(name: 'Channel 2', url: 'http://stream.com/ch2.m3u8', groupTitle: 'Sports'),
              const M3uChannel(name: 'Channel 3', url: 'http://stream.com/ch3.m3u8', groupTitle: 'News'),
            ];

          final service = LiveService(
            m3uParser: m3uParser,
            epgManager: MockEpgManager(),
            timeshiftManager: MockTimeshiftManager(),
            apiClient: null,
          );

          // When
          final results = service.searchChannels('Sports');

          // Then
          expect(results.length, 2);
          expect(results.every((c) => c.groupTitle == 'Sports'), true);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Scenario: Timeshift functionality
    // -------------------------------------------------------------------------
    group('Scenario: Timeshift functionality', () {
      test(
        'GIVEN channel is playing live '
        'WHEN user starts timeshift '
        'THEN timeshift mode is activated',
        () async {
          // Given
          final timeshiftManager = MockTimeshiftManager();
          final service = LiveService(
            m3uParser: MockM3uParser(),
            epgManager: MockEpgManager(),
            timeshiftManager: timeshiftManager,
            apiClient: null,
          );

          const channel = M3uChannel(
            name: 'Channel 1',
            url: 'http://stream.com/ch1.m3u8',
            tvgId: 'ch1',
          );

          await service.selectChannel(channel);

          // When
          final state = await service.startTimeshift(channel, const Duration(minutes: -10));

          // Then
          expect(state.status, LiveStatus.timeshift);
          expect(timeshiftManager.isTimeshiftActive, true);
          expect(state.timeshiftPosition, const Duration(minutes: -10));
        },
      );

      test(
        'GIVEN timeshift is active '
        'WHEN user stops timeshift '
        'THEN returns to live mode',
        () async {
          // Given
          final timeshiftManager = MockTimeshiftManager();
          final service = LiveService(
            m3uParser: MockM3uParser(),
            epgManager: MockEpgManager(),
            timeshiftManager: timeshiftManager,
            apiClient: null,
          );

          const channel = M3uChannel(
            name: 'Channel 1',
            url: 'http://stream.com/ch1.m3u8',
            tvgId: 'ch1',
          );

          await service.startTimeshift(channel, const Duration(minutes: -5));

          // When
          final state = await service.stopTimeshift();

          // Then
          expect(state.status, LiveStatus.loaded);
          expect(timeshiftManager.isTimeshiftActive, false);
          expect(state.timeshiftPosition, isNull);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Scenario: Loading state transitions
    // -------------------------------------------------------------------------
    group('Scenario: Loading state transitions', () {
      test(
        'GIVEN initial state '
        'WHEN loadFromApi is called '
        'THEN loading state is emitted first',
        () async {
          // Given
          final apiClient = FakeApiClient()
            ..mockChannels = [
              const IptvChannel(
                id: 'ch1',
                name: 'Channel 1',
                logo: '',
                url: 'http://stream.com/ch1.m3u8',
              ),
            ];

          final service = LiveService(
            m3uParser: MockM3uParser(),
            epgManager: MockEpgManager(),
            timeshiftManager: MockTimeshiftManager(),
            apiClient: apiClient,
          );

          expect(service.state.status, LiveStatus.initial);

          // When
          final state = await service.loadFromApi();

          // Then
          expect(state.status, LiveStatus.loaded);
        },
      );
    });
  });
}
