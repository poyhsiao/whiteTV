import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';
import 'package:white_tv/features/favorites/services/favorites_remote_service.dart';
import 'package:white_tv/features/favorites/services/favorites_local_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeFavoritesRemoteService extends FavoritesRemoteService {
  FakeFavoritesRemoteService() : super(baseUrl: 'http://test.com');

  @override
  Future<List<FavoriteItem>> fetchFavorites() async {
    return [];
  }

  @override
  Future<bool> addFavorite(FavoriteItem item) async {
    return true;
  }

  @override
  Future<bool> removeFavorite(String id) async {
    return true;
  }

  @override
  Future<bool> syncToServer(List<FavoriteItem> items) async {
    return true;
  }
}

class FakeFavoritesLocalService extends FavoritesLocalService {
  final _items = <FavoriteItem>[];

  @override
  Future<List<FavoriteItem>> getAll() async => List.from(_items);

  @override
  Future<void> save(FavoriteItem item) async {
    _items.removeWhere((i) => i.id == item.id);
    _items.add(item);
  }

  @override
  Future<void> remove(String id) async {
    _items.removeWhere((i) => i.id == id);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FavoritesRepositoryImpl', () {
    late FavoritesRepositoryImpl repository;
    late FakeFavoritesRemoteService remote;
    late FakeFavoritesLocalService local;

    setUp(() {
      remote = FakeFavoritesRemoteService();
      local = FakeFavoritesLocalService();
      repository = FavoritesRepositoryImpl(remote, local);
    });

    test('getAll returns empty list when both services return empty', () async {
      final result = await repository.getAll();
      expect(result, isEmpty);
    });

    test('add saves item locally', () async {
      final item = FavoriteItem(
        id: '1',
        title: 'Test',
        posterUrl: 'http://test.com/poster.jpg',
        type: 'movie',
        addedAt: DateTime.now(),
      );

      await repository.add(item);
      final isFav = await repository.isFavorite('1');
      expect(isFav, true);
    });

    test('remove deletes item locally', () async {
      final item = FavoriteItem(
        id: '1',
        title: 'Test',
        posterUrl: 'http://test.com/poster.jpg',
        type: 'movie',
        addedAt: DateTime.now(),
      );

      await repository.add(item);
      await repository.remove('1');
      final isFav = await repository.isFavorite('1');
      expect(isFav, false);
    });
  });
}