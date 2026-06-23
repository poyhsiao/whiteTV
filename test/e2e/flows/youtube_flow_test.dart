import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/main.dart';
import 'package:white_tv/core/router/app_router.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/features/search/search_state.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/live/data/models/ipvt_channel.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';
import 'package:white_tv/features/youtube/presentation/providers/youtube_store.dart';
import '../e2e_test_helpers.dart';
import '../pages/youtube_page.dart';

class FakeApiClient implements ApiClient {
  @override
  Future<Map<String, String>?> login(String username, String password) async => null;

  @override
  Future<List<Category>> getCategories() async => [];

  @override
  Future<List<Video>> getVideosByCategory(String categoryId) async => [];

  @override
  Future<VideoDetail> getVideoDetail(String videoId) async =>
      VideoDetail(id: videoId, title: 'Test Video', episodes: []);

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

  @override
  Future<List<YoutubeVideo>> getYoutubeRecommend() async {
    return [
      YoutubeVideo(
        id: 'yt-1',
        title: 'YouTube Video 1',
        thumbnailUrl: '',
        channelTitle: 'Channel 1',
        duration: '10:30',
      ),
      YoutubeVideo(
        id: 'yt-2',
        title: 'YouTube Video 2',
        thumbnailUrl: '',
        channelTitle: 'Channel 2',
        duration: '15:45',
      ),
    ];
  }

  @override
  Future<List<YoutubeVideo>> getYoutubeList(String categoryId, {String? page}) async {
    return [
      YoutubeVideo(
        id: 'yt-list-1',
        title: 'Category Video 1',
        thumbnailUrl: '',
        channelTitle: 'Channel 3',
        duration: '5:00',
      ),
      YoutubeVideo(
        id: 'yt-list-2',
        title: 'Category Video 2',
        thumbnailUrl: '',
        channelTitle: 'Channel 4',
        duration: '8:30',
      ),
    ];
  }

  @override
  Future<List<YoutubeCategory>> getYoutubeCategories() async {
    return [
      YoutubeCategory(id: 'cat-1', name: 'Music', thumbnailUrl: ''),
      YoutubeCategory(id: 'cat-2', name: 'Gaming', thumbnailUrl: ''),
      YoutubeCategory(id: 'cat-3', name: 'Tech', thumbnailUrl: ''),
    ];
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('YouTube Flow E2E', () {
    testWidgets('User can view YouTube section on home page', (WidgetTester tester) async {
      setupE2EPluginMocks();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            youtubeStoreProvider.overrideWith(
              (ref) => YoutubeStore(FakeApiClient()),
            ),
          ],
          child: WhiteTVApp(
            router: createAppRouter(initialLocation: '/'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Navigate and scroll to YouTube section
      final youtubePage = YoutubePage(tester);
      await youtubePage.scrollToSection();

      // Assert - Verify YouTube section is visible
      await youtubePage.verifySectionVisible();
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('User can navigate to YouTube category page', (WidgetTester tester) async {
      setupE2EPluginMocks();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            youtubeStoreProvider.overrideWith(
              (ref) => YoutubeStore(FakeApiClient()),
            ),
          ],
          child: WhiteTVApp(
            router: createAppRouter(initialLocation: '/youtube'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Wait for content to load
      await tester.pump(const Duration(seconds: 1));

      // Assert - Categories should be visible
      expect(find.byType(ChoiceChip), findsWidgets);
    });

    testWidgets('User can select category on YouTube page', (WidgetTester tester) async {
      setupE2EPluginMocks();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            youtubeStoreProvider.overrideWith(
              (ref) => YoutubeStore(FakeApiClient()),
            ),
          ],
          child: WhiteTVApp(
            router: createAppRouter(initialLocation: '/youtube'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Wait for initial load
      await tester.pump(const Duration(seconds: 1));

      // Act - Tap second category
      final youtubePage = YoutubePage(tester);
      await youtubePage.tapCategoryAtIndex(1);

      // Assert - Video grid should update
      await youtubePage.verifyVideoGrid();
    });
  });
}
