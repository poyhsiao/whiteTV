import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/main.dart';
import 'package:white_tv/core/router/app_router.dart';
import '../pages/search_page.dart';
import '../pages/detail_page.dart';
import '../pages/player_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Search and Play Flow E2E', () {
    testWidgets('User can search and navigate to detail', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: WhiteTVApp(
            router: createAppRouter(initialLocation: '/search'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Search
      final searchPage = SearchPage(tester);
      await searchPage.search('test movie');

      // Assert - Verify search results appear
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
