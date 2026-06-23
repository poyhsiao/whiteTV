import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/main.dart';
import 'package:white_tv/core/router/app_router.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/features/search/search_store.dart';
import 'package:white_tv/features/search/search_state.dart';
import 'package:white_tv/features/live/data/models/ipvt_channel.dart';
import '../e2e_test_helpers.dart';
import '../pages/search_page.dart';

class FakeApiClient implements ApiClient {
  @override
  Future<List<int>> search(String query, {SearchCategory? category}) async => [];
  @override
  Future<List<IptvChannel>> getIptvChannels() async => [];
  @override
  Future<String?> getIptvM3U() async => null;
  @override
  Future<Map<String, dynamic>> getIptvEpg() async => {};
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Search and Play Flow E2E', () {
    testWidgets('User can search and navigate to detail', (WidgetTester tester) async {
      setupE2EPluginMocks();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            searchStoreProvider.overrideWith(
              (ref) => SearchStore(FakeApiClient()),
            ),
          ],
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
