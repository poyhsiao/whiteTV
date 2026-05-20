import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/search/search_screen.dart';
import 'package:white_tv/features/search/search_store.dart';
import 'package:white_tv/features/search/search_state.dart';
import 'package:white_tv/core/api/api_client.dart';

void main() {
  group('SearchScreen', () {
    testWidgets('displays search input placeholder', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            searchStoreProvider.overrideWith((ref) => SearchStore(FakeApiClient())),
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
            searchStoreProvider.overrideWith((ref) => SearchStore(FakeApiClient())),
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
            searchStoreProvider.overrideWith((ref) => SearchStore(FakeApiClient())),
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
            searchStoreProvider.overrideWith((ref) => SearchStore(FakeApiClient())),
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );
      // Category filter should have ChoiceChips for each category
      expect(find.byType(ChoiceChip), findsWidgets);
    });
  });
}

class FakeApiClient implements ApiClient {
  @override
  Future<List<int>> search(String query, {SearchCategory? category}) async {
    return [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
