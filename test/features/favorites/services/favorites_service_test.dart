import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/favorites/services/favorites_service.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';
import 'package:white_tv/features/favorites/domain/repositories/favorites_repository.dart';

class MockFavoritesRepository implements FavoritesRepository {
  final List<FavoriteItem> _items = [];

  @override
  Future<List<FavoriteItem>> getAll() async => List.from(_items);

  @override
  Future<void> add(FavoriteItem item) async { _items.add(item); }

  @override
  Future<void> remove(String id) async { _items.removeWhere((i) => i.id == id); }

  @override
  Future<bool> isFavorite(String id) async => _items.any((i) => i.id == id);

  @override
  Future<void> sync() async { /* mock sync */ }
}

void main() {
  group('FavoritesService', () {
    late MockFavoritesRepository repo;
    late FavoritesService service;

    setUp(() {
      repo = MockFavoritesRepository();
      service = FavoritesService(repository: repo);
    });

    test('addFavorite adds item via repository', () async {
      final item = FavoriteItem(
        id: '1', title: 'Test', posterUrl: '', type: 'movie', addedAt: DateTime.now(),
      );
      await service.addFavorite(item);
      expect(await service.isFavorite('1'), true);
    });

    test('removeFavorite removes item via repository', () async {
      final item = FavoriteItem(
        id: '1', title: 'Test', posterUrl: '', type: 'movie', addedAt: DateTime.now(),
      );
      await repo.add(item);
      await service.removeFavorite('1');
      expect(await service.isFavorite('1'), false);
    });

    test('getFavorites returns all items', () async {
      final item1 = FavoriteItem(
        id: '1', title: 'Test1', posterUrl: '', type: 'movie', addedAt: DateTime.now(),
      );
      final item2 = FavoriteItem(
        id: '2', title: 'Test2', posterUrl: '', type: 'series', addedAt: DateTime.now(),
      );
      await repo.add(item1);
      await repo.add(item2);
      final favorites = await service.getFavorites();
      expect(favorites.length, 2);
    });

    test('isFavorite returns correct status', () async {
      final item = FavoriteItem(
        id: '1', title: 'Test', posterUrl: '', type: 'movie', addedAt: DateTime.now(),
      );
      await repo.add(item);
      expect(await service.isFavorite('1'), true);
      expect(await service.isFavorite('non-existent'), false);
    });
  });
}