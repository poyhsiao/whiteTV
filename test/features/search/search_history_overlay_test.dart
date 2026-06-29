import 'package:white_tv/core/api/api_client_fallbacks.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:white_tv/features/search/search_history_overlay.dart';
import 'package:white_tv/features/search/search_store.dart';
import 'package:white_tv/features/search/services/search_history_service.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockApiClient extends Mock with ApiClientFallbacks implements ApiClient {}

class MockSearchHistoryService extends Mock implements SearchHistoryService {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('SearchHistoryOverlay', () {
    late MockApiClient mockClient;
    late MockSearchHistoryService mockHistoryService;

    setUp(() {
      mockClient = MockApiClient();
      mockHistoryService = MockSearchHistoryService();
    });

    testWidgets('overlay shows when isHistoryOverlayOpen is true', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer(
        overrides: [
          searchStoreProvider.overrideWith((ref) => SearchStore(mockClient)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                final state = ref.watch(searchStoreProvider);
                return state.isHistoryOverlayOpen
                    ? const SearchHistoryOverlay()
                    : const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(find.byType(SearchHistoryOverlay), findsNothing);

      // Open the overlay via container
      container.read(searchStoreProvider.notifier).openHistoryOverlay();
      await tester.pump();

      expect(find.byType(SearchHistoryOverlay), findsOneWidget);

      container.dispose();
    });

    testWidgets('overlay closes when closeHistoryOverlay is called', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer(
        overrides: [
          searchStoreProvider.overrideWith((ref) => SearchStore(mockClient)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                final state = ref.watch(searchStoreProvider);
                return state.isHistoryOverlayOpen
                    ? const SearchHistoryOverlay()
                    : const SizedBox();
              },
            ),
          ),
        ),
      );

      // Open the overlay
      container.read(searchStoreProvider.notifier).openHistoryOverlay();
      await tester.pump();
      expect(find.byType(SearchHistoryOverlay), findsOneWidget);

      // Close the overlay
      container.read(searchStoreProvider.notifier).closeHistoryOverlay();
      await tester.pump();
      expect(find.byType(SearchHistoryOverlay), findsNothing);

      container.dispose();
    });

    testWidgets('overlay displays history items', (tester) async {
      SharedPreferences.setMockInitialValues({});

      when(() => mockHistoryService.getHistory())
          .thenAnswer((_) async => ['星際穿越', '魷魚遊戲', '黑暗騎士']);
      when(() => mockHistoryService.fetchFromCloud()).thenAnswer((_) async => []);
      when(() => mockHistoryService.deleteItem(any())).thenAnswer((_) async {});
      when(() => mockHistoryService.clearAll()).thenAnswer((_) async {});

      final store = SearchStore(mockClient, mockHistoryService);

      final container = ProviderContainer(
        overrides: [
          searchStoreProvider.overrideWith((ref) => store),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                final state = ref.watch(searchStoreProvider);
                return state.isHistoryOverlayOpen
                    ? const SearchHistoryOverlay()
                    : const SizedBox();
              },
            ),
          ),
        ),
      );

      await store.loadHistory();
      store.openHistoryOverlay();
      await tester.pump();

      expect(find.text('星際穿越'), findsOneWidget);
      expect(find.text('魷魚遊戲'), findsOneWidget);
      expect(find.text('黑暗騎士'), findsOneWidget);

      container.dispose();
    });

    testWidgets('overlay shows empty state when no history', (tester) async {
      SharedPreferences.setMockInitialValues({});

      when(() => mockHistoryService.getHistory()).thenAnswer((_) async => []);
      when(() => mockHistoryService.fetchFromCloud()).thenAnswer((_) async => []);

      final store = SearchStore(mockClient, mockHistoryService);

      final container = ProviderContainer(
        overrides: [
          searchStoreProvider.overrideWith((ref) => store),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                final state = ref.watch(searchStoreProvider);
                return state.isHistoryOverlayOpen
                    ? const SearchHistoryOverlay()
                    : const SizedBox();
              },
            ),
          ),
        ),
      );

      await store.loadHistory();
      store.openHistoryOverlay();
      await tester.pump();

      expect(find.text('尚無搜尋記錄'), findsOneWidget);

      container.dispose();
    });

    testWidgets('tapping history item triggers searchFromHistory', (tester) async {
      SharedPreferences.setMockInitialValues({});

      when(() => mockHistoryService.getHistory()).thenAnswer((_) async => ['星際穿越']);
      when(() => mockHistoryService.fetchFromCloud()).thenAnswer((_) async => []);
      when(() => mockHistoryService.deleteItem(any())).thenAnswer((_) async {});
      when(() => mockClient.search(any(), category: any(named: 'category')))
          .thenAnswer((_) async => []);

      final store = SearchStore(mockClient, mockHistoryService);

      final container = ProviderContainer(
        overrides: [
          searchStoreProvider.overrideWith((ref) => store),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                final state = ref.watch(searchStoreProvider);
                return state.isHistoryOverlayOpen
                    ? const SearchHistoryOverlay()
                    : const SizedBox();
              },
            ),
          ),
        ),
      );

      await store.loadHistory();
      store.openHistoryOverlay();
      await tester.pump();

      // Tap on the history item
      await tester.tap(find.text('星際穿越'));
      await tester.pump();

      // Overlay should close and search should be triggered
      expect(store.state.isHistoryOverlayOpen, isFalse);
      expect(store.state.query, '星際穿越');

      container.dispose();
    });

    testWidgets('clear all button shows confirmation dialog', (tester) async {
      SharedPreferences.setMockInitialValues({});

      when(() => mockHistoryService.getHistory())
          .thenAnswer((_) async => ['星際穿越', '魷魚遊戲']);
      when(() => mockHistoryService.fetchFromCloud()).thenAnswer((_) async => []);
      when(() => mockHistoryService.clearAll()).thenAnswer((_) async {});
      when(() => mockHistoryService.deleteItem(any())).thenAnswer((_) async {});

      final store = SearchStore(mockClient, mockHistoryService);

      final container = ProviderContainer(
        overrides: [
          searchStoreProvider.overrideWith((ref) => store),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                final state = ref.watch(searchStoreProvider);
                return state.isHistoryOverlayOpen
                    ? const SearchHistoryOverlay()
                    : const SizedBox();
              },
            ),
          ),
        ),
      );

      await store.loadHistory();
      store.openHistoryOverlay();
      await tester.pump();

      // Find and tap clear all button
      final clearAllButton = find.byKey(const Key('clear_all'));
      expect(clearAllButton, findsOneWidget);

      await tester.tap(clearAllButton);
      await tester.pump();

      // Confirmation dialog should appear
      expect(find.byKey(const Key('confirm_dialog')), findsOneWidget);

      container.dispose();
    });

    testWidgets('voice input button in overlay is present', (tester) async {
      SharedPreferences.setMockInitialValues({});

      when(() => mockHistoryService.getHistory()).thenAnswer((_) async => []);
      when(() => mockHistoryService.fetchFromCloud()).thenAnswer((_) async => []);

      final store = SearchStore(mockClient, mockHistoryService);

      final container = ProviderContainer(
        overrides: [
          searchStoreProvider.overrideWith((ref) => store),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                final state = ref.watch(searchStoreProvider);
                return state.isHistoryOverlayOpen
                    ? const SearchHistoryOverlay()
                    : const SizedBox();
              },
            ),
          ),
        ),
      );

      store.openHistoryOverlay();
      await tester.pump();

      // Voice input button should be present
      expect(find.byKey(const Key('voice_input')), findsOneWidget);

      container.dispose();
    });
  });
}
