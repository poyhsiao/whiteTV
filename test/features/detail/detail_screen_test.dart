import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/features/detail/detail_screen.dart';
import 'package:white_tv/features/detail/detail_store.dart';

void main() {
  group('DetailScreen', () {
    testWidgets('renders DetailScreen widget', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            detailStoreProvider.overrideWith((ref) {
              final store = DetailStore(MockClient());
              return store;
            }),
          ],
          child: const MaterialApp(
            home: DetailScreen(videoId: 'movie-1'),
          ),
        ),
      );

      // Advance time to let the mock delay complete
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Scaffold should be visible
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}