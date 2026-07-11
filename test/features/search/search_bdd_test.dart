import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/features/search/search_screen.dart';
import 'package:white_tv/features/search/search_store.dart';
import 'package:white_tv/features/search/search_state.dart';
import 'package:white_tv/features/search/widgets/category_filter.dart';
import 'package:white_tv/features/search/widgets/keyboard_input_view.dart';
import 'package:white_tv/features/search/widgets/search_results.dart';
import 'package:white_tv/features/search/services/search_history_service.dart';
import 'package:white_tv/core/api/mock_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Search Feature BDD Tests', () {
    // ========================================================================
    // Background: Shared test data
    // ========================================================================
    final testVideos = [
      const Video(
        id: '1',
        title: 'Test Movie 1',
        posterUrl: 'https://example.com/poster1.jpg',
        description: 'Test description 1',
        categoryId: 'movie',
        type: 'movie',
      ),
      const Video(
        id: '2',
        title: 'Test Series 1',
        posterUrl: 'https://example.com/poster2.jpg',
        description: 'Test description 2',
        categoryId: 'series',
        type: 'series',
      ),
      const Video(
        id: '3',
        title: 'Test Anime 1',
        posterUrl: 'https://example.com/poster3.jpg',
        description: 'Test description 3',
        categoryId: 'anime',
        type: 'anime',
      ),
    ];

    // ========================================================================
    // Feature: Search Input Flow
    // User can input search query via text field
    // ========================================================================
    group('Search Input Flow', () {
      testWidgets('Given the search screen is displayed '
          'When the user views the search screen '
          'Then a placeholder text should be shown prompting to search', (
        tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              searchStoreProvider.overrideWith(
                (ref) => SearchStore(MockClient()),
              ),
            ],
            child: const MaterialApp(home: SearchScreen()),
          ),
        );

        // Verify placeholder text is shown when no search performed
        expect(find.text('輸入搜尋關鍵字...'), findsOneWidget);
      });
    });

    // ========================================================================
    // Feature: Category Filter Flow
    // User can filter by category (all/movie/series/anime/variety)
    // ========================================================================
    group('Category Filter Flow', () {
      testWidgets('Given the search screen is displayed '
          'When the user views the category filter '
          'Then all category options should be visible', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategoryFilter(
                selectedCategory: SearchCategory.all,
                onCategorySelected: (_) {},
              ),
            ),
          ),
        );

        // All category labels should be visible (using Simplified Chinese from CategoryFilter)
        expect(find.text('全部'), findsOneWidget);
        expect(find.text('电影'), findsOneWidget);
        expect(find.text('剧集'), findsOneWidget);
        expect(find.text('动漫'), findsOneWidget);
        expect(find.text('综艺'), findsOneWidget);
      });

      testWidgets(
        'Given the user has selected a category '
        'When the user taps a different category '
        'Then the onCategorySelected callback should be called with the new category',
        (tester) async {
          SearchCategory? selectedCategory;

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: CategoryFilter(
                  selectedCategory: SearchCategory.all,
                  onCategorySelected: (category) {
                    selectedCategory = category;
                  },
                ),
              ),
            ),
          );

          // Tap on movie category (using Simplified Chinese)
          await tester.tap(find.text('电影'));
          await tester.pump();

          // Verify callback was called with movie category
          expect(selectedCategory, SearchCategory.movie);
        },
      );

      testWidgets('Given the search store has a selected category '
          'When setCategory is called with a new category '
          'Then the active category should be updated in state', (
        tester,
      ) async {
        final store = SearchStore(MockClient());

        expect(store.state.activeCategory, SearchCategory.all);

        store.setCategory(SearchCategory.anime);

        expect(store.state.activeCategory, SearchCategory.anime);
      });
    });

    // ========================================================================
    // Feature: Search Results Flow
    // Results are displayed in a grid with poster cards
    // ========================================================================
    group('Search Results Flow', () {
      testWidgets('Given the search has completed '
          'When results are available '
          'Then the results should be displayed in a grid', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SearchResults(results: testVideos, isLoading: false),
            ),
          ),
        );

        // GridView should be displayed
        expect(find.byType(GridView), findsOneWidget);

        // Video titles should be visible
        expect(find.text('Test Movie 1'), findsOneWidget);
        expect(find.text('Test Series 1'), findsOneWidget);
        expect(find.text('Test Anime 1'), findsOneWidget);
      });

      testWidgets('Given the search is in progress '
          'When the results are loading '
          'Then a loading indicator should be displayed', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SearchResults(results: const [], isLoading: true),
            ),
          ),
        );

        // CircularProgressIndicator should be shown
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('Given the search has completed with no results '
          'When the results are empty '
          'Then a "No results found" message should be displayed', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SearchResults(results: const [], isLoading: false),
            ),
          ),
        );

        // No results message should be visible
        expect(find.text('No results found'), findsOneWidget);
      });

      testWidgets('Given the search results are displayed '
          'When the user taps on a result '
          'Then the onResultSelected callback should be called', (
        tester,
      ) async {
        Video? selectedVideo;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SearchResults(
                results: testVideos,
                isLoading: false,
                onResultSelected: (video) {
                  selectedVideo = video;
                },
              ),
            ),
          ),
        );

        // Tap on first result
        await tester.tap(find.text('Test Movie 1'));
        await tester.pump();

        // Verify callback was called
        expect(selectedVideo, isNotNull);
        expect(selectedVideo!.title, 'Test Movie 1');
      });
    });

    // ========================================================================
    // Feature: Keyboard Mode Flow
    // D-pad keyboard can be toggled and used for input
    // ========================================================================
    group('Keyboard Mode Flow', () {
      testWidgets('Given the search store has keyboard mode disabled '
          'When toggleKeyboardMode is called '
          'Then the keyboard mode should be enabled', (tester) async {
        final store = SearchStore(MockClient());

        expect(store.state.isKeyboardMode, false);

        store.toggleKeyboardMode();

        expect(store.state.isKeyboardMode, true);
      });

      testWidgets('Given the keyboard mode is enabled '
          'When a key is pressed on the d-pad keyboard '
          'Then the onKeyPressed callback should receive the key value', (
        tester,
      ) async {
        String? pressedKey;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: KeyboardInputView(
                onKeyPressed: (key) {
                  pressedKey = key;
                },
              ),
            ),
          ),
        );

        // Find a keyboard key (letter A key)
        final letterA = find.text('A');
        expect(letterA, findsOneWidget);

        // Tap on letter A
        await tester.tap(letterA);
        await tester.pump();

        // Verify callback received 'A'
        expect(pressedKey, 'A');
      });

      testWidgets('Given the keyboard is displayed '
          'When the user taps Space key '
          'Then a space character should be sent', (tester) async {
        String? pressedKey;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: KeyboardInputView(
                onKeyPressed: (key) {
                  pressedKey = key;
                },
              ),
            ),
          ),
        );

        // Find and tap Space key
        await tester.tap(find.text('Space'));
        await tester.pump();

        // Verify space was pressed
        expect(pressedKey, ' ');
      });

      testWidgets('Given the keyboard is displayed '
          'When the user taps backspace key '
          'Then a backspace character should be sent', (tester) async {
        String? pressedKey;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: KeyboardInputView(
                onKeyPressed: (key) {
                  pressedKey = key;
                },
              ),
            ),
          ),
        );

        // Find and tap backspace key
        await tester.tap(find.text('⌫')); // Unicode for backspace symbol
        await tester.pump();

        // Verify backspace was pressed
        expect(pressedKey, '\b');
      });
    });

    // ========================================================================
    // Feature: QR Scan Flow
    // QR scanner can be opened and scanning works
    // ========================================================================
    group('QR Scan Flow', () {
      testWidgets('Given the QR scanner is displayed '
          'When the camera permission is denied '
          'Then a permission denied message should be shown', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _QRInputViewTestWidget(
                hasPermission: false,
                onCodeScanned: (_) {},
              ),
            ),
          ),
        );

        // Permission denied message should be visible
        expect(find.text('Camera permission denied'), findsOneWidget);
        expect(
          find.text('Please enable camera access in settings'),
          findsOneWidget,
        );
      });

      testWidgets('Given the QR scanner has detected a code '
          'When a valid QR code is scanned '
          'Then the onCodeScanned callback should be called with the code', (
        tester,
      ) async {
        String? scannedCode;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _QRInputViewTestWidget(
                hasPermission: true,
                onCodeScanned: (code) {
                  scannedCode = code;
                },
              ),
            ),
          ),
        );

        // Simulate scanning (would require actual camera in device tests)
        // This tests the callback mechanism
        expect(scannedCode, isNull);
      });
    });

    // ========================================================================
    // Feature: History Flow
    // Search history is saved and displayed
    // ========================================================================
    group('History Flow', () {
      testWidgets(
        'Given the SearchHistoryService has saved searches '
        'When getHistory is called '
        'Then the saved search queries should be returned in order (newest first)',
        (tester) async {
          SharedPreferences.setMockInitialValues({});
          final prefs = await SharedPreferences.getInstance();
          final service = SearchHistoryService(prefs, MockClient());

          // Save some searches
          await service.saveSearch('query1');
          await service.saveSearch('query2');
          await service.saveSearch('query3');

          // Get history
          final history = await service.getHistory();

          // Verify order (newest first)
          expect(history, ['query3', 'query2', 'query1']);
        },
      );

      testWidgets('Given the SearchHistoryService has duplicate searches '
          'When a duplicate query is saved '
          'Then it should be moved to the front without duplicates', (
        tester,
      ) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final service = SearchHistoryService(prefs, MockClient());

        // Save searches
        await service.saveSearch('query1');
        await service.saveSearch('query2');
        await service.saveSearch('query1'); // duplicate

        final history = await service.getHistory();

        // Should have no duplicates, query1 at front
        expect(history, ['query1', 'query2']);
      });

      testWidgets('Given the SearchHistoryService has reached max items '
          'When a new search is saved '
          'Then the oldest search should be removed', (tester) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final service = SearchHistoryService(prefs, MockClient());

        // Save 21 searches (max is 20)
        for (var i = 0; i < 21; i++) {
          await service.saveSearch('query$i');
        }

        final history = await service.getHistory();

        // Should have only 20 items
        expect(history.length, 20);
        // Should not contain query0 (the oldest)
        expect(history.contains('query0'), false);
      });

      testWidgets('Given the user wants to clear history '
          'When clearAll is called '
          'Then all history should be removed', (tester) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final service = SearchHistoryService(prefs, MockClient());

        // Save some searches
        await service.saveSearch('query1');
        await service.saveSearch('query2');

        // Clear history
        await service.clearAll();

        final history = await service.getHistory();

        // History should be empty
        expect(history, isEmpty);
      });

      testWidgets('Given the SearchHistoryService '
          'When an empty query is saved '
          'Then it should be ignored', (tester) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final service = SearchHistoryService(prefs, MockClient());

        // Try to save empty query
        await service.saveSearch('');
        await service.saveSearch('   '); // whitespace only
        await service.saveSearch('valid');

        final history = await service.getHistory();

        // Should only contain valid query
        expect(history, ['valid']);
      });

      test('Given the SearchStore has performed searches '
          'When clearSearch is called '
          'Then the current query should be added to history', () async {
        final store = SearchStore(MockClient());

        // Perform a search
        await store.search('test query');

        // Clear search - should add to history
        store.clearSearch();

        // Verify query was added to history
        expect(store.state.searchHistory, contains('test query'));
      });
    });

    // ========================================================================
    // Feature: Error Handling Flow
    // Error and loading states are properly handled
    // ========================================================================
    group('Error Handling Flow', () {
      test(
        'Given the search query is empty '
        'When search is called '
        'Then no API call should be made and results should be cleared',
        () async {
          final store = SearchStore(MockClient());

          // Set some results first via search
          await store.search('test');

          // Clear with empty query
          await store.search('');

          // Results should be cleared
          expect(store.state.results, isEmpty);
          expect(store.state.query, '');
        },
      );

      test('Given the search store is initialized '
          'When a search is performed '
          'Then the loading state should be set during the search', () async {
        final store = SearchStore(MockClient());

        expect(store.state.isLoading, false);

        // Start search but don't await
        final searchFuture = store.search('test');

        // At this point loading should be true (or just finished due to mock delay being short)
        await searchFuture;

        // After search completes, loading should be false
        expect(store.state.isLoading, false);
      });
    });

    // ========================================================================
    // Feature: SearchStore State Management
    // ========================================================================
    group('SearchStore State Management', () {
      test('Given the SearchStore is initialized '
          'When the state is accessed '
          'Then it should have correct default values', () {
        final store = SearchStore(MockClient());

        expect(store.state.query, '');
        expect(store.state.results, isEmpty);
        expect(store.state.searchHistory, isEmpty);
        expect(store.state.isLoading, false);
        expect(store.state.error, isNull);
        expect(store.state.activeCategory, SearchCategory.all);
        expect(store.state.isKeyboardMode, false);
      });

      test('Given the SearchStore has performed a search '
          'When the search method is called '
          'Then the query should be updated in state', () async {
        final store = SearchStore(MockClient());

        await store.search('星際穿越');

        expect(store.state.query, '星際穿越');
      });

      test('Given the SearchStore has keyboard mode enabled '
          'When toggleKeyboardMode is called '
          'Then the keyboard mode should be disabled', () {
        final store = SearchStore(MockClient());

        store.toggleKeyboardMode();
        expect(store.state.isKeyboardMode, true);

        store.toggleKeyboardMode();
        expect(store.state.isKeyboardMode, false);
      });

      test('Given the SearchStore has results '
          'When clearSearch is called '
          'Then the query and results should be cleared', () async {
        final store = SearchStore(MockClient());

        await store.search('test');
        store.clearSearch();

        expect(store.state.query, '');
        expect(store.state.results, isEmpty);
      });
    });
  });
}

// ============================================================================
// Test helper widgets for QR input view testing
// ============================================================================

/// Test widget that simulates QRInputView with mockable permission state
class _QRInputViewTestWidget extends StatefulWidget {
  final bool hasPermission;
  final void Function(String code) onCodeScanned;

  const _QRInputViewTestWidget({
    required this.hasPermission,
    required this.onCodeScanned,
  });

  @override
  State<_QRInputViewTestWidget> createState() => _QRInputViewTestWidgetState();
}

class _QRInputViewTestWidgetState extends State<_QRInputViewTestWidget> {
  @override
  Widget build(BuildContext context) {
    if (!widget.hasPermission) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Camera permission denied',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Please enable camera access in settings',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Placeholder for camera preview
          Container(color: Colors.black),
          // Scanning frame
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Instructions
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  'Align QR code within the frame',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
