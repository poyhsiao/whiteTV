import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/features/favorites/services/favorites_local_service.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';

void main() {
  group('FavoritesLocalService', () {
    late FavoritesLocalService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      service = FavoritesLocalService(prefs);
    });

    test('initial state has empty favorites', () async {
      final items = await service.getAll();
      expect(items, isEmpty);
    });

    test('add adds item to local storage', () async {
      final item = FavoriteItem(
        id: 'movie-001',
        title: '星際穿越',
        posterUrl: 'https://example.com/poster.jpg',
        type: 'movie',
        addedAt: DateTime(2026, 5, 21),
      );

      await service.add(item);
      final items = await service.getAll();

      expect(items.length, 1);
      expect(items[0].id, 'movie-001');
    });

    test('remove removes item from local storage', () async {
      final item = FavoriteItem(
        id: 'movie-001',
        title: '星際穿越',
        posterUrl: 'https://example.com/poster.jpg',
        type: 'movie',
        addedAt: DateTime.now(),
      );

      await service.add(item);
      await service.remove('movie-001');
      final items = await service.getAll();

      expect(items, isEmpty);
    });

    test('isFavorite returns true for favorited item', () async {
      final item = FavoriteItem(
        id: 'movie-001',
        title: '星際穿越',
        posterUrl: 'https://example.com/poster.jpg',
        type: 'movie',
        addedAt: DateTime.now(),
      );

      await service.add(item);
      final result = await service.isFavorite('movie-001');

      expect(result, true);
    });

    test('isFavorite returns false for non-favorited item', () async {
      final result = await service.isFavorite('non-existent');
      expect(result, false);
    });

    test('clear removes all items', () async {
      final item1 = FavoriteItem(
        id: '1',
        title: 'Title1',
        posterUrl: '',
        type: 'movie',
        addedAt: DateTime.now(),
      );
      final item2 = FavoriteItem(
        id: '2',
        title: 'Title2',
        posterUrl: '',
        type: 'series',
        addedAt: DateTime.now(),
      );

      await service.add(item1);
      await service.add(item2);
      await service.clear();
      final items = await service.getAll();

      expect(items, isEmpty);
    });
  });
}