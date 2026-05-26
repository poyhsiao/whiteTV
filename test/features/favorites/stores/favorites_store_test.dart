import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';
import 'package:white_tv/features/favorites/domain/models/favorites_state.dart';
import 'package:white_tv/features/favorites/presentation/providers/favorites_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('FavoritesStore', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    // Initial state tests
    test('initial state is empty with correct defaults', () {
      final state = container.read(favoritesStoreProvider);
      expect(state.items, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.isGridView, true);
      expect(state.filterType, 'all');
      expect(state.isSyncing, false);
    });

    // View toggle tests
    test('toggleView flips isGridView from true to false', () {
      final notifier = container.read(favoritesStoreProvider.notifier);
      notifier.toggleView();
      var state = container.read(favoritesStoreProvider);
      expect(state.isGridView, false);
    });

    test('toggleView flips isGridView from false to true', () {
      final notifier = container.read(favoritesStoreProvider.notifier);
      notifier.toggleView();
      notifier.toggleView();
      final state = container.read(favoritesStoreProvider);
      expect(state.isGridView, true);
    });

    // Filter tests
    test('setFilterType updates filter to specific type', () {
      final notifier = container.read(favoritesStoreProvider.notifier);
      notifier.setFilterType('movie');
      final state = container.read(favoritesStoreProvider);
      expect(state.filterType, 'movie');
    });

    test('filteredItems returns only items matching filter type', () {
      final notifier = container.read(favoritesStoreProvider.notifier);
      notifier.setItems([
        _createTestItem(id: '1', title: 'Movie 1', type: 'movie'),
        _createTestItem(id: '2', title: 'Series 1', type: 'series'),
        _createTestItem(id: '3', title: 'Movie 2', type: 'movie'),
      ]);
      notifier.setFilterType('movie');
      final state = container.read(favoritesStoreProvider);
      expect(state.filteredItems.length, 2);
      expect(state.filteredItems.every((item) => item.type == 'movie'), true);
    });

    test('filteredItems returns all items when filter is all', () {
      final notifier = container.read(favoritesStoreProvider.notifier);
      notifier.setItems([
        _createTestItem(id: '1', type: 'movie'),
        _createTestItem(id: '2', type: 'series'),
      ]);
      notifier.setFilterType('all');
      final state = container.read(favoritesStoreProvider);
      expect(state.filteredItems.length, 2);
    });

    // Error handling tests
    test('clearError sets error to null', () {
      final notifier = container.read(favoritesStoreProvider.notifier);
      notifier.setError('Test error');
      expect(container.read(favoritesStoreProvider).error, 'Test error');
      notifier.clearError();
      expect(container.read(favoritesStoreProvider).error, isNull);
    });

    test('setError updates error and clears loading', () {
      final notifier = container.read(favoritesStoreProvider.notifier);
      notifier.setLoading(true);
      notifier.setError('Network error');
      final state = container.read(favoritesStoreProvider);
      expect(state.error, 'Network error');
      expect(state.isLoading, false);
    });

    // Loading state tests
    test('setLoading updates loading state', () {
      final notifier = container.read(favoritesStoreProvider.notifier);
      notifier.setLoading(true);
      expect(container.read(favoritesStoreProvider).isLoading, true);
      notifier.setLoading(false);
      expect(container.read(favoritesStoreProvider).isLoading, false);
    });

    // Syncing state tests
    test('setSyncing updates syncing state', () {
      final notifier = container.read(favoritesStoreProvider.notifier);
      notifier.setSyncing(true);
      expect(container.read(favoritesStoreProvider).isSyncing, true);
      notifier.setSyncing(false);
      expect(container.read(favoritesStoreProvider).isSyncing, false);
    });

    // Items management tests
    test('setItems updates items and clears loading and error', () {
      final notifier = container.read(favoritesStoreProvider.notifier);
      final items = [_createTestItem(id: '1'), _createTestItem(id: '2')];
      notifier.setError('Previous error');
      notifier.setLoading(true);
      notifier.setItems(items);
      final state = container.read(favoritesStoreProvider);
      expect(state.items.length, 2);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('removeFavorite removes item from list', () {
      final notifier = container.read(favoritesStoreProvider.notifier);
      notifier.setItems([
        _createTestItem(id: '1', title: 'Item 1'),
        _createTestItem(id: '2', title: 'Item 2'),
        _createTestItem(id: '3', title: 'Item 3'),
      ]);
      notifier.removeFavorite('2');
      final state = container.read(favoritesStoreProvider);
      expect(state.items.length, 2);
      expect(state.items.any((item) => item.id == '2'), false);
    });

    test('removeFavorite handles non-existent id gracefully', () {
      final notifier = container.read(favoritesStoreProvider.notifier);
      notifier.setItems([_createTestItem(id: '1')]);
      notifier.removeFavorite('non-existent-id');
      final state = container.read(favoritesStoreProvider);
      expect(state.items.length, 1);
    });

    // Available/Unavailable items tests
    test('availableItems returns only available items', () {
      final notifier = container.read(favoritesStoreProvider.notifier);
      notifier.setItems([
        _createTestItem(id: '1', isAvailable: true),
        _createTestItem(id: '2', isAvailable: false),
        _createTestItem(id: '3', isAvailable: true),
      ]);
      final state = container.read(favoritesStoreProvider);
      expect(state.availableItems.length, 2);
    });

    test('unavailableItems returns only unavailable items', () {
      final notifier = container.read(favoritesStoreProvider.notifier);
      notifier.setItems([
        _createTestItem(id: '1', isAvailable: true),
        _createTestItem(id: '2', isAvailable: false),
      ]);
      final state = container.read(favoritesStoreProvider);
      expect(state.unavailableItems.length, 1);
      expect(state.unavailableItems.first.id, '2');
    });

    // loadFavorites test
    test('loadFavorites sets loading to false without loading from remote', () {
      final notifier = container.read(favoritesStoreProvider.notifier);
      notifier.setLoading(true);
      notifier.loadFavorites();
      final state = container.read(favoritesStoreProvider);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });
  });

  group('FavoritesState', () {
    test('copyWith creates new instance with updated values', () {
      const state = FavoritesState(isGridView: true, filterType: 'all');
      final newState = state.copyWith(isGridView: false, filterType: 'movie');
      expect(newState.isGridView, false);
      expect(newState.filterType, 'movie');
      // Original should be unchanged
      expect(state.isGridView, true);
      expect(state.filterType, 'all');
    });

    test('copyWith with clearError removes error', () {
      const state = FavoritesState(error: 'Some error');
      final newState = state.copyWith(clearError: true);
      expect(newState.error, isNull);
    });

    test('copyWith preserves values when not specified', () {
      final items = [_createTestItem(id: '1')];
      final state = FavoritesState(items: items, isLoading: true);
      final newState = state.copyWith(isLoading: false);
      expect(newState.items, items);
      expect(newState.isLoading, false);
    });
  });
}

FavoriteItem _createTestItem({
  required String id,
  String title = 'Test Title',
  String type = 'movie',
  bool isAvailable = true,
  DateTime? addedAt,
}) => FavoriteItem(
  id: id,
  title: title,
  posterUrl: 'https://example.com/poster.jpg',
  type: type,
  isAvailable: isAvailable,
  addedAt: addedAt ?? DateTime(2024, 1, 1),
);
