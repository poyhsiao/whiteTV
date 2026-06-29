import 'package:white_tv/core/api/api_client_fallbacks.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/live/data/models/ipvt_channel.dart';
import 'package:white_tv/features/live/domain/services/timeshift_service_adapter.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';
import 'package:white_tv/features/search/search_state.dart';

/// Fake ApiClient for testing TimeshiftServiceAdapter
class FakeApiClient with ApiClientFallbacks implements ApiClient {
  bool throwOnCheckSupport = false;
  bool checkSupportResult = false;

  @override
  Future<Map<String, String>?> login(String username, String password) async =>
      null;

  @override
  Future<List<Category>> getCategories() async => [];

  @override
  Future<List<Video>> getVideosByCategory(String categoryId) async => [];

  @override
  Future<VideoDetail> getVideoDetail(String videoId) async =>
      throw UnimplementedError();

  @override
  Future<List<VideoSource>> getSources(String videoId) async => [];

  @override
  Future<int> testSourceLatency(String sourceUrl) async => 0;

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
  Future<List<IptvChannel>> getIptvChannels() async => [];

  @override
  Future<String?> getIptvM3U() async => null;

  @override
  Future<Map<String, dynamic>> getIptvEpg() async => {};

  @override
  Future<List<AIRecommendation>> getAIRecommendations() async => [];

  @override
  Future<List<AIRecommendation>> getLocalRecommendations({
    List<String>? watchHistory,
    List<String>? searchHistory,
    int limit = 20,
  }) async => [];
}

void main() {
  late FakeApiClient fakeApi;
  late TimeshiftServiceAdapter adapter;

  setUp(() {
    fakeApi = FakeApiClient();
    adapter = TimeshiftServiceAdapter(fakeApi);
  });

  group('TimeshiftServiceAdapter', () {
    group('checkSupport', () {
      test('returns false when ApiClient returns false', () async {
        fakeApi.checkSupportResult = false;
        final result = await adapter.checkSupport('channel-1');
        expect(result, isFalse);
      });

      test('returns false when ApiClient throws', () async {
        fakeApi.throwOnCheckSupport = true;
        final result = await adapter.checkSupport('channel-1');
        expect(result, isFalse);
      });

      test('returns false for empty channel ID', () async {
        final result = await adapter.checkSupport('');
        expect(result, isFalse);
      });
    });

    group('getStream', () {
      test('returns null for any channel (TODO: LunaTV API)', () async {
        final result = await adapter.getStream(
          'channel-1',
          const Duration(minutes: -5),
          Duration.zero,
        );
        expect(result, isNull);
      });

      test('returns null with different offsets', () async {
        final result = await adapter.getStream(
          'channel-1',
          const Duration(hours: -1),
          const Duration(minutes: -30),
        );
        expect(result, isNull);
      });

      test('returns null for empty channel ID', () async {
        final result = await adapter.getStream(
          '',
          Duration.zero,
          Duration.zero,
        );
        expect(result, isNull);
      });
    });
  });
}
