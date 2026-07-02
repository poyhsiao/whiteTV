import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/core/api/api_client_fallbacks.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/features/youtube/presentation/providers/youtube_store.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/live/data/models/ipvt_channel.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';
import 'package:white_tv/features/search/search_state.dart';

class FakeYouTubeApiClient with ApiClientFallbacks implements ApiClient {
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
  Future<List<AIRecommendation>> getLocalRecommendations({
    List<String>? watchHistory,
    List<String>? searchHistory,
    int limit = 20,
  }) async => [];

  @override
  Future<List<YoutubeVideo>> getYoutubeRecommend() async => [
    YoutubeVideo(
      id: 'yt_test_1',
      title: 'Test YouTube Video 1',
      thumbnailUrl: 'https://example.com/thumb1.jpg',
      url: 'https://youtube.com/watch?v=dQw4w9WgXcQ',
      duration: '10:30',
      channelTitle: 'Test Channel',
    ),
  ];

  @override
  Future<List<YoutubeVideo>> getYoutubeList(String categoryId, {String? page}) async => [
    YoutubeVideo(
      id: 'yt_list_1',
      title: 'YouTube List Video 1',
      thumbnailUrl: 'https://example.com/thumb2.jpg',
      url: 'https://youtube.com/watch?v=dQw4w9WgXcQ',
      duration: '5:00',
      channelTitle: 'Test Channel',
    ),
  ];

  @override
  Future<List<YoutubeCategory>> getYoutubeCategories() async => [
    YoutubeCategory(id: 'music', name: '音樂', thumbnailUrl: 'https://example.com/music.jpg'),
    YoutubeCategory(id: 'tech', name: '科技', thumbnailUrl: 'https://example.com/tech.jpg'),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('YoutubeStore', () {
    late ProviderContainer container;
    late FakeYouTubeApiClient fakeClient;

    setUp(() {
      fakeClient = FakeYouTubeApiClient();
      container = ProviderContainer(
        overrides: [
          youtubeStoreProvider.overrideWith(
            (ref) => YoutubeStore(fakeClient),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is correct', () {
      final state = container.read(youtubeStoreProvider);
      expect(state.status, equals(YoutubeStatus.initial));
      expect(state.recommendVideos, isEmpty);
      expect(state.categories, isEmpty);
      expect(state.videosByCategory, isEmpty);
      expect(state.selectedCategoryId, isNull);
      expect(state.error, isNull);
    });

    test('loadRecommend loads recommended videos', () async {
      final notifier = container.read(youtubeStoreProvider.notifier);
      await notifier.loadRecommend();
      final state = container.read(youtubeStoreProvider);
      expect(state.status, equals(YoutubeStatus.loaded));
      expect(state.recommendVideos.length, equals(1));
      expect(state.recommendVideos.first.title, equals('Test YouTube Video 1'));
    });

    test('loadCategories loads category list', () async {
      final notifier = container.read(youtubeStoreProvider.notifier);
      await notifier.loadCategories();
      final state = container.read(youtubeStoreProvider);
      expect(state.status, equals(YoutubeStatus.loaded));
      expect(state.categories.length, equals(2));
      expect(state.categories.first.id, equals('music'));
    });

    test('selectCategory loads videos for category', () async {
      final notifier = container.read(youtubeStoreProvider.notifier);
      await notifier.selectCategory('music');
      final state = container.read(youtubeStoreProvider);
      expect(state.status, equals(YoutubeStatus.loaded));
      expect(state.selectedCategoryId, equals('music'));
      expect(state.videosByCategory['music'], isNotNull);
    });

    test('clear resets state', () async {
      final notifier = container.read(youtubeStoreProvider.notifier);
      await notifier.loadRecommend();
      await notifier.loadCategories();
      notifier.clear();
      final state = container.read(youtubeStoreProvider);
      expect(state.status, equals(YoutubeStatus.initial));
      expect(state.recommendVideos, isEmpty);
    });
  });

  group('YoutubeVideo model', () {
    test('YoutubeVideo can be created with required fields', () {
      final video = YoutubeVideo(
        id: 'test_id',
        title: 'Test Title',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        url: 'https://youtube.com/watch?v=abc123',
        duration: '5:30',
        channelTitle: 'Test Channel',
      );
      expect(video.id, equals('test_id'));
      expect(video.url, equals('https://youtube.com/watch?v=abc123'));
      expect(video.duration, equals('5:30'));
    });

    test('YoutubeCategory can be created with required fields', () {
      final category = YoutubeCategory(
        id: 'cat_id',
        name: 'Test Category',
        thumbnailUrl: 'https://example.com/cat.jpg',
      );
      expect(category.id, equals('cat_id'));
      expect(category.name, equals('Test Category'));
    });
  });
}
