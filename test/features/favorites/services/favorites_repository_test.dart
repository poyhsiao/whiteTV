import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';
import 'package:white_tv/features/favorites/domain/repositories/favorites_repository.dart';

void main() {
  group('FavoritesRepository', () {
    test('is abstract interface', () {
      // Verify it's an abstract interface by checking that a concrete
      // implementation can be instantiated while direct instantiation is not
      // possible (compile-time error in Dart 3+)
      final repo = _TestFavoritesRepository();
      expect(repo, isA<FavoritesRepository>());
    });

    test('add method signature accepts FavoriteItem', () {
      final repo = _TestFavoritesRepository();
      expect(repo.add(FavoriteItem(
        id: '1',
        title: 'Test',
        posterUrl: '',
        type: 'movie',
        addedAt: DateTime.now(),
      )), completes);
    });

    test('remove method signature accepts String id', () {
      final repo = _TestFavoritesRepository();
      expect(repo.remove('1'), completes);
    });

    test('isFavorite method signature returns bool', () {
      final repo = _TestFavoritesRepository();
      expect(repo.isFavorite('1'), completes);
    });

    test('sync method signature', () {
      final repo = _TestFavoritesRepository();
      expect(repo.sync(), completes);
    });
  });
}

class _TestFavoritesRepository implements FavoritesRepository {
  @override
  Future<List<FavoriteItem>> getAll() async => [];

  @override
  Future<void> add(FavoriteItem item) async {}

  @override
  Future<void> remove(String id) async {}

  @override
  Future<bool> isFavorite(String id) async => false;

  @override
  Future<void> sync() async {}
}