import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';
import 'package:white_tv/features/favorites/domain/models/favorites_state.dart';

void main() {
  group('FavoritesState', () {
    test('initial state has empty items', () {
      const state = FavoritesState();
      expect(state.items, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.isGridView, true);
      expect(state.filterType, 'all');
      expect(state.isSyncing, false);
    });

    test('copyWith updates specific fields', () {
      const state = FavoritesState(isLoading: true);
      final updated = state.copyWith(isLoading: false, error: 'Failed');

      expect(updated.isLoading, false);
      expect(updated.error, 'Failed');
      expect(state.isLoading, true); // original unchanged
    });

    test('filteredItems returns all when filterType is all', () {
      final items = [
        FavoriteItem(id: '1', title: '電影1', posterUrl: '', type: 'movie', addedAt: DateTime.now()),
        FavoriteItem(id: '2', title: '劇集1', posterUrl: '', type: 'series', addedAt: DateTime.now()),
      ];
      final state = FavoritesState(items: items, filterType: 'all');

      expect(state.filteredItems.length, 2);
    });

    test('filteredItems filters by type', () {
      final items = [
        FavoriteItem(id: '1', title: '電影1', posterUrl: '', type: 'movie', addedAt: DateTime.now()),
        FavoriteItem(id: '2', title: '劇集1', posterUrl: '', type: 'series', addedAt: DateTime.now()),
      ];
      final state = FavoritesState(items: items, filterType: 'movie');

      expect(state.filteredItems.length, 1);
      expect(state.filteredItems[0].type, 'movie');
    });

    test('availableItems returns only available items', () {
      final items = [
        FavoriteItem(id: '1', title: '可用', posterUrl: '', type: 'movie', isAvailable: true, addedAt: DateTime.now()),
        FavoriteItem(id: '2', title: '已下架', posterUrl: '', type: 'movie', isAvailable: false, addedAt: DateTime.now()),
      ];
      final state = FavoritesState(items: items);

      expect(state.availableItems.length, 1);
      expect(state.availableItems[0].title, '可用');
    });

    test('unavailableItems returns only unavailable items', () {
      final items = [
        FavoriteItem(id: '1', title: '可用', posterUrl: '', type: 'movie', isAvailable: true, addedAt: DateTime.now()),
        FavoriteItem(id: '2', title: '已下架', posterUrl: '', type: 'movie', isAvailable: false, addedAt: DateTime.now()),
      ];
      final state = FavoritesState(items: items);

      expect(state.unavailableItems.length, 1);
      expect(state.unavailableItems[0].title, '已下架');
    });
  });
}