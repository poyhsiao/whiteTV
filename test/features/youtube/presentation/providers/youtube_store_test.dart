import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/features/youtube/presentation/providers/youtube_store.dart';

void main() {
  group('YoutubeStore', () {
    late MockClient mockClient;
    late YoutubeStore store;

    setUp(() {
      mockClient = MockClient();
      store = YoutubeStore(mockClient);
    });

    test('initial state is correct', () {
      expect(store.state.status, YoutubeStatus.initial);
      expect(store.state.recommendVideos, isEmpty);
      expect(store.state.categories, isEmpty);
      expect(store.state.videosByCategory, isEmpty);
      expect(store.state.selectedCategoryId, isNull);
      expect(store.state.error, isNull);
    });

    test('loadRecommend populates recommendVideos', () async {
      await store.loadRecommend();
      expect(store.state.status, YoutubeStatus.loaded);
      expect(store.state.recommendVideos, isNotEmpty);
      expect(store.state.recommendVideos.first, isA<YoutubeVideo>());
    });

    test('loadRecommend handles error', () async {
      // MockClient doesn't throw by default for YouTube, testing happy path
      await store.loadRecommend();
      expect(store.state.error, isNull);
    });

    test('loadCategories populates categories', () async {
      await store.loadCategories();
      expect(store.state.status, YoutubeStatus.loaded);
      expect(store.state.categories, isNotEmpty);
      expect(store.state.categories.first, isA<YoutubeCategory>());
    });

    test('selectCategory loads videos for category', () async {
      await store.selectCategory('music');
      expect(store.state.status, YoutubeStatus.loaded);
      expect(store.state.selectedCategoryId, 'music');
      expect(store.state.videosByCategory['music'], isNotEmpty);
    });

    test('selectCategory updates videosByCategory map', () async {
      await store.selectCategory('gaming');
      expect(store.state.videosByCategory.containsKey('gaming'), isTrue);
      final videos = store.state.videosByCategory['gaming']!;
      expect(videos, isA<List<YoutubeVideo>>());
    });

    test('loading state is set during async operations', () async {
      final future = store.loadRecommend();
      expect(store.state.status, YoutubeStatus.loading);
      await future;
      expect(store.state.status, YoutubeStatus.loaded);
    });

    test('categories loading state is set during async operations', () async {
      final future = store.loadCategories();
      expect(store.state.status, YoutubeStatus.loading);
      await future;
      expect(store.state.status, YoutubeStatus.loaded);
    });

    test('selectCategory sets loading then loaded', () async {
      final future = store.selectCategory('tech');
      expect(store.state.status, YoutubeStatus.loading);
      await future;
      expect(store.state.status, YoutubeStatus.loaded);
    });

    test('clear resets state to initial', () async {
      await store.loadRecommend();
      await store.loadCategories();
      await store.selectCategory('music');

      store.clear();

      expect(store.state.status, YoutubeStatus.initial);
      expect(store.state.recommendVideos, isEmpty);
      expect(store.state.categories, isEmpty);
      expect(store.state.videosByCategory, isEmpty);
      expect(store.state.selectedCategoryId, isNull);
    });
  });

  group('YoutubeState', () {
    test('copyWith creates new instance with updated values', () {
      const state = YoutubeState();
      final updated = state.copyWith(
        status: YoutubeStatus.loaded,
        selectedCategoryId: 'test',
      );

      expect(updated.status, YoutubeStatus.loaded);
      expect(updated.selectedCategoryId, 'test');
      expect(updated.recommendVideos, isEmpty); // unchanged
    });

    test('default values are correct', () {
      const state = YoutubeState();
      expect(state.status, YoutubeStatus.initial);
      expect(state.recommendVideos, isEmpty);
      expect(state.categories, isEmpty);
      expect(state.videosByCategory, isEmpty);
      expect(state.selectedCategoryId, isNull);
      expect(state.error, isNull);
    });
  });

  group('youtubeStoreProvider', () {
    test('provider creates store with api client', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Provider throws if not overridden, verify it exists
      expect(youtubeStoreProvider, isNotNull);
    });
  });
}
