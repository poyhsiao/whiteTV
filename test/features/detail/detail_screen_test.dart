import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/core/source/source_selector.dart';
import 'package:white_tv/features/detail/detail_screen.dart';
import 'package:white_tv/features/detail/detail_store.dart';

void main() {
  group('DetailScreen', () {
    testWidgets('renders DetailScreen widget', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            detailStoreProvider.overrideWith((ref) {
              final store = DetailStore(MockClient(), SourceSelector(), null);
              return store;
            }),
          ],
          child: const MaterialApp(
            home: DetailScreen(videoId: 'movie-1'),
          ),
        ),
      );

      // Advance time to let the mock delay complete (大於 mock delay 300ms)
      await tester.pump(const Duration(milliseconds: 500));
      // Drain pending timers to avoid leaked timer assertion
      await tester.pump(const Duration(seconds: 1));

      // Scaffold should be visible
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}