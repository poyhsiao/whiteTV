import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/features/live/data/models/ipvt_channel.dart';
import 'package:white_tv/core/source/source_selector.dart';
import 'package:white_tv/features/detail/detail_screen.dart';
import 'package:white_tv/features/detail/detail_store.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';
import 'package:white_tv/features/search/search_state.dart';

/// Minimal ApiClient for testing
class FakeDetailClient implements ApiClient {
  const FakeDetailClient();

  @override
  Future<Map<String, String>?> login(String u, String p) async => null;
  @override
  Future<List<Category>> getCategories() async => [];
  @override
  Future<List<Video>> getVideosByCategory(String c) async => [];
  @override
  Future<VideoDetail> getVideoDetail(String id) async => VideoDetail(id: id, title: 'Test');
  @override
  Future<List<VideoSource>> getSources(String id) async => [];
  @override
  Future<int> testSourceLatency(String url) async => 100;
  @override
  Future<List<int>> search(String q, {SearchCategory? category}) async => [];
  @override
  Future<Map<String, dynamic>> getUserStats() async => {};
  @override
  Future<void> syncSearchHistory(List<String> h) async {}
  @override
  Future<List<String>> getSearchHistory() async => [];
  @override
  Future<bool> savePlayHistory(PlayHistory r) async => true;
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
  group('DetailScreen TV source selector', () {
    testWidgets('TV mode shows vertical source cards, not Wrap chips',
        (tester) async {
      final sources = [
        const VideoSource(
            id: 'src-1', name: '量子資源', url: 'http://a.com', latency: 120),
        const VideoSource(
            id: 'src-2', name: '穩定來源', url: 'http://b.com', latency: 80),
        const VideoSource(
            id: 'src-3',
            name: '離線源',
            url: 'http://c.com',
            latency: 0,
            isAvailable: false),
      ];

      // Pre-build state with detail and sources loaded
      final detail = VideoDetail(
        id: 'movie-1',
        title: 'Test Movie',
        sources: sources,
        episodes: [
          const Episode(id: 'ep-1', number: 1),
        ],
      );

      final preloadedState = DetailState(
        detail: detail,
        selectedSource: sources.first,
        isLoading: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            detailStoreProvider.overrideWith(
              (ref) => _FakeDetailStore(preloadedState),
            ),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(1100, 1080)),
              child: const DetailScreen(videoId: 'movie-1'),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 2));

      // TV mode: should show vertical list key
      expect(find.byKey(const Key('tv_source_list')), findsOneWidget);

      // Should show source names
      expect(find.text('量子資源'), findsOneWidget);
      expect(find.text('穩定來源'), findsOneWidget);

      // Should show latency info
      expect(find.textContaining('120ms'), findsOneWidget);
      expect(find.textContaining('80ms'), findsOneWidget);

      // Should show unavailable source with 🔴
      expect(find.textContaining('🔴'), findsOneWidget);
    });

    testWidgets('mobile mode shows Wrap chip source selector', (tester) async {
      final sources = [
        const VideoSource(
            id: 'src-1', name: '量子資源', url: 'http://a.com', latency: 120),
      ];

      final detail = VideoDetail(
        id: 'movie-1',
        title: 'Test Movie',
        sources: sources,
        episodes: [
          const Episode(id: 'ep-1', number: 1),
        ],
      );

      final preloadedState = DetailState(
        detail: detail,
        selectedSource: sources.first,
        isLoading: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            detailStoreProvider.overrideWith(
              (ref) => _FakeDetailStore(preloadedState),
            ),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(375, 812)),
              child: const DetailScreen(videoId: 'movie-1'),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 2));

      // Mobile mode: should show Wrap chip key
      expect(find.byKey(const Key('mobile_source_selector')), findsOneWidget);

      // TV list key should NOT be present
      expect(find.byKey(const Key('tv_source_list')), findsNothing);
    });
  });
}

/// Fake DetailStore that skips API loading
class _FakeDetailStore extends DetailStore {
  final DetailState _preloadedState;

  _FakeDetailStore(this._preloadedState)
      : super(FakeDetailClient(), SourceSelector(), null) {
    state = _preloadedState;
  }

  @override
  Future<void> loadDetail(String videoId) async {
    // No-op: state is already preloaded
  }
}
