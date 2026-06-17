import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/features/category/category_content_state.dart';
import 'package:white_tv/features/category/category_content_store.dart';
import 'package:white_tv/features/category/category_constants.dart';

void main() {
  group('CategoryContentStore', () {
    late MockClient mockClient;
    late CategoryContentStore store;

    setUp(() {
      mockClient = MockClient();
      store = CategoryContentStore(mockClient, 'movie');
    });

    test('initial state has correct categoryId', () {
      expect(store.state.categoryId, 'movie');
      expect(store.state.isLoading, false);
      expect(store.state.videos, isEmpty);
    });

    test('loadContent populates videos for category', () async {
      await store.loadContent();
      expect(store.state.isLoading, false);
      expect(store.state.videos, isNotEmpty);
      expect(store.state.videos.every((v) => v.categoryId == 'movie'), isTrue);
    });

    test('loadContent with error simulation sets error state', () async {
      mockClient.shouldThrowGetVideos = true;
      mockClient.videoToThrowOn = 'movie';
      await store.loadContent();
      expect(store.state.isLoading, false);
      expect(store.state.error, isNotNull);
      expect(store.state.videos, isEmpty);
    });

    test('setSubCategory updates filter', () async {
      store.setSubCategory('action');
      expect(store.state.subCategory, 'action');
      // Should trigger reload — videos may be filtered
      await store.loadContent();
      expect(store.state.isLoading, false);
    });

    test('setRegion updates region filter', () {
      store.setRegion('hk');
      expect(store.state.region, 'hk');
    });

    test('setYear updates year filter', () {
      store.setYear('2024');
      expect(store.state.year, '2024');
    });

    test('setSortOption updates sort option', () {
      store.setSortOption(SortOption.rating);
      expect(store.state.sortOption, SortOption.rating);
    });

    test('setCategoryId updates category and reloads', () async {
      await store.loadContent();
      expect(store.state.videos.isNotEmpty, isTrue);
      store.setCategoryId('drama');
      expect(store.state.categoryId, 'drama');
      expect(store.state.videos, isEmpty);
      expect(store.state.isLoading, isTrue);
    });

    test('refresh resets and reloads', () async {
      await store.loadContent();
      final videosBefore = store.state.videos;
      store.refresh();
      expect(store.state.isLoading, isTrue);
      // After refresh completes
      await store.loadContent();
      expect(store.state.isLoading, isFalse);
      expect(store.state.videos, isNotEmpty);
    });

    test('loading state is set during async operations', () async {
      final future = store.loadContent();
      expect(store.state.isLoading, isTrue);
      await future;
      expect(store.state.isLoading, isFalse);
    });
  });
}
