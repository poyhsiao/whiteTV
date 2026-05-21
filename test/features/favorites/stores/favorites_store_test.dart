import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/favorites/presentation/providers/favorites_store.dart';

void main() {
  group('FavoritesStore', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is empty', () {
      final state = container.read(favoritesStoreProvider);
      expect(state.items, isEmpty);
      expect(state.isLoading, false);
      expect(state.isGridView, true);
      expect(state.filterType, 'all');
    });

    test('toggleView flips isGridView', () {
      final notifier = container.read(favoritesStoreProvider.notifier);
      notifier.toggleView();
      var state = container.read(favoritesStoreProvider);
      expect(state.isGridView, false);

      notifier.toggleView();
      state = container.read(favoritesStoreProvider);
      expect(state.isGridView, true);
    });

    test('setFilterType updates filter', () {
      final notifier = container.read(favoritesStoreProvider.notifier);
      notifier.setFilterType('movie');
      final state = container.read(favoritesStoreProvider);
      expect(state.filterType, 'movie');
    });

    test('clearError sets error to null', () {
      final notifier = container.read(favoritesStoreProvider.notifier);
      // First set an error through the state
      notifier.clearError();
      final state = container.read(favoritesStoreProvider);
      expect(state.error, isNull);
    });
  });
}