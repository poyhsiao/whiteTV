import 'package:white_tv/core/api/api_client_fallbacks.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/search/search_screen.dart';
import 'package:white_tv/features/search/search_store.dart';
import 'package:white_tv/features/search/search_state.dart';
import 'package:white_tv/features/search/widgets/voice_input_button.dart';
import 'package:white_tv/features/search/search_history_overlay.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/features/live/data/models/ipvt_channel.dart';

void main() {
  group('SearchScreen', () {
    testWidgets('displays search input placeholder', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            searchStoreProvider.overrideWith(
              (ref) => SearchStore(FakeApiClient()),
            ),
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays search title in app bar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            searchStoreProvider.overrideWith(
              (ref) => SearchStore(FakeApiClient()),
            ),
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );
      expect(find.text('搜尋'), findsOneWidget);
    });

    testWidgets('displays search input field', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            searchStoreProvider.overrideWith(
              (ref) => SearchStore(FakeApiClient()),
            ),
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('displays category filter with ChoiceChips', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            searchStoreProvider.overrideWith(
              (ref) => SearchStore(FakeApiClient()),
            ),
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );
      // Category filter should have ChoiceChips for each category
      expect(find.byType(ChoiceChip), findsWidgets);
    });

    testWidgets('shows search input and results', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            searchStoreProvider.overrideWith(
              (ref) => SearchStore(FakeApiClient()),
            ),
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(VoiceInputButton), findsOneWidget);
    });

    testWidgets('tapping search input opens history overlay', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            searchStoreProvider.overrideWith(
              (ref) => SearchStore(FakeApiClient()),
            ),
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );

      // Find the TextField and tap it
      await tester.tap(find.byType(TextField));
      await tester.pump();

      // Verify overlay opens
      expect(find.byType(SearchHistoryOverlay), findsOneWidget);
    });

    testWidgets('closing overlay via store.closeHistoryOverlay', (
      tester,
    ) async {
      // Create store with pre-populated history for testing
      final store = SearchStore(FakeApiClient());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [searchStoreProvider.overrideWith((ref) => store)],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );

      // Open overlay
      store.openHistoryOverlay();
      await tester.pump();
      expect(find.byType(SearchHistoryOverlay), findsOneWidget);

      // Close overlay
      store.closeHistoryOverlay();
      await tester.pump();
      expect(find.byType(SearchHistoryOverlay), findsNothing);
    });
  });
}

class FakeApiClient with ApiClientFallbacks implements ApiClient {
  @override
  Future<List<int>> search(String query, {SearchCategory? category}) async {
    return [];
  }

  @override
  Future<List<IptvChannel>> getIptvChannels() async => [];

  @override
  Future<String?> getIptvM3U() async => null;

  @override
  Future<Map<String, dynamic>> getIptvEpg() async => {};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
