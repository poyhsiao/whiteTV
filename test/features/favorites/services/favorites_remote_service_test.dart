import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/favorites/services/favorites_remote_service.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';

void main() {
  group('FavoritesRemoteService', () {
    test('can be instantiated with baseUrl', () {
      final service = FavoritesRemoteService(baseUrl: 'http://test.com/api');
      expect(service, isA<FavoritesRemoteService>());
    });

    // Integration tests - require actual server
    // Marked as skip because they need http://lunatv.example.com/api running
    test('addFavorite returns bool (integration test)', () async {
      final service = FavoritesRemoteService(baseUrl: 'http://lunatv.example.com/api');
      final item = FavoriteItem(id: '1', title: 'Test', posterUrl: '', type: 'movie', addedAt: DateTime.now());
      final result = await service.addFavorite(item);
      expect(result, isA<bool>());
    }, skip: 'Requires running lunatv API server');

    test('removeFavorite returns bool (integration test)', () async {
      final service = FavoritesRemoteService(baseUrl: 'http://lunatv.example.com/api');
      final result = await service.removeFavorite('1');
      expect(result, isA<bool>());
    }, skip: 'Requires running lunatv API server');

    test('fetchFavorites returns list of favorites (integration test)', () async {
      final service = FavoritesRemoteService(baseUrl: 'http://lunatv.example.com/api');
      final result = await service.fetchFavorites();
      expect(result, isA<List<FavoriteItem>>());
    }, skip: 'Requires running lunatv API server');

    test('syncToServer returns bool (integration test)', () async {
      final service = FavoritesRemoteService(baseUrl: 'http://lunatv.example.com/api');
      final items = [
        FavoriteItem(id: '1', title: 'Test', posterUrl: '', type: 'movie', addedAt: DateTime.now()),
      ];
      final result = await service.syncToServer(items);
      expect(result, isA<bool>());
    }, skip: 'Requires running lunatv API server');
  });
}