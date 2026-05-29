import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/favorites/services/favorites_remote_service.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';

void main() {
  group('FavoritesRemoteService', () {
    late FavoritesRemoteService service;

    setUp(() {
      service = FavoritesRemoteService(baseUrl: 'http://lunatv.example.com/api');
    });

    test('fetchFavorites returns list of favorites', () async {
      final result = await service.fetchFavorites();
      expect(result, isA<List<FavoriteItem>>());
    });

    test('syncToServer returns true on success', () async {
      final items = [
        FavoriteItem(id: '1', title: 'Test', posterUrl: '', type: 'movie', addedAt: DateTime.now()),
      ];
      final result = await service.syncToServer(items);
      expect(result, isA<bool>());
    });

    test('addFavorite returns bool', () async {
      final item = FavoriteItem(id: '1', title: 'Test', posterUrl: '', type: 'movie', addedAt: DateTime.now());
      final result = await service.addFavorite(item);
      expect(result, isA<bool>());
    });

    test('removeFavorite returns bool', () async {
      final result = await service.removeFavorite('1');
      expect(result, isA<bool>());
    });
  });
}