import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/core/api/api_client_fallbacks.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/features/live/domain/services/timeshift_service_adapter.dart';
import 'package:white_tv/features/search/search_state.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/live/data/models/ipvt_channel.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';

class FakeApiClient with ApiClientFallbacks implements ApiClient {
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
  Future<List<Video>> search(String query, {SearchCategory? category}) async => [];
  @override
  Future<Map<String, dynamic>> getUserStats() async => {};
  @override
  Future<void> syncSearchHistory(List<String> history) async {}
  @override
  Future<List<String>> getSearchHistory() async => [];
  @override
  Future<bool> savePlayHistory(PlayHistory record) async => true;
  @override
  Future<List<IptvChannel>> getIptvChannels() async => [];
  @override
  Future<String?> getIptvM3U() async => null;
  @override
  Future<Map<String, dynamic>> getIptvEpg() async => {};
  @override
  Future<List<AIRecommendation>> getAIRecommendations() async => [];
  @override
  Future<List<AIRecommendation>> getLocalRecommendations({List<String>? watchHistory, List<String>? searchHistory, int limit = 20}) async => [];
  @override
  Future<List<YoutubeVideo>> getYoutubeRecommend() async => [];
  @override
  Future<List<YoutubeVideo>> getYoutubeList(String categoryId, {String? page}) async => [];
  @override
  Future<List<YoutubeCategory>> getYoutubeCategories() async => [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TimeshiftServiceAdapter', () {
    late TimeshiftServiceAdapter adapter;
    late FakeApiClient fakeClient;

    setUp(() {
      fakeClient = FakeApiClient();
      adapter = TimeshiftServiceAdapter(fakeClient);
    });

    group('checkSupport', () {
      test('returns false for empty channelId', () async {
        final result = await adapter.checkSupport('');
        expect(result, isFalse);
      });

      test('returns false for stub implementation', () async {
        final result = await adapter.checkSupport('channel_123');
        expect(result, isFalse);
      });
    });

    group('getStream', () {
      test('returns null for empty channelId', () async {
        final result = await adapter.getStream('', const Duration(minutes: -10), Duration.zero);
        expect(result, isNull);
      });

      test('returns null for stub implementation', () async {
        final result = await adapter.getStream('channel_123', const Duration(minutes: -10), Duration.zero);
        expect(result, isNull);
      });

      test('accepts valid offset parameters', () async {
        final result = await adapter.getStream('channel_123', const Duration(minutes: -30), const Duration(minutes: -10));
        expect(result, isNull);
      });

      test('handles zero offset', () async {
        final result = await adapter.getStream('channel_123', Duration.zero, Duration.zero);
        expect(result, isNull);
      });
    });
  });
}
