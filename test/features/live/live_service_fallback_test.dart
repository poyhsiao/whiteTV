import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/features/live/data/models/ipvt_channel.dart';
import 'package:white_tv/features/live/data/models/m3u_channel.dart';
import 'package:white_tv/features/live/domain/models/live_state.dart';
import 'package:white_tv/features/live/domain/repositories/epg_manager.dart';
import 'package:white_tv/features/live/domain/repositories/m3u_parser.dart';
import 'package:white_tv/features/live/domain/repositories/timeshift_manager.dart';
import 'package:white_tv/features/live/domain/services/live_service.dart';
import 'package:white_tv/features/live/data/models/epg_channel.dart';
import 'package:white_tv/features/live/data/models/epg_program.dart';
import 'package:white_tv/features/search/search_state.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';

// Minimal ApiClient implementation for testing
class FakeApiClient implements ApiClient {
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
  Future<VideoDetail> getVideoDetail(String videoId) async {
    return VideoDetail(
      id: videoId,
      title: 'Test Video',
      episodes: [],
    );
  }

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
  Future<Duration> rewind(Duration duration) async => -duration;

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
}

void main() {
  group('LiveService loadFromApi fallback', () {
    late LiveService service;
    late FakeApiClient fakeClient;
    late MockM3uParser mockParser;

    setUp(() {
      fakeClient = FakeApiClient();
      mockParser = MockM3uParser();
      service = LiveService(
        m3uParser: mockParser,
        epgManager: MockEpgManager(),
        timeshiftManager: MockTimeshiftManager(),
        apiClient: fakeClient,
      );
    });

    test('uses JSON channels when available', () async {
      fakeClient.mockChannels = [
        const IptvChannel(
          id: '1',
          name: 'Test Channel',
          logo: '',
          url: 'http://example.com/ch1.m3u8',
        ),
      ];

      final state = await service.loadFromApi();
      expect(state.status, LiveStatus.loaded);
      expect(state.channels.length, 1);
      expect(state.channels.first.name, 'Test Channel');
    });

    test('falls back to M3U when JSON is empty', () async {
      fakeClient.mockChannels = [];
      fakeClient.mockM3U = '''
#EXTM3U
#EXTINF:-1 tvg-name="M3U Channel",M3U Channel
http://example.com/ch.m3u8
''';
      mockParser.mockChannels = [
        const M3uChannel(name: 'M3U Channel', url: 'http://example.com/ch.m3u8'),
      ];

      final state = await service.loadFromApi();
      expect(state.status, LiveStatus.loaded);
      expect(state.channels.length, 1);
    });

    test('returns error when both JSON and M3U are empty', () async {
      fakeClient.mockChannels = [];
      fakeClient.mockM3U = null;

      final state = await service.loadFromApi();
      expect(state.status, LiveStatus.error);
    });

    test('API exception propagates when shouldFail is true', () async {
      fakeClient.shouldFail = true;

      // Note: Current LiveService.loadFromApi() does not catch exceptions
      // from getIptvChannels(). Exception propagates to caller.
      expect(
        () => service.loadFromApi(),
        throwsA(isA<Exception>()),
      );
    });
  });
}