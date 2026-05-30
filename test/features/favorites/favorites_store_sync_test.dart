import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:white_tv/features/favorites/presentation/providers/favorites_store.dart';
import 'package:white_tv/features/favorites/domain/models/favorites_state.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';
import 'package:white_tv/features/favorites/services/favorites_remote_service.dart';

class MockFavoritesRemoteService extends Mock implements FavoritesRemoteService {}

void main() {
  group('FavoritesStore Sync', () {
    late MockFavoritesRemoteService mockRemoteService;
    late ProviderContainer container;

    setUp(() {
      mockRemoteService = MockFavoritesRemoteService();
      container = ProviderContainer(
        overrides: [
          favoritesRemoteServiceProvider.overrideWithValue(mockRemoteService),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('loadFavorites calls remote service and updates state', () async {
      final testItems = [
        FavoriteItem(id: '1', title: 'Movie 1', type: 'movie', posterUrl: '', addedAt: DateTime.now()),
        FavoriteItem(id: '2', title: 'Movie 2', type: 'movie', posterUrl: '', addedAt: DateTime.now()),
      ];

      when(() => mockRemoteService.fetchFavorites())
          .thenAnswer((_) async => testItems);

      final store = container.read(favoritesStoreProvider.notifier);
      await store.loadFavorites();

      final state = container.read(favoritesStoreProvider);
      expect(state.items.length, 2);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('loadFavorites handles error gracefully', () async {
      when(() => mockRemoteService.fetchFavorites())
          .thenThrow(Exception('Network error'));

      final store = container.read(favoritesStoreProvider.notifier);
      await store.loadFavorites();

      final state = container.read(favoritesStoreProvider);
      expect(state.items, isEmpty);
      expect(state.error, isNotNull);
    });
  });
}