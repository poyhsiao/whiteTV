import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/features/favorites/services/favorites_local_service.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FavoritesLocalService', () {
    late FavoritesLocalService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = FavoritesLocalService();
    });

    test('save and retrieve favorites', () async {
      final item = FavoriteItem(
        id: '1',
        title: 'Test Movie',
        posterUrl: 'http://example.com/poster.jpg',
        type: 'movie',
        addedAt: DateTime(2026, 5, 29),
      );

      await service.save(item);
      final favorites = await service.getAll();

      expect(favorites.length, 1);
      expect(favorites.first.id, '1');
    });

    test('remove favorite by id', () async {
      final item = FavoriteItem(
        id: '1',
        title: 'Test Movie',
        posterUrl: 'http://example.com/poster.jpg',
        type: 'movie',
        addedAt: DateTime(2026, 5, 29),
      );

      await service.save(item);
      await service.remove('1');
      final favorites = await service.getAll();

      expect(favorites.isEmpty, true);
    });
  });
}
