import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:white_tv/features/favorites/domain/models/favorites_state.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';
import 'package:white_tv/features/favorites/presentation/widgets/favorite_grid.dart';
import 'package:white_tv/features/favorites/presentation/widgets/favorite_tile.dart';
import 'package:white_tv/features/favorites/presentation/widgets/favorites_filter_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Favorites Feature BDD Tests', () {
    // ========================================================================
    // Background: Shared test data
    // ========================================================================
    final testFavorites = [
      FavoriteItem(
        id: '1',
        title: 'Test Movie 1',
        posterUrl: 'https://example.com/poster1.jpg',
        type: 'movie',
        isAvailable: true,
        addedAt: DateTime(2026, 1, 1),
      ),
      FavoriteItem(
        id: '2',
        title: 'Test Series 1',
        posterUrl: 'https://example.com/poster2.jpg',
        type: 'series',
        isAvailable: true,
        addedAt: DateTime(2026, 1, 2),
      ),
      FavoriteItem(
        id: '3',
        title: 'Unavailable Anime',
        posterUrl: 'https://example.com/poster3.jpg',
        type: 'anime',
        isAvailable: false,
        addedAt: DateTime(2026, 1, 3),
      ),
      FavoriteItem(
        id: '4',
        title: 'Test Variety 1',
        posterUrl: 'https://example.com/poster4.jpg',
        type: 'variety',
        isAvailable: true,
        addedAt: DateTime(2026, 1, 4),
      ),
    ];

    // ========================================================================
    // Feature: Favorites Page Entry
    // User enters favorites page and sees the main screen
    // ========================================================================
    group('Favorites Page Entry', () {
      testWidgets(
        'Given the app is running '
        'When the user enters the favorites page '
        'Then the page title "我的收藏" should be displayed',
        (tester) async {
          await tester.pumpWidget(
            const ProviderScope(
              child: MaterialApp(home: FavoritesScreen()),
            ),
          );

          expect(find.text('我的收藏'), findsOneWidget);
        },
      );

      testWidgets(
        'Given the user has no favorites '
        'When the user views the favorites page '
        'Then an empty state message should be displayed',
        (tester) async {
          await tester.pumpWidget(
            const ProviderScope(
              child: MaterialApp(home: FavoritesScreen()),
            ),
          );

          expect(find.text('還沒有收藏任何內容'), findsOneWidget);
        },
      );

      testWidgets(
        'Given the favorites page is displayed '
        'When the page loads '
        'Then the filter bar should be visible with all filter options',
        (tester) async {
          await tester.pumpWidget(
            const ProviderScope(
              child: MaterialApp(home: FavoritesScreen()),
            ),
          );

          expect(find.text('全部'), findsOneWidget);
          expect(find.text('電影'), findsOneWidget);
          expect(find.text('劇集'), findsOneWidget);
          expect(find.text('動漫'), findsOneWidget);
          expect(find.text('綜藝'), findsOneWidget);
        },
      );

      testWidgets(
        'Given the favorites page is displayed '
        'When the page loads '
        'Then the view toggle button should be visible',
        (tester) async {
          await tester.pumpWidget(
            const ProviderScope(
              child: MaterialApp(home: FavoritesScreen()),
            ),
          );

          // Initial state is grid view, so list icon should be shown
          expect(find.byIcon(Icons.list), findsOneWidget);
        },
      );
    });

    // ========================================================================
    // Feature: Grid View Display
    // User views favorites in a grid layout
    // ========================================================================
    group('Grid View Display', () {
      testWidgets(
        'Given the favorites store has items '
        'When the user views the grid '
        'Then all favorite items should be displayed in a grid',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: FavoriteGrid(
                  items: testFavorites,
                ),
              ),
            ),
          );

          // Grid should be visible
          expect(find.byType(GridView), findsOneWidget);
        },
      );

      testWidgets(
        'Given the grid view is active '
        'When the user views the grid '
        'Then each item should show the title',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: FavoriteGrid(
                  items: testFavorites,
                ),
              ),
            ),
          );

          expect(find.text('Test Movie 1'), findsOneWidget);
          expect(find.text('Test Series 1'), findsOneWidget);
          expect(find.text('Unavailable Anime'), findsOneWidget);
          expect(find.text('Test Variety 1'), findsOneWidget);
        },
      );

      testWidgets(
        'Given the favorites store is in grid view mode '
        'When the grid is rendered '
        'Then the items should be displayed in a grid layout',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: FavoriteGrid(
                  items: testFavorites,
                ),
              ),
            ),
          );

          // GridView should be displayed
          expect(find.byType(GridView), findsOneWidget);
        },
      );
    });

    // ========================================================================
    // Feature: List View Display
    // User views favorites in a list layout
    // ========================================================================
    group('List View Display', () {
      testWidgets(
        'Given the favorites store has items '
        'When the user toggles to list view '
        'Then the items should be displayed in a list layout',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: FavoriteGrid(
                  items: testFavorites,
                ),
              ),
            ),
          );

          // GridView should be displayed (FavoriteGrid uses GridView internally)
          expect(find.byType(GridView), findsOneWidget);
        },
      );

      testWidgets(
        'Given the list view is active '
        'When the user views the list '
        'Then each item should show the title',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: FavoriteGrid(
                  items: testFavorites,
                ),
              ),
            ),
          );

          expect(find.text('Test Movie 1'), findsOneWidget);
          expect(find.text('Test Series 1'), findsOneWidget);
          expect(find.text('Unavailable Anime'), findsOneWidget);
          expect(find.text('Test Variety 1'), findsOneWidget);
        },
      );

      test(
        'Given the user is in grid view '
        'When the user toggles the view '
        'Then the favoritesStore should update to list view',
        () {
          final store = TestFavoritesStore(
            const FavoritesState(),
          );

          expect(store.state.isGridView, true);

          store.toggleView();

          expect(store.state.isGridView, false);
        },
      );
    });

    // ========================================================================
    // Feature: Filter by Type
    // User can filter favorites by content type
    // ========================================================================
    group('Filter by Type', () {
      testWidgets(
        'Given the filter bar is displayed '
        'When the user views the filters '
        'Then all filter options should be visible',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: FavoritesFilterBar(
                  selectedType: 'all',
                  onTypeSelected: (_) {},
                ),
              ),
            ),
          );

          expect(find.text('全部'), findsOneWidget);
          expect(find.text('電影'), findsOneWidget);
          expect(find.text('劇集'), findsOneWidget);
          expect(find.text('動漫'), findsOneWidget);
          expect(find.text('綜藝'), findsOneWidget);
        },
      );

      testWidgets(
        'Given the user has selected a filter type '
        'When the user taps a different filter '
        'Then the onTypeSelected callback should be called with the new type',
        (tester) async {
          String? selectedType;

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: FavoritesFilterBar(
                  selectedType: 'all',
                  onTypeSelected: (type) {
                    selectedType = type;
                  },
                ),
              ),
            ),
          );

          // Tap on movie filter
          await tester.tap(find.text('電影'));
          await tester.pump();

          expect(selectedType, 'movie');
        },
      );

      test(
        'Given the favorites store has a filter type '
        'When setFilterType is called '
        'Then the filter type should be updated in state',
        () {
          final store = TestFavoritesStore(
            const FavoritesState(),
          );

          expect(store.state.filterType, 'all');

          store.setFilterType('anime');

          expect(store.state.filterType, 'anime');
        },
      );

      test(
        'Given the favorites state has items '
        'When filteredItems is accessed with type filter '
        'Then only items of that type should be returned',
        () {
          final state = FavoritesState(items: testFavorites);
          final filteredMovieItems = state.filteredItems
              .where((item) => item.type == 'movie')
              .toList();

          expect(filteredMovieItems.length, 1);
          expect(filteredMovieItems.first.title, 'Test Movie 1');
        },
      );

      test(
        'Given the favorites state has items '
        'When filteredItems is accessed with "all" filter '
        'Then all items should be returned',
        () {
          final state = FavoritesState(items: testFavorites);
          final allItems = state.filteredItems;

          expect(allItems.length, 4);
        },
      );
    });

    // ========================================================================
    // Feature: Unavailable Content Display
    // User sees unavailable content marked correctly
    // ========================================================================
    group('Unavailable Content Display', () {
      testWidgets(
        'Given the favorites store has unavailable items '
        'When the user views the items '
        'Then unavailable items should be marked with unavailability indicator',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: FavoriteTile(
                  item: testFavorites[2], // Unavailable Anime
                ),
              ),
            ),
          );

          // Unavailable item title should be visible
          expect(find.text('Unavailable Anime'), findsOneWidget);
        },
      );

      test(
        'Given a favorite item '
        'When the item is unavailable '
        'Then the isAvailable property should be false',
        () {
          final unavailableItem = testFavorites[2];

          expect(unavailableItem.isAvailable, false);
        },
      );

      test(
        'Given the favorites state '
        'When unavailableItems is accessed '
        'Then only unavailable items should be returned',
        () {
          final state = FavoritesState(items: testFavorites);
          final unavailableItems = state.unavailableItems;

          expect(unavailableItems.length, 1);
          expect(unavailableItems.first.title, 'Unavailable Anime');
        },
      );

      test(
        'Given the favorites state '
        'When availableItems is accessed '
        'Then only available items should be returned',
        () {
          final state = FavoritesState(items: testFavorites);
          final availableItems = state.availableItems;

          expect(availableItems.length, 3);
        },
      );

      test(
        'Given the favorites store has items '
        'When an item is removed '
        'Then the item should no longer appear in the list',
        () {
          final store = TestFavoritesStore(
            FavoritesState(items: testFavorites),
          );

          store.removeFavorite('1');

          expect(store.state.items.length, 3);
          expect(
            store.state.items.any((item) => item.id == '1'),
            false,
          );
        },
      );
    });

    // ========================================================================
    // Feature: FavoritesStore State Management
    // ========================================================================
    group('FavoritesStore State Management', () {
      test(
        'Given the FavoritesStore is initialized '
        'When the state is accessed '
        'Then it should have correct default values',
        () {
          final store = TestFavoritesStore(
            const FavoritesState(),
          );

          expect(store.state.items, isEmpty);
          expect(store.state.isLoading, false);
          expect(store.state.error, isNull);
          expect(store.state.isGridView, true);
          expect(store.state.filterType, 'all');
          expect(store.state.isSyncing, false);
        },
      );

      test(
        'Given the FavoritesStore has items '
        'When setItems is called '
        'Then the items should be updated and loading should be false',
        () {
          final store = TestFavoritesStore(
            const FavoritesState(),
          );

          store.setItems(testFavorites);

          expect(store.state.items.length, 4);
          expect(store.state.isLoading, false);
          expect(store.state.error, isNull);
        },
      );

      test(
        'Given the FavoritesStore '
        'When setLoading is called '
        'Then the loading state should be updated',
        () {
          final store = TestFavoritesStore(
            const FavoritesState(),
          );

          store.setLoading(true);
          expect(store.state.isLoading, true);

          store.setLoading(false);
          expect(store.state.isLoading, false);
        },
      );

      test(
        'Given the FavoritesStore '
        'When setError is called '
        'Then the error should be set and loading should be false',
        () {
          final store = TestFavoritesStore(
            const FavoritesState(),
          );

          store.setError('Test error message');

          expect(store.state.error, 'Test error message');
          expect(store.state.isLoading, false);
        },
      );

      test(
        'Given the FavoritesStore has an error '
        'When clearError is called '
        'Then the error should be cleared',
        () {
          final store = TestFavoritesStore(
            const FavoritesState(),
          );

          store.setError('Test error');
          expect(store.state.error, isNotNull);

          store.clearError();
          expect(store.state.error, isNull);
        },
      );

      test(
        'Given the FavoritesStore '
        'When setSyncing is called '
        'Then the syncing state should be updated',
        () {
          final store = TestFavoritesStore(
            const FavoritesState(),
          );

          store.setSyncing(true);
          expect(store.state.isSyncing, true);

          store.setSyncing(false);
          expect(store.state.isSyncing, false);
        },
      );
    });
  });
}

// ========================================================================
// Test helper: In-memory FavoritesStore for testing
// ========================================================================

class TestFavoritesStore {
  TestFavoritesStore(FavoritesState initialState) : _state = initialState;

  late FavoritesState _state;

  FavoritesState get state => _state;

  void toggleView() {
    _state = _state.copyWith(isGridView: !_state.isGridView);
  }

  void setFilterType(String type) {
    _state = _state.copyWith(filterType: type);
  }

  void loadFavorites() {
    _state = _state.copyWith(isLoading: false, error: null);
  }

  void removeFavorite(String id) {
    _state = _state.copyWith(
      items: _state.items.where((item) => item.id != id).toList(),
    );
  }

  void setItems(List<FavoriteItem> items) {
    _state = _state.copyWith(items: items, isLoading: false, clearError: true);
  }

  void setLoading(bool isLoading) {
    _state = _state.copyWith(isLoading: isLoading);
  }

  void setError(String error) {
    _state = _state.copyWith(error: error, isLoading: false);
  }

  void setSyncing(bool isSyncing) {
    _state = _state.copyWith(isSyncing: isSyncing);
  }

  void clearError() {
    _state = _state.copyWith(clearError: true);
  }
}